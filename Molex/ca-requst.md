Subject: Request to Export and Trust Fortinet Root Certificate for GitLab Runner Registration

Description:

We are currently migrating our code platform from Kochsource to GitLab. During the process of registering a GitLab Runner on our internal server, we encountered a TLS verification error due to the GitLab certificate being signed by an internal Fortinet firewall CA (CN=FG200FT923926512). This CA is not included in the system's default trusted root certificate store, which causes the runner registration to fail with the following error:

tls: failed to verify certificate: x509: certificate signed by unknown authority
Request:

Please export the root certificate from the Fortinet firewall (CN=FG200FT923926512).
Provide the certificate in .crt or .pem format.
We will manually install and trust this certificate on the GitLab Runner host at:
/etc/pki/ca-trust/source/anchors/
followed by running:
update-ca-trust extract
Server Information:

GitLab Runner Hostname: MLXCDUVLPGL01.molex.com
Operating System: Linux (RHEL/CentOS-based)
GitLab Runner Version: 17.1.0
Purpose:

This is required to allow the GitLab Runner to securely communicate with GitLab over HTTPS and complete the registration process.

Additional Info:

GitLab URL: https://gitlab.com