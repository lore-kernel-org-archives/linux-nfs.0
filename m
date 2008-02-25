From: Thanos Chatziathanassiou <tchatzi-nz9JlX+3IF8@public.gmane.org>
Subject: kernel 2.6 and simulated flock() with posix locks
Date: Mon, 25 Feb 2008 15:20:29 +0200
Message-ID: <47C2C09D.2010203@arx.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/x-pkcs7-signature"; micalg=sha1; boundary="------------ms090009040803010901030306"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from lvs-director.arx.gr ([193.239.214.236]:54976 "EHLO
	lvs-director.arx.gr" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751328AbYBYN1J (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Feb 2008 08:27:09 -0500
Received: from [192.168.100.11] (skevos.arx.gr [193.239.214.238] (may be forged))
	by lvs-director.arx.gr (8.9.3p3/8.9.3) with ESMTP id PAA04196
	for <linux-nfs@vger.kernel.org>; Mon, 25 Feb 2008 15:20:29 +0200
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a cryptographically signed message in MIME format.

--------------ms090009040803010901030306
Content-Type: text/plain; charset=ISO-8859-7; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

I've been trying to replace kernel 2.4 in a web server mounting its Document Root via NFS with kernel 2.6 and faced a rather disturbing problem.
About 1/2 hour after starting, the server would stop serving requests though it seemed fine.
Earlier 2.6 kernels exhibited the ``do_vfs_lock: VFS is out of sync with lock manager!'' symptom, later (when this was changed to a dprintk()) just sat there.
No apparent error apart from apache compaining ``[error] server reached MaxClients setting, consider raising the MaxClients setting'', unable to serve any requests.

