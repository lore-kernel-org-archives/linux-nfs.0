Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail2-relais-roc.national.inria.fr ([192.134.164.83]:35139 "EHLO
	mail2-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752089Ab0H1Q61 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 28 Aug 2010 12:58:27 -0400
Message-ID: <4C79402F.7040204@inria.fr>
Date: Sat, 28 Aug 2010 18:58:23 +0200
From: Guillaume Rousse <Guillaume.Rousse@inria.fr>
CC: linux-nfs@vger.kernel.org
Subject: Re: [patch] fix description of nfsversion mount option
References: <4C66ADF2.9030700@inria.fr> <4C6B03DE.5040105@RedHat.com>
In-Reply-To: <4C6B03DE.5040105@RedHat.com>
Content-Type: multipart/signed; protocol="application/pkcs7-signature"; micalg=sha1; boundary="------------ms080602090006000100030806"
To: unlisted-recipients:; (no To-header on input)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--------------ms080602090006000100030806
Content-Type: multipart/mixed;
 boundary="------------020301020008050807070907"

This is a multi-part message in MIME format.
--------------020301020008050807070907
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Le 17/08/2010 23:49, Steve Dickson a =E9crit :
>=20
>=20
> On 08/14/2010 10:53 AM, Guillaume Rousse wrote:
>> Hello list.
>>
>> Here is a first patch trying to update a little bit nfs-utils
>> documentation. I'd like also to change the constant opposition of 'nfs=
'
>> vs 'nfs4' filesystems in this man page, but I have no clue if the plan=

>> is to remove 'nfs4' filesystem completly, or to keep for compatibility=

>> purpose. In the first case, I'd just remove any occurence of it in the=

>> man page, in the second case, I'm less sure about what to do.
> In the future please use the proper Signed-off-by: line in=20
> your patch... Its cool for this time, since the change is a=20
> minor one...=20
Here is a now one, dealing with protocol-specific versions. This time I
found how to add the signoff header in git documentation :)

BTW, I don't what what's the exact plan for the 'nfs4' filesystem type,
so I just mentionned it as an old syntax. And I also supposed than
protocol-specific versions would just get ignored when used with another
version, but I'm not sure at all.
--=20
BOFH excuse #375:

Root name servers corrupted.

--------------020301020008050807070907
Content-Type: text/plain;
 name="0001-Drop-reference-to-the-nfs4-filesystem-type-excepted-.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename*0="0001-Drop-reference-to-the-nfs4-filesystem-type-excepted-.pa";
 filename*1="tch"

=46rom 95f5f0e1a5e1edf7a34a03ee3fecd8908fa1ddad Mon Sep 17 00:00:00 2001
From: Guillaume Rousse <Guillaume.Rousse@inria.fr>
Date: Sat, 28 Aug 2010 18:50:43 +0200
Subject: [PATCH] Drop reference to the nfs4 filesystem type, excepted as =
an older
 syntax, and document options as specific to a protocol version
 rather than to a filesystem type.


Signed-off-by: Guillaume Rousse <Guillaume.Rousse@inria.fr>
---
 utils/mount/nfs.man |   50 ++++++++++++++++++++-------------------------=
