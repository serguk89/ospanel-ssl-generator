@echo off
setlocal EnableDelayedExpansion

cd %~dp0
call env_vars.cmd

set dname=https

echo [trust_cert] > %TMP_DIR%\%dname%.cnf
echo subjectAltName=@alt_names >> %TMP_DIR%\%dname%.cnf
echo keyUsage=digitalSignature,keyEncipherment,dataEncipherment >> %TMP_DIR%\%dname%.cnf
echo extendedKeyUsage=serverAuth,clientAuth >> %TMP_DIR%\%dname%.cnf
echo [alt_names] >> %TMP_DIR%\%dname%.cnf
set /a count = 1
for /f "tokens=*" %%G in ('dir %DOMAINS_DIR% /b') do (
	echo DNS.!count! = %%G.webdev >> %TMP_DIR%\%dname%.cnf
	set /a count += 1
)
 
openssl req -sha256 -new -utf8 -key %CA_DIR%\trusted.key -out %TMP_DIR%\%dname%.csr -subj /emailAddress="info\@webdev\.io"/C=RU/stateOrProvinceName="Ukraine"/L=Kyiv/O="Local Server"/OU=Software/CN=localhost
 
openssl x509 -sha256 -req -days %CA_VALID_DAYS% -in %TMP_DIR%\%dname%.csr -extfile %TMP_DIR%\%dname%.cnf -extensions trust_cert -CA %CA_DIR%\trusted.crt -CAkey %CA_DIR%\trusted.key -out %CERTS_DIR%\%dname%.crt
 
openssl x509 -in %CERTS_DIR%\%dname%.crt -noout -purpose
 
del %TMP_DIR%\%dname%.csr
del %TMP_DIR%\%dname%.cnf