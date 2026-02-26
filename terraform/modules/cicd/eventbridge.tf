# -------------------------------------------------------
# EventBridge Rules — CodePipeline Formatted Notifications
# Replaces raw-JSON CodeStar Notifications with clean,
# human-readable messages via the Input Transformer.
#
# Email format:
#   ==============================
#   AWS CodePipeline | FAILED
#   ==============================
#   Pipeline  : ecs-bluegreen-pipeline
#   Status    : FAILED
#   Region    : us-east-1
#   Time (UTC): 2026-02-26T09:27:58Z
#   Execution : 25f27d49-...
#
#   View in Console:
#   https://console.aws.amazon.com/...
#   ==============================
# -------------------------------------------------------

# -------------------------------------------------------
# Rule 1 — Pipeline-level execution state changes
# Triggers on: STARTED, SUCCEEDED, FAILED, STOPPED, SUPERSEDED
# -------------------------------------------------------
resource "aws_cloudwatch_event_rule" "pipeline_execution" {
  name        = "pipeline-execution-notifications"
  description = "Capture CodePipeline execution state changes and send formatted SNS notifications"

  event_pattern = jsonencode({
    source        = ["aws.codepipeline"]
    "detail-type" = ["CodePipeline Pipeline Execution State Change"]
    detail = {
      pipeline = [aws_codepipeline.ecs_pipeline.name]
      state    = ["STARTED", "SUCCEEDED", "FAILED", "STOPPED", "SUPERSEDED"]
    }
  })
}

resource "aws_cloudwatch_event_target" "pipeline_execution_sns" {
  rule      = aws_cloudwatch_event_rule.pipeline_execution.name
  target_id = "PipelineExecutionSNS"
  arn       = var.sns_topic_arn

  input_transformer {
    input_paths = {
      pipeline    = "$.detail.pipeline"
      state       = "$.detail.state"
      executionId = "$.detail.execution-id"
      region      = "$.region"
      account     = "$.account"
      time        = "$.time"
    }

    # Plain-text formatted message — SNS email renders \n as newlines.
    # The outer quotes make this a valid JSON string (required by EventBridge).
    input_template = "\"==============================\\nAWS CodePipeline | <state>\\n==============================\\n\\nPipeline  : <pipeline>\\nStatus    : <state>\\nRegion    : <region>\\nTime (UTC): <time>\\nExecution : <executionId>\\nAccount   : <account>\\n\\nView in Console:\\nhttps://console.aws.amazon.com/codesuite/codepipeline/pipelines/<pipeline>/view?region=<region>\\n\\n==============================\""
  }
}

# -------------------------------------------------------
# Rule 2 — Stage-level execution state changes
# Triggers on per-stage STARTED, SUCCEEDED, FAILED
# Useful for knowing exactly which stage (Source/Build/Deploy) failed
# -------------------------------------------------------
resource "aws_cloudwatch_event_rule" "pipeline_stage" {
  name        = "pipeline-stage-notifications"
  description = "Capture CodePipeline stage-level state changes"

  event_pattern = jsonencode({
    source        = ["aws.codepipeline"]
    "detail-type" = ["CodePipeline Stage Execution State Change"]
    detail = {
      pipeline = [aws_codepipeline.ecs_pipeline.name]
      state    = ["FAILED", "SUCCEEDED"]
    }
  })
}

resource "aws_cloudwatch_event_target" "pipeline_stage_sns" {
  rule      = aws_cloudwatch_event_rule.pipeline_stage.name
  target_id = "PipelineStageSNS"
  arn       = var.sns_topic_arn

  input_transformer {
    input_paths = {
      pipeline = "$.detail.pipeline"
      state    = "$.detail.state"
      stage    = "$.detail.stage"
      region   = "$.region"
      time     = "$.time"
    }

    input_template = "\"------------------------------\\nSTAGE FAILED: <stage>\\n------------------------------\\n\\nPipeline  : <pipeline>\\nStage     : <stage>\\nStatus    : <state>\\nRegion    : <region>\\nTime (UTC): <time>\\n\\nView in Console:\\nhttps://console.aws.amazon.com/codesuite/codepipeline/pipelines/<pipeline>/view?region=<region>\\n\\n------------------------------\""
  }
}
