##
# Local Swagger docker configuration
##

# enable realpath extension
enable -f realpath realpath

# path to locally cloned swagger repo
SWAGGER_REPO_PATH=$(dirname $( realpath ${BASH_SOURCE[0]} ) )

# Start local swagger using specified openapi spec
swagu() {
  # Verify user passed 1 argument
  if [[ -z "${1}" ]]; then
    echo 'Pass either a URL or a local path to a valid openapi spec JSON/YAML file'
    return 1
  else
    url_regex='^(http(s)?:\/\/).*'
    if [[ "${1}" =~ $url_regex ]]; then
      # If user passes a url use docker-compose-url.yaml
      SWAGGER_COMPOSE=docker-compose-url.yaml
      # Set url specific env vars
      SWAGGER_VARS=( SWAGGER_URL="${1}" )
    else
      # If user passes a filepath use docker-compose-localfile.yaml
      SWAGGER_COMPOSE=docker-compose-localfile.yaml
      full_path=$(realpath "${1}")
      base_name=$(basename "${full_path}")
      # Set localfile specific env vars
      SWAGGER_VARS=( SWAGGER_PATH="${full_path}" SWAGGER_FILE="${base_name}" )
    fi

    # Bring up specific docker-compose file
    env "${SWAGGER_VARS[@]}" docker-compose -f "${SWAGGER_REPO_PATH}/${SWAGGER_COMPOSE}" up -d
    # Print status of docker-compose
    docker-compose -f "${SWAGGER_REPO_PATH}/${SWAGGER_COMPOSE}" ps
    # Open new browser tab to swagger-ui
    browser_cmd=$(command -v xdg-open || command -v gnome-open || command -v open) && $("${browser_cmd}" http://localhost:${SWAGGER_UI_PORT:-8080})
  fi
}

swagd() {
  docker-compose --project-directory "${SWAGGER_REPO_PATH}" down
}
