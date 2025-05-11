from setuptools import setup, find_packages

with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

setup(
    name="vaultarq",
    version="0.1.11",
    author="Dedan Okware",
    author_email="softengdedan@gmail.com",
    description="Python SDK for Vaultarq - The developer-first, invisible secrets manager",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/Vaultarq/vaultarq",
    project_urls={
        "Bug Tracker": "https://github.com/Vaultarq/vaultarq/issues",
    },
    classifiers=[
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.7",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
        "Development Status :: 4 - Beta",
        "Intended Audience :: Developers",
        "Topic :: Security",
        "Topic :: Software Development",
    ],
    packages=find_packages(),
    python_requires=">=3.7",
    keywords="secrets, environment, env, secrets-management, security",
) 