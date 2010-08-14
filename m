Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail1-relais-roc.national.inria.fr ([192.134.164.82]:36655 "EHLO
	mail1-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754268Ab0HNPDK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 14 Aug 2010 11:03:10 -0400
Message-ID: <4C66ADF2.9030700@inria.fr>
Date: Sat, 14 Aug 2010 16:53:38 +0200
From: Guillaume Rousse <Guillaume.Rousse@inria.fr>
To: linux-nfs@vger.kernel.org
Subject: [patch] fix description of nfsversion mount option
Content-Type: multipart/signed; protocol="application/pkcs7-signature"; micalg=sha1; boundary="------------ms020404070904090006010907"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--------------ms020404070904090006010907
Content-Type: multipart/mixed;
 boundary="------------010408050106000307050103"

This is a multi-part message in MIME format.
--------------010408050106000307050103
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hello list.

Here is a first patch trying to update a little bit nfs-utils
documentation. I'd like also to change the constant opposition of 'nfs'
vs 'nfs4' filesystems in this man page, but I have no clue if the plan
is to remove 'nfs4' filesystem completly, or to keep for compatibility
purpose. In the first case, I'd just remove any occurence of it in the
man page, in the second case, I'm less sure about what to do.

Also, I really think NEWS and ChangeLOG files should be either dropped,
or merged and updated.
--=20
BOFH excuse #295:

The Token fell out of the ring. Call us when you find it.

--------------010408050106000307050103
Content-Type: text/plain;
 name="0001-fix-description-of-nfsversion-mount-option.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename*0="0001-fix-description-of-nfsversion-mount-option.patch"

=46rom b03afedc798ff96cab3d5b174ed620fd126abb71 Mon Sep 17 00:00:00 2001
From: Guillaume Rousse <Guillaume.Rousse@inria.fr>
Date: Sat, 14 Aug 2010 16:46:59 +0200
Subject: [PATCH] fix description of nfsversion mount option

---
 utils/mount/nfs.man |   11 +++--------
 1 files changed, 3 insertions(+), 8 deletions(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index c64de5f..3806635 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -623,14 +623,9 @@ in such cases.
 .TP 1.5i
 .BI nfsvers=3D n
 The NFS protocol version number used to contact the server's NFS service=
=2E
-The Linux client supports version 2 and version 3 of the NFS protocol
-when using the file system type
-.BR nfs .
-If the server does not support the requested version,
-the mount request fails.
-If this option is not specified, the client attempts to use version 3,
-but negotiates the NFS version with the server if version 3 support
-is not available.
+If the server does not support the requested version, the mount request =
fails.
+If this option is not specified, the client negociate a suitable version=
 with
+the server, trying version 4 first, version 3 second, and version 2 last=
=2E
 .TP 1.5i
 .BI vers=3D n
 This option is an alternative to the
--=20
1.7.2.1


--------------010408050106000307050103--

--------------ms020404070904090006010907
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

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
ZSBpbmZvcm1hdGlvbiwgc2VlIGh0dHA6Ly9pZ2MubmF0aW9uYWwuaW5yaWEuZnIvSU5SSUEt
UGx1cy8wHQYDVR0OBBYEFD+CnY/KyRES90CCG8DhJB8NbU12MFUGA1UdIwROMEyAFJHAF8Y6
2la4MgATiUt86phKUBRWoTGkLzAtMQswCQYDVQQGEwJGUjEOMAwGA1UEChMFSU5SSUExDjAM
BgNVBAMTBUlOUklBggEAMFcGA1UdHwRQME4wTKBKoEiGRmh0dHA6Ly9pZ2MubmF0aW9uYWwu
aW5yaWEuZnIvY2dpLWJpbi9sb2FkLmNybD9DQT1JTlJJQS1QbHVzJmZvcm1hdD1ERVIwDQYJ
KoZIhvcNAQEFBQADggEBAGH29zuA2RJK2k2uRm2q1zvk1qYABAsElHUoeeNZVux4GLnKR+Zc
o/ZAzxhZGzdx57esdyIAY032g2m5PZmnjSV1WH37eA0bBn6khFiMSuAhvHFoHqTxGyzysrke
TuC9nFjtImPfc24pGiTg7AOdHnFePq24C2uoTS7j89nTCaWcNpXSp1lu4B2P59hsE57c5tKR
u095sPVDbqrDHQeojlPyBRq7iJORbQWhnY0rYNMR0D+iYmXANleD3OxDnudoEmJgKL2T6Epp
dyhqhpLoxdpknogcYH8dSEacYq4w3VjIIEPKLaiWDqIQHSEoS7b7z2XdiFVGuuGejYOHcM7P
3bgwggSRMIIDeaADAgECAgFGMA0GCSqGSIb3DQEBBQUAMDIxCzAJBgNVBAYTAkZSMQ4wDAYD
VQQKEwVJTlJJQTETMBEGA1UEAxMKSU5SSUEtUGx1czAeFw0wOTEyMDcxMDI2MzhaFw0xMDEy
MDcxMDI2MzhaMHMxCzAJBgNVBAYTAkZSMQ4wDAYDVQQKEwVJTlJJQTEPMA0GA1UECxMGU2Fj
bGF5MRkwFwYDVQQDExBHdWlsbGF1bWUgUm91c3NlMSgwJgYJKoZIhvcNAQkBFhlHdWlsbGF1
bWUuUm91c3NlQGlucmlhLmZyMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA6BzO
Sg9EJzwAN2h4UvpoPzyFjQQihljeipMOm+2n2QpscCrgZ7JPXLP8W6hWTIhaICsuoLPHsGi2
1Q8xsHSpv3pa0CbeTjXZwYHkHxdO+GZViiUHI6qmzZ92JlKZ58X9evjf8/XBAMPAuKQhIX0o
6UQmsgUS4sA4WF13t2FN67i+bKBebDxj8b2pkWXlwqiVNJSEws8akdWeARKbzuA+Npzr+gmK
YAz9UVHGSTbKmL35TuNwb6tMXeQ/0yDLVqNHSOmLClb3bBNYth+qDTw1t4DWGPEmEBl91duI
dynUwrP5L01azCwbwUzSFSmdscqdXvr6lyiDHfnLaa39Bk1ncwIDAQABo4IBbzCCAWswDAYD
VR0TAQH/BAIwADARBglghkgBhvhCAQEEBAMCBLAwDgYDVR0PAQH/BAQDAgXgMGkGCWCGSAGG
+EIBDQRcFlpDZXJ0aWZpY2F0ZSBJTlJJQS1QbHVzLiBGb3IgbW9yZSBpbmZvcm1hdGlvbiwg
c2VlIGh0dHA6Ly9pZ2MubmF0aW9uYWwuaW5yaWEuZnIvSU5SSUEtUGx1cy8wHQYDVR0OBBYE
FD+CnY/KyRES90CCG8DhJB8NbU12MFUGA1UdIwROMEyAFJHAF8Y62la4MgATiUt86phKUBRW
oTGkLzAtMQswCQYDVQQGEwJGUjEOMAwGA1UEChMFSU5SSUExDjAMBgNVBAMTBUlOUklBggEA
MFcGA1UdHwRQME4wTKBKoEiGRmh0dHA6Ly9pZ2MubmF0aW9uYWwuaW5yaWEuZnIvY2dpLWJp
bi9sb2FkLmNybD9DQT1JTlJJQS1QbHVzJmZvcm1hdD1ERVIwDQYJKoZIhvcNAQEFBQADggEB
AGH29zuA2RJK2k2uRm2q1zvk1qYABAsElHUoeeNZVux4GLnKR+Zco/ZAzxhZGzdx57esdyIA
Y032g2m5PZmnjSV1WH37eA0bBn6khFiMSuAhvHFoHqTxGyzysrkeTuC9nFjtImPfc24pGiTg
7AOdHnFePq24C2uoTS7j89nTCaWcNpXSp1lu4B2P59hsE57c5tKRu095sPVDbqrDHQeojlPy
BRq7iJORbQWhnY0rYNMR0D+iYmXANleD3OxDnudoEmJgKL2T6EppdyhqhpLoxdpknogcYH8d
SEacYq4w3VjIIEPKLaiWDqIQHSEoS7b7z2XdiFVGuuGejYOHcM7P3bgxggKyMIICrgIBATA3
MDIxCzAJBgNVBAYTAkZSMQ4wDAYDVQQKEwVJTlJJQTETMBEGA1UEAxMKSU5SSUEtUGx1cwIB
RjAJBgUrDgMCGgUAoIIBUDAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJ
BTEPFw0xMDA4MTQxNDUzMzhaMCMGCSqGSIb3DQEJBDEWBBQH7rYFKGXiX1AUV7QPumy7vauk
pjBGBgkrBgEEAYI3EAQxOTA3MDIxCzAJBgNVBAYTAkZSMQ4wDAYDVQQKEwVJTlJJQTETMBEG
A1UEAxMKSU5SSUEtUGx1cwIBRjBIBgsqhkiG9w0BCRACCzE5oDcwMjELMAkGA1UEBhMCRlIx
DjAMBgNVBAoTBUlOUklBMRMwEQYDVQQDEwpJTlJJQS1QbHVzAgFGMF8GCSqGSIb3DQEJDzFS
MFAwCwYJYIZIAWUDBAECMAoGCCqGSIb3DQMHMA4GCCqGSIb3DQMCAgIAgDANBggqhkiG9w0D
AgIBQDAHBgUrDgMCBzANBggqhkiG9w0DAgIBKDANBgkqhkiG9w0BAQEFAASCAQCKUSBJNqCI
DOhIksmuXKo96iUJYaygj4G4nG2So7+Hi3W5uIL3sQqk9d8jGZQFC1yuTucma6A1W/tm+xb9
PtUXG2XSjWiCTcXQsu6KrlHuA0mX6hM1FVvd7LW2ami9ut+qgeODLPEdvFt9N2sGRu0xXakT
ijmnoHwXIMuyaZd0POfgK8svQwxb5YcHnxnp8CITazOtz3E5VB8OckzpaD6IKA7hamvUqldc
v4wbyhd+2apwsAZEM6Vzq/62PjPP05Dxk1yFTp7BxizNXQNN8bPwlMtvY8v+qKOupgZmXCN8
Lj09ql6nsFOVWOzqkG+i2BPNp7DE7FOAwLP7UHeWf1eIAAAAAAAA

--------------ms020404070904090006010907--
