FROM kong:2.8.1

COPY ./kong.yml /home/kong/kong.yml.tpl

ENTRYPOINT ["bash", "-c", "eval \"echo \\\"$(cat ~/kong.yml.tpl)\\\"\" > ~/kong.yml && /docker-entrypoint.sh kong docker-start"]
