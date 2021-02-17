version: "3.7"
services:
  confluence:
    image: atlassian/confluence-server
    ports:
      - "${http_port}:8090"
    volumes:
      - /data/confluence:/var/atlassian/application-data/confluence
    environment:
      - ATL_JDBC_URL=jdbc:postgresql://${db_host}:5432/${db_db}
      - ATL_JDBC_USER=${db_user}
      - ATL_JDBC_PASSWORD='${db_pass}'
      - ATL_DB_TYPE=postgresql
