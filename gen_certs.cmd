@echo off
setlocal

cd %~dp0
call env_vars.cmd

for /f "tokens=*" %%G in ('dir %DOMAINS_DIR% /b') do (
	echo [trust_cert] > %TMP_DIR%\%%G.cnf
	echo subjectAltName=@alt_names >> %TMP_DIR%\%%G.cnf
	echo keyUsage=digitalSignature,keyEncipherment,dataEncipherment >> %TMP_DIR%\%%G.cnf
	echo extendedKeyUsage=serverAuth,clientAuth >> %TMP_DIR%\%%G.cnf
	rem echo authorityInfoAccess=OCSP;URI:http://%%G:8888 >> %TMP_DIR%\%%G.cnf
	echo crlDistributionPoints=URI:http://localhost/revoked.crl >> %TMP_DIR%\%%G.cnf
	echo [alt_names] >> %TMP_DIR%\%%G.cnf
	echo DNS.1 = %%G >> %TMP_DIR%\%%G.cnf
	echo DNS.2 = %%G.ospanel.io >> %TMP_DIR%\%%G.cnf

	openssl genrsa -out %CERTS_DIR%\%%G.key %RSA_KEY_BITS%
	openssl req -sha256 -new -key %CERTS_DIR%\%%G.key -out %TMP_DIR%\%%G.csr -subj /emailAddress=%KEY_EMAIL%/C="%KEY_COUNTRY%"/stateOrProvinceName="%KEY_STATE%"/L="%KEY_CITY%"/O="%KEY_ORG%"/OU="%KEY_ORG_UNIT%"/CN=%%G
	rem Для создания самоподписанного сертификата
	rem openssl x509 -sha256 -req -days %CA_VALID_DAYS% -in %TMP_DIR%\%%G.csr -signkey %CERTS_DIR%\%%%G.key -out %CERTS_DIR%\%%%G.crt
	rem Для создания сертификата, подписанного доверенным сертификатом
	openssl x509 -sha256 -req -days %CA_VALID_DAYS% -in %TMP_DIR%\%%G.csr -extfile %TMP_DIR%\%%G.cnf -extensions trust_cert -CA %CA_DIR%/trusted.crt -CAkey %CA_DIR%/trusted.key -out %CERTS_DIR%\%%G.crt
)

del %TMP_DIR%\*.csr
del %TMP_DIR%\*.cnf

pause