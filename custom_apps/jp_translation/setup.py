from setuptools import setup, find_packages

with open("requirements.txt") as f:
    install_requires = f.read().strip().split("\n")

setup(
    name="jp_translation",
    version="0.1.0",
    description="Japanese Translation Enhancement for ERPNext",
    author="Sasuke Torii",
    author_email="support@example.com",
    packages=find_packages(),
    zip_safe=False,
    include_package_data=True,
    install_requires=install_requires
)