#!/usr/bin/env python3
"""
NVIDIA Model Manager for S3 Operations
Handles both 8B LLM and Retriever model configurations with graceful error handling
"""

import boto3
import os
import json
import time
from typing import Dict, Any, Optional, List
from pathlib import Path
from botocore.exceptions import ClientError, NoCredentialsError, EndpointConnectionError

from loguru import logger

# Configure loguru for beautiful, structured logging
logger.remove()  # Remove default handler
logger.add(
    "logs/s3_operations.log",
    format="{time:YYYY-MM-DD HH:mm:ss} | {level} | {message}",
    rotation="10 MB",
    retention="7 days",
    level="INFO"
)
logger.add(
    lambda msg: print(msg, end=""),  # Also print to console
    format="<green>{time:HH:mm:ss}</green> | <level>{level: <8}</level> | <cyan>{message}</cyan>",
    level="INFO"
)


class ModelManager:
    """Enhanced S3 manager for NVIDIA models with comprehensive error handling"""
    
    def __init__(self, bucket_name: str, region: str = "us-east-1"):
        self.bucket_name = bucket_name
        self.region = region
        self.s3_client = None
        self._initialize_client()
        
        # NVIDIA Model configurations
        self.nvidia_models = {
            "llm": {
                "name": "Llama-3.1-Nemotron-Nano-8B-v1",
                "huggingface_url": "https://huggingface.co/nvidia/Llama-3.1-Nemotron-Nano-8B-v1",
                "s3_prefix": "models/llm/",
                "config_file": "model_config.json"
            },
            "retriever": {
                "name": "llama-3_2-nemoretriever-300m-embed-v1", 
                "build_url": "https://build.nvidia.com/nvidia/llama-3_2-nemoretriever-300m-embed-v1",
                "s3_prefix": "models/retriever/",
                "config_file": "model_config.json"
            }
        }
    
    def _initialize_client(self) -> bool:
        """Initialize S3 client with error handling"""
        try:
            self.s3_client = boto3.client('s3', region_name=self.region)
            
            # Test connection with a simple operation
            self.s3_client.head_bucket(Bucket=self.bucket_name)
            logger.success(f"✅ Successfully connected to S3 bucket: {self.bucket_name}")
            return True
            
        except NoCredentialsError:
            logger.error("❌ AWS credentials not found. Please configure AWS CLI or set environment variables.")
            return False
        except ClientError as e:
            error_code = e.response['Error']['Code']
            if error_code == '404':
                logger.error(f"❌ Bucket {self.bucket_name} not found. Check bucket name and permissions.")
            elif error_code == '403':
                logger.error(f"❌ Access denied to bucket {self.bucket_name}. Check IAM permissions.")
            else:
                logger.error(f"❌ AWS ClientError: {e}")
            return False
        except EndpointConnectionError:
            logger.error(f"❌ Cannot connect to S3 endpoint in region {self.region}. Check network and region.")
            return False
        except Exception as e:
            logger.error(f"❌ Unexpected error initializing S3 client: {e}")
            return False
    
    def _create_model_config(self, model_type: str) -> Dict[str, Any]:
        """Create standardized model configuration"""
        base_config = {
            "model_type": model_type,
            "upload_timestamp": time.time(),
            "upload_date_iso": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
            "version": "1.0",
            "environment": "hackathon",
            "owner": "pydev369"
        }
        
        if model_type == "llm":
            base_config.update({
                "model_name": self.nvidia_models["llm"]["name"],
                "parameters": "8B",
                "architecture": "Transformer",
                "context_length": 4096,
                "precision": "bfloat16",
                "nim_compatible": True,
                "deployment": {
                    "instance_type": "g4dn.xlarge",
                    "gpu_required": True,
                    "gpu_memory": "16GB",
                    "container_image": "nvcr.io/nvidia/nim:latest"
                }
            })
        elif model_type == "retriever":
            base_config.update({
                "model_name": self.nvidia_models["retriever"]["name"],
                "parameters": "300M",
                "embedding_dimension": 1024,
                "architecture": "Retriever",
                "max_sequence_length": 2048,
                "nim_compatible": True,
                "deployment": {
                    "instance_type": "cpu",
                    "gpu_required": False,
                    "container_image": "nvcr.io/nvidia/nim:latest"
                }
            })
        
        return base_config
    
    def upload_model_config(self, model_type: str, custom_config: Dict[str, Any] = None) -> bool:
        """Upload model configuration to S3 with comprehensive error handling"""
        if not self.s3_client:
            logger.error("❌ S3 client not initialized. Cannot upload configuration.")
            return False
        
        if model_type not in self.nvidia_models:
            logger.error(f"❌ Unknown model type: {model_type}. Available: {list(self.nvidia_models.keys())}")
            return False
        
        try:
            model_info = self.nvidia_models[model_type]
            config = self._create_model_config(model_type)
            
            # Merge with custom configuration if provided
            if custom_config:
                config.update(custom_config)
            
            key = f"{model_info['s3_prefix']}{model_info['config_file']}"
            
            logger.info(f"📤 Uploading {model_type} configuration to S3...")
            logger.debug(f"📁 S3 Key: {key}")
            logger.debug(f"⚙️  Config: {json.dumps(config, indent=2)}")
            
            self.s3_client.put_object(
                Bucket=self.bucket_name,
                Key=key,
                Body=json.dumps(config, indent=2),
                ContentType='application/json',
                Metadata={
                    'model-type': model_type,
                    'uploaded-by': 'pydev369',
                    'hackathon': 'nvidia-agentic-app'
                }
            )
            
            logger.success(f"✅ Successfully uploaded {model_type} configuration to s3://{self.bucket_name}/{key}")
            return True
            
        except ClientError as e:
            logger.error(f"❌ Failed to upload {model_type} configuration: {e}")
            return False
        except Exception as e:
            logger.error(f"❌ Unexpected error uploading {model_type} configuration: {e}")
            return False
    
    def download_model_config(self, model_type: str) -> Optional[Dict[str, Any]]:
        """Download model configuration from S3 with error handling"""
        if not self.s3_client:
            logger.error("❌ S3 client not initialized. Cannot download configuration.")
            return None
        
        try:
            model_info = self.nvidia_models[model_type]
            key = f"{model_info['s3_prefix']}{model_info['config_file']}"
            
            logger.info(f"📥 Downloading {model_type} configuration from S3...")
            
            response = self.s3_client.get_object(Bucket=self.bucket_name, Key=key)
            config_data = json.loads(response['Body'].read())
            
            logger.success(f"✅ Successfully downloaded {model_type} configuration")
            logger.debug(f"📋 Config: {json.dumps(config_data, indent=2)}")
            
            return config_data
            
        except ClientError as e:
            error_code = e.response['Error']['Code']
            if error_code == 'NoSuchKey':
                logger.warning(f"⚠️  Configuration not found for {model_type}. Run upload first.")
            else:
                logger.error(f"❌ Failed to download {model_type} configuration: {e}")
            return None
        except Exception as e:
            logger.error(f"❌ Unexpected error downloading {model_type} configuration: {e}")
            return None
    
    def upload_lock_file(self, deployment_id: str, lock_data: Dict[str, Any]) -> bool:
        """Upload deployment lock file to prevent conflicts"""
        try:
            lock_data.update({
                "lock_timestamp": time.time(),
                "lock_owner": "pydev369",
                "deployment_id": deployment_id
            })
            
            key = f"locks/{deployment_id}.json"
            
            logger.info(f"🔒 Uploading lock file for deployment {deployment_id}...")
            
            self.s3_client.put_object(
                Bucket=self.bucket_name,
                Key=key,
                Body=json.dumps(lock_data, indent=2),
                ContentType='application/json'
            )
            
            logger.success(f"✅ Lock file uploaded: s3://{self.bucket_name}/{key}")
            return True
            
        except Exception as e:
            logger.error(f"❌ Failed to upload lock file: {e}")
            return False
    
    def check_lock_file(self, deployment_id: str) -> bool:
        """Check if a lock file exists"""
        try:
            key = f"locks/{deployment_id}.json"
            self.s3_client.head_object(Bucket=self.bucket_name, Key=key)
            logger.warning(f"⚠️  Lock file exists for deployment: {deployment_id}")
            return True
        except ClientError:
            return False
        except Exception as e:
            logger.error(f"❌ Error checking lock file: {e}")
            return False
    
    def list_uploaded_configs(self) -> List[str]:
        """List all uploaded model configurations"""
        try:
            response = self.s3_client.list_objects_v2(
                Bucket=self.bucket_name,
                Prefix="models/"
            )
            
            if 'Contents' not in response:
                logger.info("📭 No model configurations found in S3")
                return []
            
            configs = [obj['Key'] for obj in response['Contents'] if obj['Key'].endswith('.json')]
            logger.info(f"📋 Found {len(configs)} model configurations:")
            for config in configs:
                logger.info(f"   📄 {config}")
            
            return configs
            
        except Exception as e:
            logger.error(f"❌ Error listing configurations: {e}")
            return []


