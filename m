From: Thanos Chatziathanassiou <tchatzi-nz9JlX+3IF8@public.gmane.org>
Subject: Re: kernel 2.6 and simulated flock() with posix locks
Date: Mon, 25 Feb 2008 18:42:35 +0200
Message-ID: <47C2EFFB.40807@arx.net>
References: <47C2C09D.2010203@arx.net> <20080225163802.GB10402@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/x-pkcs7-signature"; micalg=sha1; boundary="------------ms040000010904050203020500"
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from lvs-director.arx.gr ([193.239.214.236]:51445 "EHLO
	lvs-director.arx.gr" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754180AbYBYQno (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Feb 2008 11:43:44 -0500
In-Reply-To: <20080225163802.GB10402@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a cryptographically signed message in MIME format.

--------------ms040000010904050203020500
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

J. Bruce Fields wrote:
> On Mon, Feb 25, 2008 at 03:20:29PM +0200, Thanos Chatziathanassiou wrote:
>   
>> Hi,
>>
>> I've been trying to replace kernel 2.4 in a web server mounting its Document Root via NFS with kernel 2.6 and faced a rather disturbing problem.
>> About 1/2 hour after starting, the server would stop serving requests though it seemed fine.
>> Earlier 2.6 kernels exhibited the ``do_vfs_lock: VFS is out of sync with lock manager!'' symptom, later (when this was changed to a dprintk()) just sat there.
>> No apparent error apart from apache compaining ``[error] server reached MaxClients setting, consider raising the MaxClients setting'', unable to serve any requests.
>>
>> This issue does not surface under 2.4, where everything works as expected.
>> I came across this 
>> (http://blog.notreally.org/articles/2007/12/19/modifying-a-live-linux-kernel/) 
>> where apparently they faced the same problem, but their solution (which 
>> seemed a little crude) resulted in apache spitting ``There are no 
>> available locks'' messages (or roughly this, translated from my regional 
>> settings).
>>
>> Is there any solution to this or a way to get 2.4 behavior under 2.6 ?
>>     
>
> I'm a little confused--how do you know that the problem you face is the
> same as the one described on the blog above?  Are you re-exporting NFS
> via Samba?
>
> --b.
>   
Indeed I am. But I am willing to convince you ;) What kind of debug info 
would I need to collect to find out what really the problem is ?


--------------ms040000010904050203020500
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
Fw0wODAyMjUxNjQyMzVaMCMGCSqGSIb3DQEJBDEWBBRmD+RZgxnkZDZaM9cRQEmkalgXQDBS
BgkqhkiG9w0BCQ8xRTBDMAoGCCqGSIb3DQMHMA4GCCqGSIb3DQMCAgIAgDANBggqhkiG9w0D
AgIBQDAHBgUrDgMCBzANBggqhkiG9w0DAgIBKDCBhQYJKwYBBAGCNxAEMXgwdjBiMQswCQYD
VQQGEwJaQTElMCMGA1UEChMcVGhhd3RlIENvbnN1bHRpbmcgKFB0eSkgTHRkLjEsMCoGA1UE
AxMjVGhhd3RlIFBlcnNvbmFsIEZyZWVtYWlsIElzc3VpbmcgQ0ECEGl/+Sp8Ij9PO61AOtSD
7lcwgYcGCyqGSIb3DQEJEAILMXigdjBiMQswCQYDVQQGEwJaQTElMCMGA1UEChMcVGhhd3Rl
IENvbnN1bHRpbmcgKFB0eSkgTHRkLjEsMCoGA1UEAxMjVGhhd3RlIFBlcnNvbmFsIEZyZWVt
YWlsIElzc3VpbmcgQ0ECEGl/+Sp8Ij9PO61AOtSD7lcwDQYJKoZIhvcNAQEBBQAEggEApcDJ
EUebi9vDL/iApK40zXYfRlNESiRYQVkfSeDW1IiozVxlCabdSJrpBYZpapIOGEH9mxM3uqlA
qM4I8YDHTonB1G80PBFzsle1H75Wli+zpxZADye9KCsQHAJHE2oiWT+k1Kl3AYZ0bMpLm6/Q
4NyYByUIBiJR4tsE/F/qt3R+E3NxEaC5CW848ijXMxiKqnFziL+i/WuQIh/rjQRhUZvLg1M1
yxp9pfnlcTcSb500nFNGanq9htpp00ZkT4zpOglysHFKlMZiQLoBJdK5J3fIFmEBMgbg80eA
/8xCSA+d07YpKma14kAZzsGTqs/n/suU2M3t7O2gIdcgVLZ5YAAAAAAAAA==
--------------ms040000010904050203020500--
