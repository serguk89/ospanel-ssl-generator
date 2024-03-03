@echo off

cd %~dp0
call env_vars.cmd

set cert_name=https
set dname=webdev.localhost
set cname="*.%dname%"

echo [trust_cert] > %TMP_DIR%\%dname%.cnf
echo subjectAltName=@alt_names >> %TMP_DIR%\%dname%.cnf
echo keyUsage=digitalSignature,keyEncipherment,dataEncipherment >> %TMP_DIR%\%dname%.cnf
echo extendedKeyUsage=serverAuth,clientAuth >> %TMP_DIR%\%dname%.cnf
echo [alt_names] >> %TMP_DIR%\%dname%.cnf
echo DNS.1 = %dname% >> %TMP_DIR%\%dname%.cnf
echo DNS.2 = %cname% >> %TMP_DIR%\%dname%.cnf

openssl genrsa -out %CERTS_DIR%\%cert_name%.key %RSA_KEY_BITS%

openssl req -sha256 -new -utf8 -key %CERTS_DIR%\%cert_name%.key -out %TMP_DIR%\%dname%.csr -subj /emailAddress="info\@webdev\.io"/C=RU/stateOrProvinceName="Ukraine"/L=Kyiv/O="Local Server"/OU=Software/CN=%cname%
 
openssl x509 -sha256 -req -days %CA_VALID_DAYS% -in %TMP_DIR%\%dname%.csr -extfile %TMP_DIR%\%dname%.cnf -out %CERTS_DIR%\%cert_name%.crt -extensions trust_cert -CA %CA_DIR%\trusted.crt -CAkey %CA_DIR%\trusted.key
 
openssl x509 -in %CERTS_DIR%\%cert_name%.crt -noout -purpose
 
del %TMP_DIR%\%dname%.csr
del %TMP_DIR%\%dname%.cnf