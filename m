From: =?ISO-8859-1?Q?Mart=EDn_Alejandro_Carmona_Selva?= <mcarmona@3waysolutions.com>
Subject: NFS mount time problem
Date: Mon, 17 Jan 2005 19:04:12 -0300
Message-ID: <41EC365C.4090903@3waysolutions.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/x-pkcs7-signature"; micalg=sha1; boundary="------------ms010504080807030105050202"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cqeyz-0006yc-Qn
	for nfs@lists.sourceforge.net; Mon, 17 Jan 2005 14:04:21 -0800
Received: from [200.69.244.241] (helo=mx.3waysolutions.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1Cqeyy-0000rJ-3t
	for nfs@lists.sourceforge.net; Mon, 17 Jan 2005 14:04:21 -0800
Received: from [192.168.1.64] (unknown [192.168.1.64])
	by mx.3waysolutions.com (Postfix) with ESMTP id 17FDF282AB
	for <nfs@lists.sourceforge.net>; Mon, 17 Jan 2005 19:03:55 -0300 (ART)
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

This is a cryptographically signed message in MIME format.

--------------ms010504080807030105050202
Content-Type: multipart/alternative;
 boundary="------------050900060401050005030207"

This is a multi-part message in MIME format.
--------------050900060401050005030207
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

I have a linux NFS Server exporting a directory which has 8=20
sub-directories with some JPGs constantly changing and then, more=20
subdirs with lots of JPGs (it's a DVR).
The problem is that it takes AGES to mount -4 hours and still no mount=20
done- NFS from my machine to that server -on the same switch 100MBPS=20
FullDuplex-.

At first eartly today I think about all the JPGs on that sub directories =

and used the no-subtree-check option, but something must be wrong since=20
I can't get my MDK10 (kernel 2.6) to mount the dir on the MDK 8.2=20
(kernel 2.4.23)...
*
my /etc/exports* file goes like this:

#
/video1/camara1/ *(ro,async,no_subtree_check)
/video1/camara2/ *(ro,async,no_subtree_check)
/video1/camara3/ *(ro,async,no_subtree_check)
/video1/camara4/ *(ro,async,no_subtree_check)
/video1/camara5/ *(ro,async,no_subtree_check)
/video1/camara6/ *(ro,async,no_subtree_check)
/video1/camara7/ *(ro,async,no_subtree_check)
/video1/camara8/ *(ro,async,no_subtree_check)

And inside every camera dir (camara1..camara8) there's just one=20
camara.jpg (chaning constantly) and two directories (with a tree with=20
lots of JPG files).

Hope this would be enough for you to give me a hand, or, at least, tell=20
me where to look for a possible solution..

Thank you in advance,

Regards,

/m@cs

P.S.: YES, I'M A TOTAL NEWBIE. :(

--=20
Mart=EDn Alejandro Carmona Selva
mcarmona@3waysolutions.com
http://www.3waysolutions.com
Tel: (+54-11)-5217-3330
Fax: (+54-11)-4953-6319
----------------------------------
http://www.macs.com.ar
webmaster@photoart.com.ar
----------------------------------
Amare et sapere vix deo conceditur
----------------------------------


--------------050900060401050005030207
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <meta content="text/html;charset=ISO-8859-1" http-equiv="Content-Type">
  <title></title>
</head>
<body bgcolor="#ffffff" text="#000000">
I have a linux NFS Server exporting a directory which has 8
sub-directories with some JPGs constantly changing and then, more
subdirs with lots of JPGs (it's a DVR).<br>
The problem is that it takes AGES to mount -4 hours and still no mount
done- NFS from my machine to that server -on the same switch 100MBPS
FullDuplex-.<br>
<br>
At first eartly today I think about all the JPGs on that sub
directories and used the no-subtree-check option, but something must be
wrong since I can't get my MDK10 (kernel 2.6) to mount the dir on the
MDK 8.2 (kernel 2.4.23)...<br>
<b><br>
my /etc/exports</b> file goes like this:<br>
<br>
#<br>
/video1/camara1/ *(ro,async,no_subtree_check)<br>
/video1/camara2/ *(ro,async,no_subtree_check)<br>
/video1/camara3/ *(ro,async,no_subtree_check)<br>
/video1/camara4/ *(ro,async,no_subtree_check)<br>
/video1/camara5/ *(ro,async,no_subtree_check)<br>
/video1/camara6/ *(ro,async,no_subtree_check)<br>
/video1/camara7/ *(ro,async,no_subtree_check)<br>
/video1/camara8/ *(ro,async,no_subtree_check)<br>
<br>
And inside every camera dir (camara1..camara8) there's just one
camara.jpg (chaning constantly) and two directories (with a tree with
lots of JPG files).<br>
<br>
Hope this would be enough for you to give me a hand, or, at least, tell
me where to look for a possible solution..<br>
<br>
Thank you in advance,<br>
<br>
Regards,<br>
<br>
/m@cs<br>
<br>
P.S.: YES, I'M A TOTAL NEWBIE. :(<br>
<br>
<pre class="moz-signature" cols="72">-- 
Mart&iacute;n Alejandro Carmona Selva
<a class="moz-txt-link-abbreviated" href="mailto:mcarmona@3waysolutions.com">mcarmona@3waysolutions.com</a>
<a class="moz-txt-link-freetext" href="http://www.3waysolutions.com">http://www.3waysolutions.com</a>
Tel: (+54-11)-5217-3330
Fax: (+54-11)-4953-6319
----------------------------------
<a class="moz-txt-link-freetext" href="http://www.macs.com.ar">http://www.macs.com.ar</a>
<a class="moz-txt-link-abbreviated" href="mailto:webmaster@photoart.com.ar">webmaster@photoart.com.ar</a>
----------------------------------
Amare et sapere vix deo conceditur
----------------------------------</pre>
</body>
</html>

--------------050900060401050005030207--

--------------ms010504080807030105050202
Content-Type: application/x-pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIJDTCC
AuEwggJKoAMCAQICAw0lJzANBgkqhkiG9w0BAQQFADBiMQswCQYDVQQGEwJaQTElMCMGA1UE
ChMcVGhhd3RlIENvbnN1bHRpbmcgKFB0eSkgTHRkLjEsMCoGA1UEAxMjVGhhd3RlIFBlcnNv
bmFsIEZyZWVtYWlsIElzc3VpbmcgQ0EwHhcNMDQwOTMwMTc1OTQwWhcNMDUwOTMwMTc1OTQw
WjBMMR8wHQYDVQQDExZUaGF3dGUgRnJlZW1haWwgTWVtYmVyMSkwJwYJKoZIhvcNAQkBFhpt
Y2FybW9uYUAzd2F5c29sdXRpb25zLmNvbTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoC
ggEBAMggasz7aZJHUrXRWmhcm6xxUeLnkeMYeDV0+iGrEhSB4cL81Bwq5p4DZpqkyoL885Ez
NM653reYUix9t7FqsAYLeW4H6ylPUDXy1TB8zKUrPJHZV6aqTIo34XZzX1h9nLzcxPWcanP1
XVA0jxWLLsARoUlgHfP8/hRkI35laDrCmQ+4dX2Q4hc2gSZRLa/L9TWpQUbwGYXfksFLOP9K
pkVv+/ryRPAqFM+UxDGlOgFq06E0pcxKLEpiDbH0xquiInnGW+/SFH1EDUx+rjg8LbW9DavS
5dMnVPQgwcBUc5IGK3KyGkCOVuym1q/ipoShT9RU2eUncGVZJOX4R3kWkUkCAwEAAaM3MDUw
JQYDVR0RBB4wHIEabWNhcm1vbmFAM3dheXNvbHV0aW9ucy5jb20wDAYDVR0TAQH/BAIwADAN
BgkqhkiG9w0BAQQFAAOBgQB9CZaJRxkEgjSQsXWy9s7Az7X/wxllyP1b+UoQdRbfzI1LWd1I
U3PZybWdwgK6eDlpHZWiUVw5bEIugf2iM1D1kMXEmOINXhW5Xd/+JcX+rfRNWGhxf5l3bDWD
Q4GsHtwjkKoXn/gniZu3pQzAtB6NlDda4TGXLIV5+HoCFbr8EzCCAuEwggJKoAMCAQICAw0l
JzANBgkqhkiG9w0BAQQFADBiMQswCQYDVQQGEwJaQTElMCMGA1UEChMcVGhhd3RlIENvbnN1
bHRpbmcgKFB0eSkgTHRkLjEsMCoGA1UEAxMjVGhhd3RlIFBlcnNvbmFsIEZyZWVtYWlsIElz
c3VpbmcgQ0EwHhcNMDQwOTMwMTc1OTQwWhcNMDUwOTMwMTc1OTQwWjBMMR8wHQYDVQQDExZU
aGF3dGUgRnJlZW1haWwgTWVtYmVyMSkwJwYJKoZIhvcNAQkBFhptY2FybW9uYUAzd2F5c29s
dXRpb25zLmNvbTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAMggasz7aZJHUrXR
Wmhcm6xxUeLnkeMYeDV0+iGrEhSB4cL81Bwq5p4DZpqkyoL885EzNM653reYUix9t7FqsAYL
eW4H6ylPUDXy1TB8zKUrPJHZV6aqTIo34XZzX1h9nLzcxPWcanP1XVA0jxWLLsARoUlgHfP8
/hRkI35laDrCmQ+4dX2Q4hc2gSZRLa/L9TWpQUbwGYXfksFLOP9KpkVv+/ryRPAqFM+UxDGl
OgFq06E0pcxKLEpiDbH0xquiInnGW+/SFH1EDUx+rjg8LbW9DavS5dMnVPQgwcBUc5IGK3Ky
GkCOVuym1q/ipoShT9RU2eUncGVZJOX4R3kWkUkCAwEAAaM3MDUwJQYDVR0RBB4wHIEabWNh
cm1vbmFAM3dheXNvbHV0aW9ucy5jb20wDAYDVR0TAQH/BAIwADANBgkqhkiG9w0BAQQFAAOB
gQB9CZaJRxkEgjSQsXWy9s7Az7X/wxllyP1b+UoQdRbfzI1LWd1IU3PZybWdwgK6eDlpHZWi
UVw5bEIugf2iM1D1kMXEmOINXhW5Xd/+JcX+rfRNWGhxf5l3bDWDQ4GsHtwjkKoXn/gniZu3
pQzAtB6NlDda4TGXLIV5+HoCFbr8EzCCAz8wggKooAMCAQICAQ0wDQYJKoZIhvcNAQEFBQAw
gdExCzAJBgNVBAYTAlpBMRUwEwYDVQQIEwxXZXN0ZXJuIENhcGUxEjAQBgNVBAcTCUNhcGUg
VG93bjEaMBgGA1UEChMRVGhhd3RlIENvbnN1bHRpbmcxKDAmBgNVBAsTH0NlcnRpZmljYXRp
b24gU2VydmljZXMgRGl2aXNpb24xJDAiBgNVBAMTG1RoYXd0ZSBQZXJzb25hbCBGcmVlbWFp
bCBDQTErMCkGCSqGSIb3DQEJARYccGVyc29uYWwtZnJlZW1haWxAdGhhd3RlLmNvbTAeFw0w
MzA3MTcwMDAwMDBaFw0xMzA3MTYyMzU5NTlaMGIxCzAJBgNVBAYTAlpBMSUwIwYDVQQKExxU
aGF3dGUgQ29uc3VsdGluZyAoUHR5KSBMdGQuMSwwKgYDVQQDEyNUaGF3dGUgUGVyc29uYWwg
RnJlZW1haWwgSXNzdWluZyBDQTCBnzANBgkqhkiG9w0BAQEFAAOBjQAwgYkCgYEAxKY8VXNV
+065yplaHmjAdQRwnd/p/6Me7L3N9VvyGna9fww6YfK/Uc4B1OVQCjDXAmNaLIkVcI7dyfAr
hVqqP3FWy688Cwfn8R+RNiQqE88r1fOCdz0Dviv+uxg+B79AgAJk16emu59l0cUqVIUPSAR/
p7bRPGEEQB5kGXJgt/sCAwEAAaOBlDCBkTASBgNVHRMBAf8ECDAGAQH/AgEAMEMGA1UdHwQ8
MDowOKA2oDSGMmh0dHA6Ly9jcmwudGhhd3RlLmNvbS9UaGF3dGVQZXJzb25hbEZyZWVtYWls
Q0EuY3JsMAsGA1UdDwQEAwIBBjApBgNVHREEIjAgpB4wHDEaMBgGA1UEAxMRUHJpdmF0ZUxh
YmVsMi0xMzgwDQYJKoZIhvcNAQEFBQADgYEASIzRUIPqCy7MDaNmrGcPf6+svsIXoUOWlJ1/
TCG4+DYfqi2fNi/A9BxQIJNwPP2t4WFiw9k6GX6EsZkbAMUaC4J0niVQlGLH2ydxVyWN3amc
OY6MIE9lX5Xa9/eH1sYITq726jTlEBpbNU1341YheILcIRk13iSx0x1G/11fZU8xggM7MIID
NwIBATBpMGIxCzAJBgNVBAYTAlpBMSUwIwYDVQQKExxUaGF3dGUgQ29uc3VsdGluZyAoUHR5
KSBMdGQuMSwwKgYDVQQDEyNUaGF3dGUgUGVyc29uYWwgRnJlZW1haWwgSXNzdWluZyBDQQID
DSUnMAkGBSsOAwIaBQCgggGnMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcN
AQkFMQ8XDTA1MDExNzIyMDQxMlowIwYJKoZIhvcNAQkEMRYEFDR0IzFp7Jo2fd8H1ceJsnyF
Dya3MFIGCSqGSIb3DQEJDzFFMEMwCgYIKoZIhvcNAwcwDgYIKoZIhvcNAwICAgCAMA0GCCqG
SIb3DQMCAgFAMAcGBSsOAwIHMA0GCCqGSIb3DQMCAgEoMHgGCSsGAQQBgjcQBDFrMGkwYjEL
MAkGA1UEBhMCWkExJTAjBgNVBAoTHFRoYXd0ZSBDb25zdWx0aW5nIChQdHkpIEx0ZC4xLDAq
BgNVBAMTI1RoYXd0ZSBQZXJzb25hbCBGcmVlbWFpbCBJc3N1aW5nIENBAgMNJScwegYLKoZI
hvcNAQkQAgsxa6BpMGIxCzAJBgNVBAYTAlpBMSUwIwYDVQQKExxUaGF3dGUgQ29uc3VsdGlu
ZyAoUHR5KSBMdGQuMSwwKgYDVQQDEyNUaGF3dGUgUGVyc29uYWwgRnJlZW1haWwgSXNzdWlu
ZyBDQQIDDSUnMA0GCSqGSIb3DQEBAQUABIIBAEAzLLzcmRWjGZCYKdCOhOABxDsMEXN/nsQ/
HaW4pkaoqKU0l15GtlGM2QdMvGQI8ZZYx7pclT1hFB5V60dt4Pe3tgn5L2kneKrG1TUDzWqV
c2bWPMsXrTDEW2CFmzCNPpCUOglmqAhyDMVAbK8fLcdqRoePeqXS29S2gTLuXDD78QD/0SZv
rA7tO1unz5vm7RzjhNe7DfHHtBi1pwxt9N+w16KenxYIFtmB92DAoHhJUGhOe77d7Z0tIiUO
zUi4hZtscwHHsTPwzLlHYJxjYnw6XPNYYRFOG+q725NdRGEyfIv2rrOxrNkHaDmf2AIQXLdm
/JFtjDIUWHNWSo5WVlcAAAAAAAA=
--------------ms010504080807030105050202--


-------------------------------------------------------
The SF.Net email is sponsored by: Beat the post-holiday blues
Get a FREE limited edition SourceForge.net t-shirt from ThinkGeek.
It's fun and FREE -- well, almost....http://www.thinkgeek.com/sfshirt
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
