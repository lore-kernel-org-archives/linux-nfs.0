From: Stephan =?iso-8859-1?Q?Windm=FCller?=
	<stephan.windmueller-ogaGWlaKng3jEoi5djuKH7NAH6kLmebB@public.gmane.org>
Subject: Re: Device or resource busy
Date: Mon, 27 Oct 2008 15:29:44 +0100
Message-ID: <20081027142944.GD25001@speutel.de>
References: <20081027131034.GC25001@speutel.de> <1225116112.7842.3.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/x-pkcs7-signature";
	micalg=sha1; boundary="Km1U/tdNT/EmXiR1"
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from speutel.de ([213.239.215.137]:54758 "EHLO speutel.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751099AbYJ0O3t (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Oct 2008 10:29:49 -0400
In-Reply-To: <1225116112.7842.3.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--Km1U/tdNT/EmXiR1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, 27. Oct 2008, Trond Myklebust wrote:

> > When I look with "nfsstat -m", I can see a lot of mount points for each
> > user, including the directory which cannot be deleted. One user had a
> > total of 200 mounts!
> If /export/username is on a different volume from /export on the server,
> then the NFS client has to mount it as being a different volume on the
> client. 'cat /proc/fs/nfsfs/volumes' should be able to tell you if your
> server is exporting more than one volume.

/export and /export/home/username are different volumes, but I only
share /export/home/username. Also it is not only the homedirectory
itself but many subdirectories which cause this error. A sample output
=66rom 'nfsstat -m':

-----

/home/username from fileserver:/export/home/username
 Flags: rw,vers=3D3,rsize=3D1048576,wsize=3D1048576,hard,intr,proto=3Dtcp,t=
imeo=3D600,retrans=3D2,sec=3Dsys,addr=3Dfileserver

/home/username/workspace/ls5/da/text/Konzept from
fileserver:/export/home/username/workspace/ls5/da/text/Konzept
 Flags: rw,vers=3D3,rsize=3D1048576,wsize=3D1048576,hard,intr,proto=3Dtcp,t=
imeo=3D600,retrans=3D2,sec=3Dsys,addr=3Dfileserver

/home/username/.eclipse/org.eclipse.platform_3.3.0_1148896627 from
fileserver:/export/home/username/.eclipse/org.eclipse.platform_3.3.0_114889=
6627
 Flags: rw,vers=3D3,rsize=3D1048576,wsize=3D1048576,hard,intr,proto=3Dtcp,t=
imeo=3D600,retrans=3D2,sec=3Dsys,addr=3Dfileserver

[...]

-----

The output from /proc/fs/nfsfs/volumes looks like:

NV SERVER   PORT DEV     FSID
v3 81d91add  801 0:29    1000001009f:0
v3 81d91add  801 0:27    1000001010f:0
v3 81d91ade  801 0:30    100000100f1:0
v3 81d91add  801 0:31    1000001018b:0
v3 81d91add  801 0:26    10000010189:0
v3 81d91ade  801 0:28    100000100ef:0
v3 81d91ade  801 0:32    100000100f6:0
v3 81d91add  801 0:33    10000010192:0

- Stephan

--Km1U/tdNT/EmXiR1
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
9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTA4MTAyNzE0Mjk0NFowIwYJKoZIhvcNAQkEMRYEFDBf
tmGtFLEES9DwyB80NWa+VPAfMFIGCSqGSIb3DQEJDzFFMEMwCgYIKoZIhvcNAwcwDgYIKoZI
hvcNAwICAgCAMA0GCCqGSIb3DQMCAgFAMAcGBSsOAwIHMA0GCCqGSIb3DQMCAgEoMA0GCSqG
SIb3DQEBAQUABIIBAERfaFKjjdHkROS/9C+6qnU+wrbtAWlMmenFqpqYeVzBC0dIOJyWyqOC
k3rjVHAsQdg8ENlT6BOur4xuOSuV55POxEor++cadXjRr5ExwxV3FDCPR4DgzFyGN/k2pfFI
Rwkb5a9cvDvjjSzXMgcCt4X1p+y4avXo1lQFj6NaA+4f8+lqr/vFpQO8U8IecORCsz4yv20q
V0KddA2huYnoVY0wmjS9S4hHgY4oBFRM6FTLlfHi9ehfaIsQ+ODIACfFA28eyQdfmBbTpbBI
VwHjkMeWM9GBbgt3/b0fR+FiQRTPvft6LVgnXVvmI4foO5h4mz5GCuKnMOMNbjH3rWnuZzE=

--Km1U/tdNT/EmXiR1--
