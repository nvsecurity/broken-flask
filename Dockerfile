# ---------------------------------------------------------------------------------------------------------------------
# Build with Chainguard secure images which have zero CVEs
# Credit: https://github.com/chainguard-dev/cg-images-python-migration
# ---------------------------------------------------------------------------------------------------------------------
FROM python:3.11-alpine as builder

WORKDIR /flask_app

RUN python -m venv venv
ENV PATH="/flask_app/venv/bin":$PATH
COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt

# Using the dev image so we can use shell commands
FROM python:3.11-alpine

WORKDIR /flask_app

COPY flask_app .

COPY --from=builder /flask_app/venv /flask_app/venv
RUN mkdir -p /flask_app/instance && \
    rm -f /flask_app/instance/* && \
    chmod -R 754 /flask_app/instance
ENV PATH="/flask_app/venv/bin:$PATH"

EXPOSE 4000

ENTRYPOINT ["python"]
CMD ["-m", "gunicorn", "-b", "0.0.0.0:4000", "--workers=4", "app:app"]