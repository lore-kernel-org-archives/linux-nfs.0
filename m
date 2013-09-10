Return-Path: linux-nfs-owner@vger.kernel.org
Received: from postout2.mail.lrz.de ([129.187.255.138]:51833 "EHLO
	postout2.mail.lrz.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751296Ab3IJSzT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Sep 2013 14:55:19 -0400
Message-ID: <522F69A1.5090005@tum.de>
Date: Tue, 10 Sep 2013 20:49:05 +0200
From: Joschi Brauchle <joschi.brauchle@tum.de>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: nfsd4: utime sometimes takes 40+ seconds to return (but on SLES11SP3
 with kernel 3.0.82)
Content-Type: multipart/signed; protocol="application/pkcs7-signature"; micalg=sha1; boundary="------------ms030905080503040800040105"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a cryptographically signed message in MIME format.

--------------ms030905080503040800040105
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

Hello everyone,

we are administrating an NFS high-availability cluster running on=20
SLES11SP1 with kernel 2.6.32.59. Just recently, one of the cluster=20
machines was updated to SLES11SP3 with kernel 3.0.82.


We are now experiencing severe hangs on NFS clients when the SLES11SP3=20
server is running the NFS services. An strace on the hanging processes=20
on the client side show that is is waiting up to 60+ seconds for a=20
"utime()" call to complete.


The problem we see is matching the problem described in the thread "v3.5 =

nfsd4 regression; utime sometimes takes 40+ seconds to return". If the=20
NFS server is running on SLES11SP3, the little test program provided in=20
this tread hangs at the "utime()" call for 60+ seconds. It hangs each=20
time it is run! It finishes right away with 0 seconds delay is SLES11SP1 =

is providing NFS services, each time.


Now, in the serverside logfiles of SLES11SP3 we see these messages (not=20
so on SP1):
--------------
kernel: [99381.184976] RPC: AUTH_GSS upcall timed out.
kernel: [99381.184978] Please check user daemon is running.
--------------

We have always been running the NFS server without rpc.gssd on the=20
server side, as the init script for the nfsserver also does not start=20
rpc.gssd.


Once we started rpc.gssd on the SLES11SP3 server, using the test utility =

on the client shows that the first call to "utime()" succeeds right=20
away, the second call takes ~25s to complete. But now, any consecutive=20
runs of the utility finish with no more delay.


So can anyone confirm that with kernel 3.0+ the rpc.gssd daemon is also=20
required on the server side for correct operation?

Has there been a change between kernel 2.6.32.59 and 3.0.x?

Thus, is the init script of the nfsserver in SLES11SP3 indeed missing to =

start rpc.gssd?

Thank you for your help!

Best regards,
--=20
Dipl.-Ing. Joschi Brauchle, M.S.

Institute for Communications Engineering (LNT)
Technische Universitaet Muenchen (TUM)
80290 Munich, Germany

Tel (work): +49 89 289-23474
Fax (work): +49 89 289-23490
E-mail: joschi.brauchle@tum.de
Web: http://www.lnt.ei.tum.de/



--------------ms030905080503040800040105
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIObzCC
BCEwggMJoAMCAQICAgDHMA0GCSqGSIb3DQEBBQUAMHExCzAJBgNVBAYTAkRFMRwwGgYDVQQK
ExNEZXV0c2NoZSBUZWxla29tIEFHMR8wHQYDVQQLExZULVRlbGVTZWMgVHJ1c3QgQ2VudGVy
MSMwIQYDVQQDExpEZXV0c2NoZSBUZWxla29tIFJvb3QgQ0EgMjAeFw0wNjEyMTkxMDI5MDBa
Fw0xOTA2MzAyMzU5MDBaMFoxCzAJBgNVBAYTAkRFMRMwEQYDVQQKEwpERk4tVmVyZWluMRAw
DgYDVQQLEwdERk4tUEtJMSQwIgYDVQQDExtERk4tVmVyZWluIFBDQSBHbG9iYWwgLSBHMDEw
ggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDpm8NnhfkNrvWNVMOWUDU9YuluTO2U
1wBblSJ01CDrNI/W7MAxBAuZgeKmFNJSoCgjhIt0iQReW+DieMF4yxbLKDU5ey2QRdDtoAB6
fL9KDhsAw4bpXCsxEXsM84IkQ4wcOItqaACa7txPeKvSxhObdq3u3ibo7wGvdA/BCaL2a869
080UME/15eOkyGKbghoDJzANAmVgTe3RCSMqljVYJ9N2xnG2kB3E7f81hn1vM7PbD8URwoqD
oZRdQWvY0hD1TP3KUazZve+Sg7va64sWVlZDz+HVEz2mHycwzUlU28kTNJpxdcVs6qcLmPkh
nSevPqM5OUhqjK3JmfvDEvK9AgMBAAGjgdkwgdYwcAYDVR0fBGkwZzBloGOgYYZfaHR0cDov
L3BraS50ZWxlc2VjLmRlL2NnaS1iaW4vc2VydmljZS9hZl9Eb3dubG9hZEFSTC5jcmw/LWNy
bF9mb3JtYXQ9WF81MDkmLWlzc3Vlcj1EVF9ST09UX0NBXzIwHQYDVR0OBBYEFEm3xs/oPR9/
6kR7Eyn38QpwPt5kMB8GA1UdIwQYMBaAFDHDeRu69VPXF+CJei0XbAqzK50zMA4GA1UdDwEB
/wQEAwIBBjASBgNVHRMBAf8ECDAGAQH/AgECMA0GCSqGSIb3DQEBBQUAA4IBAQA74Vp3wEgX
3KkY7IGvWonwvSiSpspZGBJw7Cjy565/lizn8l0ZMfYTK3S9vYCyufdnyTmieTvhERHua3iR
M347XyYndVNljjNj7s9zw7CSI0khUHUjoR8Y4pSFPT8z6XcgjaK95qGFKUD2P3MyWA0Ja6ba
hWzAP7uNZmRWJE6uDT8yNQFb6YyC2XJZT7GGhfF0hVblw/hc843uR7NTBXDn5U2KaYMo4RMJ
hp5eyOpYHgwf+aTUWgRo/Sg+iwK2WLX2oSw3VwBnqyNojWOl75lrXP1LVvarQIc01BGSbOyH
xQoLBzNytG8MHVQs2FHHzL8w00Ny8TK/jM5JY6gA9/IcMIIEzDCCA7SgAwIBAgIECfEKYzAN
BgkqhkiG9w0BAQUFADBaMQswCQYDVQQGEwJERTETMBEGA1UEChMKREZOLVZlcmVpbjEQMA4G
A1UECxMHREZOLVBLSTEkMCIGA1UEAxMbREZOLVZlcmVpbiBQQ0EgR2xvYmFsIC0gRzAxMB4X
DTA3MDIxMzEwMDMwMVoXDTE5MDIxMjAwMDAwMFowYDELMAkGA1UEBhMCREUxKTAnBgNVBAoT
IFRlY2huaXNjaGUgVW5pdmVyc2l0YWV0IE11ZW5jaGVuMSYwJAYDVQQDEx1aZXJ0aWZpemll
cnVuZ3NzdGVsbGUgZGVyIFRVTTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKjv
6NPYBFzJ+ZELc6JfE/5aga/7K7LWMVBHZvohdJZGd31pN9QEfzQeph0kiqsm1X5kHraPtTc9
jMH8SLASBI45JppNSSYRfw6j6RjKA7PUStRfV0dq5cBPBl5FpxAY23lAzMzY+6EQEq3/hS8I
a3zG5Q5saJsc+9B2So8+gvaVwZhrWhe7NhyvVqYMiBpTE9fbViah3Ur5VdDpcGbsb/BqRDxR
rOCjQdNQ6TCQHfIUEDTQMW/czj1wbgLxrp8sB5XlwMPX7c2Do+yByWbcrkitdGEeagcWqC1g
c8pD/f8PJIoVeW4cy60PjHRIfYC0NBVvg9P0viuwFEyWM17brI8CAwEAAaOCAZIwggGOMA8G
A1UdEwEB/wQFMAMBAf8wCwYDVR0PBAQDAgEGMB0GA1UdDgQWBBSdnyPwGRt+xyNdJyrMpTY6
pmnliTAfBgNVHSMEGDAWgBRJt8bP6D0ff+pEexMp9/EKcD7eZDCBiAYDVR0fBIGAMH4wPaA7
oDmGN2h0dHA6Ly9jZHAxLnBjYS5kZm4uZGUvZ2xvYmFsLXJvb3QtY2EvcHViL2NybC9jYWNy
bC5jcmwwPaA7oDmGN2h0dHA6Ly9jZHAyLnBjYS5kZm4uZGUvZ2xvYmFsLXJvb3QtY2EvcHVi
L2NybC9jYWNybC5jcmwwgaIGCCsGAQUFBwEBBIGVMIGSMEcGCCsGAQUFBzAChjtodHRwOi8v
Y2RwMS5wY2EuZGZuLmRlL2dsb2JhbC1yb290LWNhL3B1Yi9jYWNlcnQvY2FjZXJ0LmNydDBH
BggrBgEFBQcwAoY7aHR0cDovL2NkcDIucGNhLmRmbi5kZS9nbG9iYWwtcm9vdC1jYS9wdWIv
Y2FjZXJ0L2NhY2VydC5jcnQwDQYJKoZIhvcNAQEFBQADggEBAINoNtnDCyUwcPDc68e/u5O/
ffcs+r4x4OeRxKtYXd3dRCyuCoxJAhhepSk2oQc89QhWFOOBxeT7KosoCsn+htLtgnZLj4R/
yNX8MemzYP170OZ/m4X9vmRhty+gh90kCSZlaQgT9MfV+7g1C6QgelUDV8N68Nd4Pl1IMBWk
AkZZLcT9/Hgol59FGhFDF1uFx7Su+vYBlO3g+tHnI18XJBDOs2abHRXI5PmYcvtGirsVMfWc
s0ooZOonYw5pvWI+N8dat9DNIvgRdoChTOKdvPURjtkY3kJkvdAfPKsf/ZCj3HhdEn0b6VZQ
qDj7VJRCvFOL0tqSc2wUrHLRw/9Mu2gwggV2MIIEXqADAgECAgQQ26t7MA0GCSqGSIb3DQEB
BQUAMGAxCzAJBgNVBAYTAkRFMSkwJwYDVQQKEyBUZWNobmlzY2hlIFVuaXZlcnNpdGFldCBN
dWVuY2hlbjEmMCQGA1UEAxMdWmVydGlmaXppZXJ1bmdzc3RlbGxlIGRlciBUVU0wHhcNMTAx
MDE4MTEyMjIwWhcNMTMxMDE3MTEyMjIwWjCB3TELMAkGA1UEBhMCREUxDzANBgNVBAgTBkJh
eWVybjERMA8GA1UEBxMITXVlbmNoZW4xKTAnBgNVBAoTIFRlY2huaXNjaGUgVW5pdmVyc2l0
YWV0IE11ZW5jaGVuMT4wPAYDVQQLEzVGYWt1bHRhZXQgZnVlciBFbGVrdHJvdGVjaG5payB1
bmQgSW5mb3JtYXRpb25zdGVjaG5pazEYMBYGA1UEAxMPSm9zY2hpIEJyYXVjaGxlMSUwIwYJ
KoZIhvcNAQkBFhZqb3NjaGkuYnJhdWNobGVAdHVtLmRlMIIBIjANBgkqhkiG9w0BAQEFAAOC
AQ8AMIIBCgKCAQEA2cF6tIlKUNmY12XEz8gAtWLnifpPKQ06VhsHNH3FRa3qqpScW96ypYRL
z3HTot2GdY7JSmEKSx7p5ehlOKbEcKsr57nbVzOkVW/0SmmWjroxzXe1e4KTw9QmpxXXQI5F
uUXRQoXZhgkPJWXa31uEzixbWIO4DHzM2TuEidFk3y2zcyA4j6g8flb8zMMSQjqAafTDA8Cf
A+j7cJZOCk30UZYNRuGLJi6tJi1nmaDy1ZMDAQA5P8nQJ3BpJGCxWwm5A0ppEBlKPFWjproJ
n8NErCRHRhWWcKkHwzwI48zB0bnrsKqMQVpkgSquGD94dbyDAIbht5M8HSE8eqmWj7Ug6QID
AQABo4IBuDCCAbQwCQYDVR0TBAIwADALBgNVHQ8EBAMCBeAwKQYDVR0lBCIwIAYIKwYBBQUH
AwIGCCsGAQUFBwMEBgorBgEEAYI3FAICMB0GA1UdDgQWBBSqoAQm9/5Acan0m0kcMmLzRDUu
FDAfBgNVHSMEGDAWgBSdnyPwGRt+xyNdJyrMpTY6pmnliTAhBgNVHREEGjAYgRZqb3NjaGku
YnJhdWNobGVAdHVtLmRlMHcGA1UdHwRwMG4wNaAzoDGGL2h0dHA6Ly9jZHAxLnBjYS5kZm4u
ZGUvdHVtLWNhL3B1Yi9jcmwvY2FjcmwuY3JsMDWgM6Axhi9odHRwOi8vY2RwMi5wY2EuZGZu
LmRlL3R1bS1jYS9wdWIvY3JsL2NhY3JsLmNybDCBkgYIKwYBBQUHAQEEgYUwgYIwPwYIKwYB
BQUHMAKGM2h0dHA6Ly9jZHAxLnBjYS5kZm4uZGUvdHVtLWNhL3B1Yi9jYWNlcnQvY2FjZXJ0
LmNydDA/BggrBgEFBQcwAoYzaHR0cDovL2NkcDIucGNhLmRmbi5kZS90dW0tY2EvcHViL2Nh
Y2VydC9jYWNlcnQuY3J0MA0GCSqGSIb3DQEBBQUAA4IBAQCnQxDlwDKK5DSFIj5NaYxqCc3W
xO2X/VXL+MSw+3cgsp9W9pYsnWSUoYY32lHoOj45LNGJWZ4ikueDiG20j23n/ao+G8lwVh3D
+UPikmFPp2PWg3GlbRwQ33cbAxVIJ+XsOJupbQDfKh3U4AV91bdd/Eug3OAGOMbtB84HgD9G
sy1xEUDHuq4Ol24JUuZdimNPHUyMvk4bth+CECNcDjiUZ6kJ24m0AKE1GqkRbk7hyfqwhSCU
OP2riJ6JBQZf0U9sK91TjdNF0+he8SZpDJtJdMFZ75TO5Rwr7KLh6v6IefYYPo4f/IfdtMOX
LIVBpOWj/snSrDeGoO9X62zPufqGMYIDUjCCA04CAQEwaDBgMQswCQYDVQQGEwJERTEpMCcG
A1UEChMgVGVjaG5pc2NoZSBVbml2ZXJzaXRhZXQgTXVlbmNoZW4xJjAkBgNVBAMTHVplcnRp
Zml6aWVydW5nc3N0ZWxsZSBkZXIgVFVNAgQQ26t7MAkGBSsOAwIaBQCgggG/MBgGCSqGSIb3
DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTEzMDkxMDE4NDkwNVowIwYJKoZI
hvcNAQkEMRYEFBSr0eZI1IvLJ9STJBee2x62kbu7MGwGCSqGSIb3DQEJDzFfMF0wCwYJYIZI
AWUDBAEqMAsGCWCGSAFlAwQBAjAKBggqhkiG9w0DBzAOBggqhkiG9w0DAgICAIAwDQYIKoZI
hvcNAwICAUAwBwYFKw4DAgcwDQYIKoZIhvcNAwICASgwdwYJKwYBBAGCNxAEMWowaDBgMQsw
CQYDVQQGEwJERTEpMCcGA1UEChMgVGVjaG5pc2NoZSBVbml2ZXJzaXRhZXQgTXVlbmNoZW4x
JjAkBgNVBAMTHVplcnRpZml6aWVydW5nc3N0ZWxsZSBkZXIgVFVNAgQQ26t7MHkGCyqGSIb3
DQEJEAILMWqgaDBgMQswCQYDVQQGEwJERTEpMCcGA1UEChMgVGVjaG5pc2NoZSBVbml2ZXJz
aXRhZXQgTXVlbmNoZW4xJjAkBgNVBAMTHVplcnRpZml6aWVydW5nc3N0ZWxsZSBkZXIgVFVN
AgQQ26t7MA0GCSqGSIb3DQEBAQUABIIBAIvQDB/ntud6eex5ku5byDhIsN1V5n8JZ6riXfJS
iNuyg93lk5SUTaSPQXp/hgWkh2Q5wPExUy3h+N7PmuxNx1Qy/jv0reQH84aeGS0GumMs8doR
FTc/RQtKLRE6UT+TKWqDZZYLpChXvkbI6mNgUun6shyRc00IMNT+wbDwP1DGBgTJa4JqKXAn
c/oDh9mqcF8uiHNuDkDkEB1RIH1BuM4l0BNluSMCBPnX7zkunxADO1pOE/eMR2aPghE6Ddnf
LOcAtLtoRSqdoQqBIvv9klgdn08v3uZKTDuveriQtStmARUWm5DgwjHErjO8qqdvmK3y71TP
vG9v/ygN/Nf4YWIAAAAAAAA=
--------------ms030905080503040800040105--
