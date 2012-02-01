Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:40041 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755053Ab2BAU0D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Feb 2012 15:26:03 -0500
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "Adamson, Dros" <Weston.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/2] NFS: add mount option 'v4.1'
Date: Wed, 1 Feb 2012 20:25:55 +0000
Message-ID: <06E7DD7B-C7E9-479F-A703-3C6AEE421463@netapp.com>
References: <1328122817-661-1-git-send-email-dros@netapp.com>
 <1328122817-661-2-git-send-email-dros@netapp.com>
 <16B8D5D9-4373-474E-A54A-AF853AC59153@oracle.com>
 <1328125568.3789.103.camel@lade.trondhjem.org>
 <58E70AA6-71A7-4C5F-8423-523769D5B2C6@oracle.com>
 <1328126374.3789.111.camel@lade.trondhjem.org>
 <BD18F976-317D-4651-9674-8C564B13E8E3@oracle.com>
In-Reply-To: <BD18F976-317D-4651-9674-8C564B13E8E3@oracle.com>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_759DF613-8AE5-431A-87FF-87661E6C7C9E";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_759DF613-8AE5-431A-87FF-87661E6C7C9E
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii


On Feb 1, 2012, at 3:05 PM, Chuck Lever wrote:

>=20
> On Feb 1, 2012, at 2:59 PM, Myklebust, Trond wrote:
>=20
>> On Wed, 2012-02-01 at 14:48 -0500, Chuck Lever wrote:
>>> On Feb 1, 2012, at 2:46 PM, Myklebust, Trond wrote:
>>>=20
>>>> On Wed, 2012-02-01 at 14:17 -0500, Chuck Lever wrote:
>>>>> Hi-
>>>>>=20
>>>>> I think we should co-ordinate with Solaris on this administrative =
interface.  Can we discuss in Santa Clara?
>>>>=20
>>>> Unless they have a strong argument for why this is a bad idea, I =
plan on
>>>> just adding this to 3.4. There is no point in foot-dragging on this =
any
>>>> more.
>>>=20
>>> No foot dragging.  We just ask at the next convenient opportunity.  =
I think they want to go with vers=3D41.
>>=20
>> "4.1" allows for easier visual and automated parsing of major vs =
minor
>> version. In 8 years from now, I'd prefer to see 'vers=3D4.10' rather =
than
>> 'vers=3D410'
>=20
> Fair enough, and I've made similar points to them in the past.  But =
you should be having this conversation with the Solaris guys, not me.  =
Can we have this discussion at Connectathon, when all interested parties =
will be in the room?  That should still be enough time to allow you to =
submit this change for 3.4.
>=20
> (And by the way, you will probably need some adjustment to mount.nfs's =
string parsing logic as well).

Well, it "just worked" for me!

-dros=

--Apple-Mail=_759DF613-8AE5-431A-87FF-87661E6C7C9E
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
MBwGCSqGSIb3DQEJBTEPFw0xMjAyMDEyMDI1NTZaMCMGCSqGSIb3DQEJBDEWBBRbB6jq7M2O58F0
vN5T6eHA0ccHlzANBgkqhkiG9w0BAQEFAASCAQCNjrM8FaKuq/7QcHFrfVkY+WlDY7R7vuAYw+DQ
glUlUZHJeCW6epg4+p/RlODtOztIf3iByOHwZcFDGvUrfOHCs9rm54ilIgUT/Iaiqo8NIeJT1O5W
vptZClgrzPo4oCOBBBBsqWGPDsGVYLtKcPl9Oixvh/5MzdERRtFtLZArWYUHMNodxEAqo9ceXa8T
rI8zgSGJc2c153DB6Lfa2uQyHl8gV8HMJbOgzTNi8j3HA2iAwyD+8ToiHSSF5+EEPtxxhwFcUXS+
B1TQHdI1oyaNoFam0j+tyXQiU9VNXvW3/yVDhYzoTTepQTaq1dRh2MrZZniEQI6VJi2Jk5vUa+4B
AAAAAAAA

--Apple-Mail=_759DF613-8AE5-431A-87FF-87661E6C7C9E--
