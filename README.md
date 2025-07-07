# Rotten Potatoes 🎬

Rotten Potatoes is a lightweight, full-stack movie review application built with Flask, MongoDB, and a custom frontend. It is designed to showcase modern development practices and serve as a foundation for CI/CD pipelines using tools such as Terraform, Ansible, Trivy, Hadolint, Docker Scout, Docker, and Kubernetes.

---

## 🚀 Features

- Flask-based web server
- Movie and review models with MongoDB backend
- Dynamic HTML pages using Jinja2 templates
- Predefined movies from a YAML source
- Fully responsive UI with custom CSS and Sass
- REST-style routing and middleware support

---

## ⚙️ Configuration

To run the application, you need access to a MongoDB instance. Configure the following environment variables to connect to the database:

- `MONGODB_DB` → Name of the MongoDB database
- `MONGODB_HOST` → MongoDB host address
- `MONGODB_PORT` → Port used to access MongoDB
- `MONGODB_USERNAME` → MongoDB username
- `MONGODB_PASSWORD` → MongoDB password

You can set these variables in your shell or use a `.env` file with a tool like `python-dotenv`.

---

## 🧪 Technologies to Integrate (CI/CD Pipeline)

This project will be extended with a complete DevOps pipeline including:

- **Terraform**: Provisioning infrastructure (e.g., cloud VMs or Kubernetes clusters)
- **Ansible**: Configuration management for server setup
- **Docker**: Containerization of the application
- **Hadolint**: Linting Dockerfiles
- **Trivy**: Vulnerability scanning
- **Docker Scout**: Deep container image analysis
- **Kubernetes**: Orchestrating container deployment
- **GitHub Actions / GitLab CI**: Automating builds, tests, and deployments

---

## 🏗️ Project Structure

```

src/
├── app.py               # Main application
├── config.py            # App configuration
├── middleware.py        # Middleware hooks
├── mongodb.py           # DB connection setup
├── models/              # Data models (movie, review)
├── templates/           # HTML templates
├── static/              # Static assets (CSS, JS, images)
├── requirements.txt     # Python dependencies
└── movies.yaml          # Sample movie data

````

---

## 📦 Installation

```bash
# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r src/requirements.txt

# Set environment variables (example)
export MONGODB_DB=rottenpotatoes
export MONGODB_HOST=localhost
export MONGODB_PORT=27017
export MONGODB_USERNAME=admin
export MONGODB_PASSWORD=secret

# Run the app
python src/app.py
````

---

## 🛠️ CI/CD Goals

This repository is part of a larger portfolio project. The goal is to:

* Practice infrastructure as code
* Secure and scan Docker images
* Automate testing and deployment to Kubernetes
* Learn DevOps workflows end-to-end
