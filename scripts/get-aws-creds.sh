CREDENTIALS=$(aws sts get-session-token)

set -x

export AWS_ACCESS_KEY_ID=$(echo ${CREDENTIALS} | jq -r .Credentials.AccessKeyId)
export AWS_SECRET_ACCESS_KEY=$(echo ${CREDENTIALS} | jq -r .Credentials.SecretAccessKey)
export AWS_SESSION_TOKEN=$(echo ${CREDENTIALS} | jq -r .Credentials.SessionToken)