def main():
    """Main execution function with step-by-step workflow"""
    logger.info("🚀 Starting NVIDIA Model Manager S3 Operations")
    
    # Initialize manager
    manager = ModelManager("nvidia-models-pydev369")
    
    if not manager.s3_client:
        logger.error("❌ Failed to initialize S3 client. Exiting.")
        return
    
    # Step 1: Upload LLM Configuration
    logger.info("\n" + "="*50)
    logger.info("STEP 1: Uploading 8B LLM Configuration")
    logger.info("="*50)
    
    llm_success = manager.upload_model_config("llm", {
        "custom_notes": "Primary reasoning model for agentic workflow",
        "expected_throughput": "100 tokens/sec on T4",
        "api_endpoint": "/v1/chat/completions"
    })
    
    # Step 2: Upload Retriever Configuration  
    logger.info("\n" + "="*50)
    logger.info("STEP 2: Uploading Retriever Configuration")
    logger.info("="*50)
    
    retriever_success = manager.upload_model_config("retriever", {
        "custom_notes": "Embedding model for RAG and validation",
        "embedding_usage": "document retrieval, similarity search",
        "api_endpoint": "/v1/embeddings"
    })
    
    # Step 3: Create Deployment Lock
    logger.info("\n" + "="*50)
    logger.info("STEP 3: Creating Deployment Lock")
    logger.info("="*50)
    
    deployment_id = f"deploy-{int(time.time())}"
    lock_success = manager.upload_lock_file(deployment_id, {
        "models": ["llm", "retriever"],
        "status": "initializing",
        "cluster": "nvidia-hackathon-cluster"
    })
    
    # Step 4: Verify Uploads
    logger.info("\n" + "="*50)
    logger.info("STEP 4: Verification & Summary")
    logger.info("="*50)
    
    manager.list_uploaded_configs()
    
    # Download and verify one configuration
    llm_config = manager.download_model_config("llm")
    if llm_config:
        logger.success("✅ LLM configuration verified successfully")
    
    # Final status
    logger.info("\n" + "🎯 OPERATION SUMMARY:")
    logger.info(f"   LLM Config: {'✅ SUCCESS' if llm_success else '❌ FAILED'}")
    logger.info(f"   Retriever Config: {'✅ SUCCESS' if retriever_success else '❌ FAILED'}")
    logger.info(f"   Lock File: {'✅ SUCCESS' if lock_success else '❌ FAILED'}")
    
    if all([llm_success, retriever_success, lock_success]):
        logger.success("🎉 All S3 operations completed successfully!")
    else:
        logger.error("💥 Some operations failed. Check logs above.")


if __name__ == "__main__":
    # Create logs directory
    Path("logs").mkdir(exist_ok=True)
    
    try:
        main()
    except KeyboardInterrupt:
        logger.warning("⏹️  Operation cancelled by user")
    except Exception as e:
        logger.critical(f"💥 Critical error in main execution: {e}")