-----
 1 files changed, 20 insertions(+), 30 deletions(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index 3806635..fe58015 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -3,8 +3,6 @@
 .SH NAME
 nfs \- fstab format and options for the
 .B nfs
-and
-.B nfs4
 file systems
 .SH SYNOPSIS
 .I /etc/fstab
@@ -71,14 +69,10 @@ for details on specifying raw IPv6 addresses.
 .P
 The
 .I fstype
-field contains either "nfs" (for version 2 or version 3 NFS mounts)
-or "nfs4" (for NFS version 4 mounts).
+field contains "nfs", for whatever version of the protocol.
 The
 .B nfs
-and
-.B nfs4
-file system types share similar mount options,
-which are described below.
+allow several mount options, which are described below.
 .SH "MOUNT OPTIONS"
 Refer to
 .BR mount (8)
@@ -89,14 +83,8 @@ specify any mount options, use the generic option
 in
 .IR /etc/fstab .
 .DT
-.SS "Valid options for either the nfs or nfs4 file system type"
-These options are valid to use when mounting either
-.B nfs
-or
-.B nfs4
-file system types.
-They imply the same behavior
-and have the same default for both file system types.
+.SS "Options supported by all versions"
+These options are valid to use with any NFS version.
 .TP 1.5i
 .BR soft " / " hard
 Determines the recovery behavior of the NFS client
@@ -476,11 +464,9 @@ by other clients, but can impact application and ser=
ver performance.
 .IP
 The DATA AND METADATA COHERENCE section contains a
 detailed discussion of these trade-offs.
-.SS "Valid options for the nfs file system type"
+.SS "Options for versions 2 and 3 only"
 Use these options, along with the options in the above subsection,
-for mounting the
-.B nfs
-file system type.
+for NFSv2/v3 only. They will be ignored for newer versions.
 .TP 1.5i
 .BI proto=3D netid
 The transport protocol name and protocol family the NFS client uses
@@ -722,11 +708,9 @@ If this option is not specified, the NFS client uses=
 READDIRPLUS requests
 on NFS version 3 mounts to read small directories.
 Some applications perform better if the client uses only READDIR request=
s
 for all directories.
-.SS "Valid options for the nfs4 file system type"
+.SS "Options for version 4 only"
 Use these options, along with the options in the first subsection above,=

-for mounting the
-.B nfs4
-file system type.
+for NFSv4 only. They will be ignored with older versions.
 .TP 1.5i
 .BI proto=3D netid
 The transport protocol name and protocol family the NFS client uses
@@ -823,6 +807,13 @@ In the presence of multiple client network interface=
s,
 special routing policies,
 or atypical network topologies,
 the exact address to use for callbacks may be nontrivial to determine.
+.SH nfs4 FILE SYSTEM TYPE
+The
+.BR nfs4
+file system type is an old syntax for specifying NFSv4 usage. It can sti=
ll=20
+be used with all NFSv4-specific and common options, excepted the
+.B nfsvers
+mount option.
 .SH MOUNT CONFIGURATION FILE
 If the mount command is configured to do so, all of the mount options=20
 described in the previous section can also be configured in the=20
@@ -844,12 +835,11 @@ file system type and specify the
 .B nfsvers=3D3
 mount option.
 To mount using NFS version 4,
-use the
-.B nfs4
-file system type.
-The
-.B nfsvers
-mount option is not supported for the
+use either the
+.B nfs
+file system type, with the
+.B nfsvers=3D4
+mount option, or the=20
 .B nfs4
 file system type.
 .P
--=20
1.7.2.2


--------------020301020008050807070907--

--------------ms080602090006000100030806
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
BTEPFw0xMDA4MjgxNjU4MjNaMCMGCSqGSIb3DQEJBDEWBBSn/wpU8NrQDOCXEBZk82LJyt5g
vzBGBgkrBgEEAYI3EAQxOTA3MDIxCzAJBgNVBAYTAkZSMQ4wDAYDVQQKEwVJTlJJQTETMBEG
A1UEAxMKSU5SSUEtUGx1cwIBRjBIBgsqhkiG9w0BCRACCzE5oDcwMjELMAkGA1UEBhMCRlIx
DjAMBgNVBAoTBUlOUklBMRMwEQYDVQQDEwpJTlJJQS1QbHVzAgFGMF8GCSqGSIb3DQEJDzFS
MFAwCwYJYIZIAWUDBAECMAoGCCqGSIb3DQMHMA4GCCqGSIb3DQMCAgIAgDANBggqhkiG9w0D
AgIBQDAHBgUrDgMCBzANBggqhkiG9w0DAgIBKDANBgkqhkiG9w0BAQEFAASCAQAf6j5p2SW6
mBMy2rZGHZZOKe7DAWfL2Wy+JWVr7zDZCLwVYv8dPw4zmC1kTprBMOdAjU9wQ2gQY8BPX54+
BGjMBaVnIFF3K0ibzfCV1NyOa79heBbfUYb7XqN2eMrUPCLUz51ge2SaqE9hGigHMe5W0ALA
Aqpaa/ssy54HEacpCcpy+0XG7iAy3aXnYQv1GbR54F3RVLnQNm6N1eGUKUr4bIzxRxP39r1X
cmKcWegv2mnPZITZYLr9unJPJwD4SNhA5EbWLxfs3fxaY8wSWoSQU6Lvuroh8QNDbX8tu0Ea
c9cfoqX0K9L2XIrCoO6uSD/THSMysC4aMxP99O7kVXhOAAAAAAAA

--------------ms080602090006000100030806--
