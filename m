From: Stephan =?iso-8859-1?Q?Windm=FCller?=
	<stephan.windmueller-ogaGWlaKng3jEoi5djuKH7NAH6kLmebB@public.gmane.org>
Subject: Device or resource busy
Date: Mon, 27 Oct 2008 14:10:34 +0100
Message-ID: <20081027131034.GC25001@speutel.de>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/x-pkcs7-signature";
	micalg=sha1; boundary="qjNfmADvan18RZcF"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from speutel.de ([213.239.215.137]:50690 "EHLO speutel.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751116AbYJ0NrG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Oct 2008 09:47:06 -0400
Received: from windy by speutel.de with local (Exim 4.63)
	(envelope-from <stephan.windmueller-ogaGWlaKng3jEoi5djuKH7NAH6kLmebB@public.gmane.org>)
	id 1KuRre-0001f8-DV
	for linux-nfs@vger.kernel.org; Mon, 27 Oct 2008 14:10:34 +0100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--qjNfmADvan18RZcF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hello!

On our Ubuntu (8.04) machine we mount home directories from a Solaris
server with NFS and autofs. From time to time users complain that they
are unable to delete any directories. The error message is "Device or
resource busy".

When I look with "nfsstat -m", I can see a lot of mount points for each
user, including the directory which cannot be deleted. One user had a
total of 200 mounts!

My question is: Why does NFS mount each directory seperately?

Here is an example output for a user:

/ldaphome/username from host:/export/username
 Flags: rw,vers=3,rsize=1048576,wsize=1048576,hard,intr,
 proto=tcp,timeo=600,retrans=2,sec=sys,addr=host

TIA
 Stephan

--qjNfmADvan18RZcF
Content-Type: application/x-pkcs7-signature
Content-Disposition: attachment; filename="smime.p7s"
Content-Transfer-Encoding: base64

MIIJDQYJKoZIhvcNAQcCoIII/jCCCPoCAQExCzAJBgUrDgMCGgUAMAsGCSqGSIb3DQEHAaCC
BoQwggM9MIICpqADAgECAhBIcQ0ZGB7TPPXezMGKDaQFMA0GCSqGSIb3DQEBBQUAMGIxCzAJ
BgNVBAYTAlpBMSUwIwYDVQQKExxUaGF3dGUgQ29uc3VsdGluZyAoUHR5KSBMdGQuMSwwKgYD
VQQDEyNUaGF3dGUgUGVyc29uYWwgRnJlZW1haWwgSXNzdWluZyBDQTAeFw0wODA5MDkxNzIx
MzlaFw0wOTA5MDkxNzIxMzlaMHsxHzAdBgNVBAMTFlRoYXd0ZSBGcmVlbWFpbCBNZW1iZXIx
IjAgBgkqhkiG9w0BCQEWE3dpbmR5QHdoaXRlLWhhd2suZGUxNDAyBgkqhkiG9w0BCQEWJXN0
ZXBoYW4ud2luZG11ZWxsZXJAY3MudHUtZG9ydG11bmQuZGUwggEiMA0GCSqGSIb3DQEBAQUA
A4IBDwAwggEKAoIBAQDCCn3lTSbxo/3P9UyvE2rxJELiZksbNk4AlVYvqNmU6Sg1gDrPrd72
muoKPWqsYQs7qauOX0F5ee5znYx8EJv/iPAHnC+U8ZQx/LvsHZuw4JkpRtqB5D/84Snq1WRW
QA4xhWtn7hiQsDCBeZIMGfTGI91r96+V1sBYnfm/Px7VTQ0Ur4+lxIK2SGA5De3VETsS4aw9
wORYTgD4vpXs1JfmuNvlpKHAZhps9DnyF9qRW7Of/wh7WAOgxUDoK1YUnYFOHEAJb4eHVdcN
m+TB17dmKdqVoqyUv1kQJTzaAmHeD3uBzXgZdU6sAeinlABb3j0TNXIkwhFloTOxoin0az1N
AgMBAAGjVzBVMEUGA1UdEQQ+MDyBE3dpbmR5QHdoaXRlLWhhd2suZGWBJXN0ZXBoYW4ud2lu
ZG11ZWxsZXJAY3MudHUtZG9ydG11bmQuZGUwDAYDVR0TAQH/BAIwADANBgkqhkiG9w0BAQUF
AAOBgQAn1zmnTyZUhXAw73M24I9+VnCN3jpbA2BDScktFDLRxwilNJXR3KKuPHciVoYvFYIG
Jr7u2/Q3d9uYg8La0fOC6MIyIrmaFEGRCVFMEvTt5Ru36miJlIb40pNZPJWeWb+eNCj3mQtv
rHDHxbcmRe8mI6icVCMwnUqa5kVi9HIvzzCCAz8wggKooAMCAQICAQ0wDQYJKoZIhvcNAQEF
BQAwgdExCzAJBgNVBAYTAlpBMRUwEwYDVQQIEwxXZXN0ZXJuIENhcGUxEjAQBgNVBAcTCUNh
cGUgVG93bjEaMBgGA1UEChMRVGhhd3RlIENvbnN1bHRpbmcxKDAmBgNVBAsTH0NlcnRpZmlj
YXRpb24gU2VydmljZXMgRGl2aXNpb24xJDAiBgNVBAMTG1RoYXd0ZSBQZXJzb25hbCBGcmVl
bWFpbCBDQTErMCkGCSqGSIb3DQEJARYccGVyc29uYWwtZnJlZW1haWxAdGhhd3RlLmNvbTAe
Fw0wMzA3MTcwMDAwMDBaFw0xMzA3MTYyMzU5NTlaMGIxCzAJBgNVBAYTAlpBMSUwIwYDVQQK
ExxUaGF3dGUgQ29uc3VsdGluZyAoUHR5KSBMdGQuMSwwKgYDVQQDEyNUaGF3dGUgUGVyc29u
YWwgRnJlZW1haWwgSXNzdWluZyBDQTCBnzANBgkqhkiG9w0BAQEFAAOBjQAwgYkCgYEAxKY8
VXNV+065yplaHmjAdQRwnd/p/6Me7L3N9VvyGna9fww6YfK/Uc4B1OVQCjDXAmNaLIkVcI7d
yfArhVqqP3FWy688Cwfn8R+RNiQqE88r1fOCdz0Dviv+uxg+B79AgAJk16emu59l0cUqVIUP
SAR/p7bRPGEEQB5kGXJgt/sCAwEAAaOBlDCBkTASBgNVHRMBAf8ECDAGAQH/AgEAMEMGA1Ud
HwQ8MDowOKA2oDSGMmh0dHA6Ly9jcmwudGhhd3RlLmNvbS9UaGF3dGVQZXJzb25hbEZyZWVt
YWlsQ0EuY3JsMAsGA1UdDwQEAwIBBjApBgNVHREEIjAgpB4wHDEaMBgGA1UEAxMRUHJpdmF0
ZUxhYmVsMi0xMzgwDQYJKoZIhvcNAQEFBQADgYEASIzRUIPqCy7MDaNmrGcPf6+svsIXoUOW
lJ1/TCG4+DYfqi2fNi/A9BxQIJNwPP2t4WFiw9k6GX6EsZkbAMUaC4J0niVQlGLH2ydxVyWN
3amcOY6MIE9lX5Xa9/eH1sYITq726jTlEBpbNU1341YheILcIRk13iSx0x1G/11fZU8xggJR
MIICTQIBATB2MGIxCzAJBgNVBAYTAlpBMSUwIwYDVQQKExxUaGF3dGUgQ29uc3VsdGluZyAo
UHR5KSBMdGQuMSwwKgYDVQQDEyNUaGF3dGUgUGVyc29uYWwgRnJlZW1haWwgSXNzdWluZyBD
QQIQSHENGRge0zz13szBig2kBTAJBgUrDgMCGgUAoIGxMBgGCSqGSIb3DQEJAzELBgkqhkiG
9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTA4MTAyNzEzMTAzNFowIwYJKoZIhvcNAQkEMRYEFI9a
EtHG3lHqm3U3ACW5bOli4JTwMFIGCSqGSIb3DQEJDzFFMEMwCgYIKoZIhvcNAwcwDgYIKoZI
hvcNAwICAgCAMA0GCCqGSIb3DQMCAgFAMAcGBSsOAwIHMA0GCCqGSIb3DQMCAgEoMA0GCSqG
SIb3DQEBAQUABIIBAF+AlCYzm9j3E8JY67+El7plQ2HWIemZQk16Lk7YfGN6mxhT9Zx2zlLx
2e+xHp4AONn6mVgw6cDDBkiOXVfr3CLEG+u7XZv64piCyE0r3eRwmld6MyqN9Iqb9rRm1zTX
Vbq7kXfatLgbF3kWumonxsfMxEH9KQoVb1Zs/3YsNhfk1a0Rz8NUefOeUydthTxHDYuG577d
Dla0bYkDpUv3jsOoDcpvBo2s1iHLigNwsFMaeQfA5iJYMLHMZstq4uVSKHArd7l9ZDkivISo
Qwq/8UPFqNbgmm7Eqw0ql6ZMPoijHoxWx7ROs5l1oKBnMYYhlzt7rabZM/rPJHY/LK4rMY0=

--qjNfmADvan18RZcF--