This issue does not surface under 2.4, where everything works as expected.
I came across this (http://blog.notreally.org/articles/2007/12/19/modifying-a-live-linux-kernel/) where apparently they faced the same problem, but their solution 
(which seemed a little crude) resulted in apache spitting ``There are no available locks'' messages (or roughly this, translated from my regional settings).

Is there any solution to this or a way to get 2.4 behavior under 2.6 ?

Best Regards,
Thanos Chatziathanassiou



--------------ms090009040803010901030306
Content-Type: application/x-pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIII+zCC
AtgwggJBoAMCAQICEGl/+Sp8Ij9PO61AOtSD7lcwDQYJKoZIhvcNAQEFBQAwYjELMAkGA1UE
BhMCWkExJTAjBgNVBAoTHFRoYXd0ZSBDb25zdWx0aW5nIChQdHkpIEx0ZC4xLDAqBgNVBAMT
I1RoYXd0ZSBQZXJzb25hbCBGcmVlbWFpbCBJc3N1aW5nIENBMB4XDTA3MDMwMTE4MTM0NVoX
DTA4MDIyOTE4MTM0NVowQTEfMB0GA1UEAxMWVGhhd3RlIEZyZWVtYWlsIE1lbWJlcjEeMBwG
CSqGSIb3DQEJARYPdGNoYXR6aUBhcngubmV0MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIB
CgKCAQEAtqQ460HHxv/KAYuEJ5DlIKfYDlhZxTPyxEWSY7jY6HF/uJU1w9QMgYby5BpncGNu
6wS3x6UUxysN8qGcWvGiN90jGf3QIOzA6rzGNzL2lQg2pxuLLm8E7LT9pXM28I3ClcOn7qQ/
ydlJoaTmk8Zjbe5h0SoXNDDf1vk8hizHlZBFlpl7hsHZ9qLjOkTMGnVCstuog67BFUyQ/m3G
h87y7mzboU63m1hjEewx5xJXRvlq/kZ/zxu4MBS/kWPsBkTCCi0QmeMMin0xI/TzTZ7CiC0c
/dLMldv+Aq5tHkWtKH0qDZ+BkdSn0QXpZhNTjHwCQW7KYdnP++qj9TosmklbjQIDAQABoyww
KjAaBgNVHREEEzARgQ90Y2hhdHppQGFyeC5uZXQwDAYDVR0TAQH/BAIwADANBgkqhkiG9w0B
AQUFAAOBgQA5rpSXFBEM9BzS+Fv2p5Gy1ocxBkDj33x+JhIPlrEaMwlQ3HeG0xxNeCJnZ+OB
JLtIMYf+OSG165+NU3vKpVGcpy4nZtTymb4oaBEhW3XpIPOnzkuxToFutIPZG7RUGfWGLmms
oEPmZXcR2q8fvCRwHrZAfaGZgWQ52gbCwzafsTCCAtgwggJBoAMCAQICEGl/+Sp8Ij9PO61A
OtSD7lcwDQYJKoZIhvcNAQEFBQAwYjELMAkGA1UEBhMCWkExJTAjBgNVBAoTHFRoYXd0ZSBD
b25zdWx0aW5nIChQdHkpIEx0ZC4xLDAqBgNVBAMTI1RoYXd0ZSBQZXJzb25hbCBGcmVlbWFp
bCBJc3N1aW5nIENBMB4XDTA3MDMwMTE4MTM0NVoXDTA4MDIyOTE4MTM0NVowQTEfMB0GA1UE
AxMWVGhhd3RlIEZyZWVtYWlsIE1lbWJlcjEeMBwGCSqGSIb3DQEJARYPdGNoYXR6aUBhcngu
bmV0MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAtqQ460HHxv/KAYuEJ5DlIKfY
DlhZxTPyxEWSY7jY6HF/uJU1w9QMgYby5BpncGNu6wS3x6UUxysN8qGcWvGiN90jGf3QIOzA
6rzGNzL2lQg2pxuLLm8E7LT9pXM28I3ClcOn7qQ/ydlJoaTmk8Zjbe5h0SoXNDDf1vk8hizH
lZBFlpl7hsHZ9qLjOkTMGnVCstuog67BFUyQ/m3Gh87y7mzboU63m1hjEewx5xJXRvlq/kZ/
zxu4MBS/kWPsBkTCCi0QmeMMin0xI/TzTZ7CiC0c/dLMldv+Aq5tHkWtKH0qDZ+BkdSn0QXp
ZhNTjHwCQW7KYdnP++qj9TosmklbjQIDAQABoywwKjAaBgNVHREEEzARgQ90Y2hhdHppQGFy
eC5uZXQwDAYDVR0TAQH/BAIwADANBgkqhkiG9w0BAQUFAAOBgQA5rpSXFBEM9BzS+Fv2p5Gy
1ocxBkDj33x+JhIPlrEaMwlQ3HeG0xxNeCJnZ+OBJLtIMYf+OSG165+NU3vKpVGcpy4nZtTy
mb4oaBEhW3XpIPOnzkuxToFutIPZG7RUGfWGLmmsoEPmZXcR2q8fvCRwHrZAfaGZgWQ52gbC
wzafsTCCAz8wggKooAMCAQICAQ0wDQYJKoZIhvcNAQEFBQAwgdExCzAJBgNVBAYTAlpBMRUw
EwYDVQQIEwxXZXN0ZXJuIENhcGUxEjAQBgNVBAcTCUNhcGUgVG93bjEaMBgGA1UEChMRVGhh
d3RlIENvbnN1bHRpbmcxKDAmBgNVBAsTH0NlcnRpZmljYXRpb24gU2VydmljZXMgRGl2aXNp
b24xJDAiBgNVBAMTG1RoYXd0ZSBQZXJzb25hbCBGcmVlbWFpbCBDQTErMCkGCSqGSIb3DQEJ
ARYccGVyc29uYWwtZnJlZW1haWxAdGhhd3RlLmNvbTAeFw0wMzA3MTcwMDAwMDBaFw0xMzA3
MTYyMzU5NTlaMGIxCzAJBgNVBAYTAlpBMSUwIwYDVQQKExxUaGF3dGUgQ29uc3VsdGluZyAo
UHR5KSBMdGQuMSwwKgYDVQQDEyNUaGF3dGUgUGVyc29uYWwgRnJlZW1haWwgSXNzdWluZyBD
QTCBnzANBgkqhkiG9w0BAQEFAAOBjQAwgYkCgYEAxKY8VXNV+065yplaHmjAdQRwnd/p/6Me
7L3N9VvyGna9fww6YfK/Uc4B1OVQCjDXAmNaLIkVcI7dyfArhVqqP3FWy688Cwfn8R+RNiQq
E88r1fOCdz0Dviv+uxg+B79AgAJk16emu59l0cUqVIUPSAR/p7bRPGEEQB5kGXJgt/sCAwEA
AaOBlDCBkTASBgNVHRMBAf8ECDAGAQH/AgEAMEMGA1UdHwQ8MDowOKA2oDSGMmh0dHA6Ly9j
cmwudGhhd3RlLmNvbS9UaGF3dGVQZXJzb25hbEZyZWVtYWlsQ0EuY3JsMAsGA1UdDwQEAwIB
BjApBgNVHREEIjAgpB4wHDEaMBgGA1UEAxMRUHJpdmF0ZUxhYmVsMi0xMzgwDQYJKoZIhvcN
AQEFBQADgYEASIzRUIPqCy7MDaNmrGcPf6+svsIXoUOWlJ1/TCG4+DYfqi2fNi/A9BxQIJNw
PP2t4WFiw9k6GX6EsZkbAMUaC4J0niVQlGLH2ydxVyWN3amcOY6MIE9lX5Xa9/eH1sYITq72
6jTlEBpbNU1341YheILcIRk13iSx0x1G/11fZU8xggNkMIIDYAIBATB2MGIxCzAJBgNVBAYT
AlpBMSUwIwYDVQQKExxUaGF3dGUgQ29uc3VsdGluZyAoUHR5KSBMdGQuMSwwKgYDVQQDEyNU
aGF3dGUgUGVyc29uYWwgRnJlZW1haWwgSXNzdWluZyBDQQIQaX/5KnwiP087rUA61IPuVzAJ
BgUrDgMCGgUAoIIBwzAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEP
Fw0wODAyMjUxMzIwMjlaMCMGCSqGSIb3DQEJBDEWBBQLSoAz3FqGQFpFAgvfs1ud9onQ4jBS
BgkqhkiG9w0BCQ8xRTBDMAoGCCqGSIb3DQMHMA4GCCqGSIb3DQMCAgIAgDANBggqhkiG9w0D
AgIBQDAHBgUrDgMCBzANBggqhkiG9w0DAgIBKDCBhQYJKwYBBAGCNxAEMXgwdjBiMQswCQYD
VQQGEwJaQTElMCMGA1UEChMcVGhhd3RlIENvbnN1bHRpbmcgKFB0eSkgTHRkLjEsMCoGA1UE
AxMjVGhhd3RlIFBlcnNvbmFsIEZyZWVtYWlsIElzc3VpbmcgQ0ECEGl/+Sp8Ij9PO61AOtSD
7lcwgYcGCyqGSIb3DQEJEAILMXigdjBiMQswCQYDVQQGEwJaQTElMCMGA1UEChMcVGhhd3Rl
IENvbnN1bHRpbmcgKFB0eSkgTHRkLjEsMCoGA1UEAxMjVGhhd3RlIFBlcnNvbmFsIEZyZWVt
YWlsIElzc3VpbmcgQ0ECEGl/+Sp8Ij9PO61AOtSD7lcwDQYJKoZIhvcNAQEBBQAEggEAQ1hE
tAASGtReCcCesKWXG7bX3z2p/e22IAXmKE8vsMmTQtsgX9/e6m/d2CAOoc3Kh1m+E6b2/tgI
wEvDLYZIcJxaiq/pY3ZiaXYLP2JHAtc/kZ7jajEH4BxIT5XjgyHjnS76xmvYNHJdO9i1YibV
pzfAxymfxEVcV1oNz18IGgAOYgQIcryPt3M1a5CsUysjjvWAO6dfBuy9G1c68wP0DZ+gqqZF
CJSURQY0nlOGKkkVpS2sKa1hXtkDWKj0RBHGjZVYtG2vmDzjKm363dAqU4prccf+CmYcTlDl
wO0uOlKSaAEOmgugLG1zO1+UioCcC0tyP6XZtoTAnMcFyKylSwAAAAAAAA==
--------------ms090009040803010901030306--
