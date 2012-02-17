Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:36697 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752006Ab2BQTQt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Feb 2012 14:16:49 -0500
Received: from sacrsexc1-prd.hq.netapp.com (sacrsexc1-prd.hq.netapp.com [10.99.115.27])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q1HJGX3d006353
	for <linux-nfs@vger.kernel.org>; Fri, 17 Feb 2012 11:16:34 -0800 (PST)
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Adamson, Dros" <Weston.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: include filelayout DS rpc stats in mountstats
Date: Fri, 17 Feb 2012 19:16:25 +0000
Message-ID: <B0E11743-DDA2-495A-BB39-E9982B40A170@netapp.com>
References: <1329502524-27114-1-git-send-email-dros@netapp.com>
 <1329504423.12048.3.camel@lade.trondhjem.org>
 <9E808232-0D4C-4498-8BD8-4856C4D8190F@netapp.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9030685@SACEXCMBX04-PRD.hq.netapp.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9030685@SACEXCMBX04-PRD.hq.netapp.com>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_26067470-EBD4-4A43-B83E-166CB670B651";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_26067470-EBD4-4A43-B83E-166CB670B651
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii


On Feb 17, 2012, at 2:04 PM, Myklebust, Trond wrote:

>> -----Original Message-----
>> From: Adamson, Dros
>> Sent: Friday, February 17, 2012 2:02 PM
>> To: Myklebust, Trond
>> Cc: Adamson, Dros; linux-nfs@vger.kernel.org
>> Subject: Re: [PATCH] NFS: include filelayout DS rpc stats in =
mountstats
>>=20
>> On Feb 17, 2012, at 1:47 PM, Myklebust, Trond wrote:
>>=20
>>> On Fri, 2012-02-17 at 13:15 -0500, Weston Andros Adamson wrote:
>>>> Include RPC statistics from all data servers in =
/proc/self/mountstats for
>> pNFS
>>>> filelayout mounts.
>>>>=20
>>>> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
>>>> ---
>>>> Update: don't increment tk_client stats if callback is used.
>>>>=20
>>>> This still checks task->tk_client !=3D NULL -- I'm not convinced =
it's unneeded
>>>> as it existed in rpc_count_iostats.
>>>=20
>>> I'll remove it before applying.
>>=20
>> I can repost the patch, if that's easier.
>=20
> Nah. I've already applied and pushed to the git repository.
>=20

Cool, thanks!

-dros=

--Apple-Mail=_26067470-EBD4-4A43-B83E-166CB670B651
Content-Disposition: attachment; filename="smime.p7s"
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIDTzCCA0sw
ggIzoAMCAQICAQEwCwYJKoZIhvcNAQEFMEYxFzAVBgNVBAMMDldlc3RvbiBBZGFtc29uMQswCQYD
VQQGEwJVUzEeMBwGCSqGSIb3DQEJARYPZHJvc0BuZXRhcHAuY29tMB4XDTExMDYwODIyMDc0NloX
DTEyMDYwNzIyMDc0NlowRjEXMBUGA1UEAwwOV2VzdG9uIEFkYW1zb24xCzAJBgNVBAYTAlVTMR4w
HAYJKoZIhvcNAQkBFg9kcm9zQG5ldGFwcC5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEK
AoIBAQC8/tJxtovJEXYRfSsrFOWKHxIZGY7/2mBee1DpWuoGDbVNapefCC7WXe+Nqxz609w2J/Mk
/k3trZ3Ge2NXK0tGnP9NzjkzpGA7rSpM3wUFsvbLMUEGfQpvV24/nYvcLHTvOOEUaDPpHduN94bD
dwvyowzDIRIpF2MeRnOzBNeHkrGHlZdzPmGjm8tkhrDRRkDYHhlxaiG4z30KCfAazxomuINiy1kj
vbndXooYMDoh9H63hgW4NkOedtLdflLa322DXQ3nFU7YbyOIjHVl1tgWJLDWf7WT3lsAB8KvuJZ5
zhsUB+fqxCKPJVRPDO1gjChvvtGiG1tGUUZz0H9Wx00zAgMBAAGjRjBEMA4GA1UdDwEB/wQEAwIH
gDAWBgNVHSUBAf8EDDAKBggrBgEFBQcDBDAaBgNVHREEEzARgQ9kcm9zQG5ldGFwcC5jb20wDQYJ
KoZIhvcNAQEFBQADggEBACv0niZSmW+psB1sJXULh3mecDbN2mj0bFpN1YNdjcV7BiOLJ1Rs1ibV
f13h73z8C7SBsPXTM5si8gmJtOnXM5jsgtlql44h/RrjUr8+mtK5DPCZls9J7iz3cGthzwOPvxUj
nMSv3BpRX5oJom5ESgCM9Nn4u/ECTlLMhEIOYnBFiN0eDxcxz+r1cpbHg3r0otIKyxLpeaCjP6AH
F93EHp4T8Rb63y3CcDgxrQGHlTdVi3QvxaMUexUXD81fiA+UqsB/MKmRxB1Hs4Vf3Q/+ejcm78K1
ROF8TNPmNWRlKg3Y7cSFjZGzLuzXsvSsCbw4HLn0oZe/OfgSbarTAxttL5IxggHRMIIBzQIBATBL
MEYxFzAVBgNVBAMMDldlc3RvbiBBZGFtc29uMQswCQYDVQQGEwJVUzEeMBwGCSqGSIb3DQEJARYP
ZHJvc0BuZXRhcHAuY29tAgEBMAkGBSsOAwIaBQCgXTAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcB
MBwGCSqGSIb3DQEJBTEPFw0xMjAyMTcxOTE2MjVaMCMGCSqGSIb3DQEJBDEWBBQkFNjQWyksuFdf
6Cnyb046L1YxTzANBgkqhkiG9w0BAQEFAASCAQBtf640B9Xs1uEhNSP/3NoODIhDmnSMpNMQRt7m
msZTv+7/CyGLpMXNNoDk3nv4nIhjVpV1HsQIMiMiTJz5TPhls0xMooeG+VGc79fPa4gM/fdITkWq
Q/ZeWfUV9roTTNQJnyg4SdPoyTwOfNXmHT5kt1iPeXrjlH6RndJEpMv0yvFKLIVI09sX9XJQWV6C
v15qtIlecsWRkty4Fd+Dr8/lBXVO6bwo79/QmJHzw9dfDMBQa2aDRRPvz+wF3D0XYoaZnD3Lo9oY
yJ57U35MLoCodyRfdMX0Uy5UtKkjFqF59Si4n5m2R3Rn8FgBYDT+Xuly83MYA9NqqtV1Kh1+P59r
AAAAAAAA

--Apple-Mail=_26067470-EBD4-4A43-B83E-166CB670B651--
