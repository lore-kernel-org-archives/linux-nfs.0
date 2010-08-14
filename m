Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail3-relais-sop.national.inria.fr ([192.134.164.104]:26420
	"EHLO mail3-relais-sop.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752229Ab0HNPLF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 14 Aug 2010 11:11:05 -0400
Message-ID: <4C66B207.5060101@inria.fr>
Date: Sat, 14 Aug 2010 17:11:03 +0200
From: Guillaume Rousse <Guillaume.Rousse@inria.fr>
To: Kevin Coffman <kwc@citi.umich.edu>
CC: linux-nfs@vger.kernel.org
Subject: Re: trouble using kerberos between linux client and server
References: <4BCFE979.2000406@inria.fr> <4BE1E099.9050902@inria.fr>	 <4BEB1FA2.1060001@inria.fr>	 <AANLkTinNTYrEe9G6urXBxv-hogZPatOe9zWbbjnVTbWz@mail.gmail.com>	 <4BEBC1B0.8030502@inria.fr> <AANLkTinPfbYgqFxcIuT3975TAtk0e1D84bMAeez5Z06T@mail.gmail.com> <4BEC6B6E.9090705@inria.fr>
In-Reply-To: <4BEC6B6E.9090705@inria.fr>
Content-Type: multipart/signed; protocol="application/pkcs7-signature"; micalg=sha1; boundary="------------ms060102060609060700050408"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--------------ms060102060609060700050408
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Le 13/05/2010 23:13, Guillaume Rousse a =C3=A9crit :
> Le 13/05/2010 14:55, Kevin Coffman a =C3=A9crit :
>> On Thu, May 13, 2010 at 5:09 AM, Guillaume Rousse
>> <Guillaume.Rousse@inria.fr> wrote:
>>> Le 13/05/2010 01:21, Kevin Coffman a =C3=A9crit :
>>>> On Wed, May 12, 2010 at 5:37 PM, Guillaume Rousse
>>>> <Guillaume.Rousse@inria.fr> wrote:
>>>>> Le 05/05/2010 23:18, Guillaume Rousse a =C3=A9crit :
>>>>>> I'm attaching network capture, even I can't figure additional
>>>>>> information from it by myself.
>>>>> Reading https://bugzilla.redhat.com/show_bug.cgi?id=3D562807, I reb=
uild
>>>>> libtirpc with patch applied and -DDEBUG. Unfortunatly, it doesn't b=
ring
>>>>> additional information about the server-side failure :(
>>>>
>>>> It looks to me like fflush(), called in qword_eol(), may be returnin=
g
>>>> the number of bytes flushed (95) rather than zero for success?  I
>>>> don't immediately see any changes that would cause this.  But I
>>>> haven't looked extensively...
>>> Not necessarily a change: I never used a kerberized server sofar, onl=
y
>>> clients.
>>
>> Well, I've not seen that issue before, so I assumed it was a change.
>> I looked back a bit, but didn't see: what versions of nfs-utils and
>> kernel are on the server?
> The same on both sides: kernel 2.6.33.3 + nfs-utils 1.2.2
Hello.

I finally managed to understand the issue: I also need rpc.svcgssd _and_
rpc.gssd on server side, whereas I thought rpc.gssd was needed on client
side only
(http://wiki.linux-nfs.org/wiki/index.php/Enduser_doc_kerberos). Is this
expected behaviour ?
--=20
BOFH excuse #255:

Standing room only on the bus.


--------------ms060102060609060700050408
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
BTEPFw0xMDA4MTQxNTExMDNaMCMGCSqGSIb3DQEJBDEWBBRsD1dzXw6nwLYJ76n300bwlwhn
ZjBGBgkrBgEEAYI3EAQxOTA3MDIxCzAJBgNVBAYTAkZSMQ4wDAYDVQQKEwVJTlJJQTETMBEG
A1UEAxMKSU5SSUEtUGx1cwIBRjBIBgsqhkiG9w0BCRACCzE5oDcwMjELMAkGA1UEBhMCRlIx
DjAMBgNVBAoTBUlOUklBMRMwEQYDVQQDEwpJTlJJQS1QbHVzAgFGMF8GCSqGSIb3DQEJDzFS
MFAwCwYJYIZIAWUDBAECMAoGCCqGSIb3DQMHMA4GCCqGSIb3DQMCAgIAgDANBggqhkiG9w0D
AgIBQDAHBgUrDgMCBzANBggqhkiG9w0DAgIBKDANBgkqhkiG9w0BAQEFAASCAQDix1fxzm/c
LUdPTrgAyxG0pB3pEPHBCng6UgENTd3ixX22iFD30BoSAD4PTq3L5K/Alal+GGipXs/xSaTi
0CXva1GB3Ck0MbMpxaUDUY5CtgHNDtX5DJpEuhdYFfF6VzD4AvyktnfX2jbo+ZY+wuKPmmZx
CjNSqryE114uAgtQQef1wkeD7W7RIgWbhxXmFU9CX1IBe3UCI2sZ2tjSYt0yG35FkeRzYHrP
2jxYWOO1QuuKA40VZy6apZvZnGYMVv+rg9tBlarHCtqX8H1psxif6YrInYRXkS7q1nNA1aI7
LeBG3YGASy+cZZDX70wZodI2ZQCGVIQCm4Yd5jhA0JWdAAAAAAAA

--------------ms060102060609060700050408--
