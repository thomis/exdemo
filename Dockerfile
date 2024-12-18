FROM thomis/elixir-rocky

WORKDIR /app
COPY . /app
RUN cp /app/devops/build_release .
RUN chmod +x /app/build_release
RUN cp /root/.tool-versions .
