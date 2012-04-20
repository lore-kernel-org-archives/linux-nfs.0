Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:18867 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755359Ab2DTWFe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Apr 2012 18:05:34 -0400
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Adamson, Dros" <Weston.Adamson@netapp.com>, Jim Rees <rees@umich.edu>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS4: fix referrals with IPv6 mounts
Date: Fri, 20 Apr 2012 22:05:32 +0000
Message-ID: <1642D7EE-AF61-42D8-BB8B-BA444207DFAF@netapp.com>
References: <1334949705-33393-1-git-send-email-dros@netapp.com>
 <20120420194504.GA10259@umich.edu>
 <EA178ED0-5813-4235-A0CF-CF9D54AFB04F@netapp.com>
 <1334952788.3295.24.camel@lade.trondhjem.org>
 <A3FAE1E4-2AB8-4AF0-AC46-77EA3E4B9AB2@netapp.com>
 <1334957730.3295.35.camel@lade.trondhjem.org>
 <9AAD6718-5A17-482C-8AC1-A6F676838AF0@netapp.com>
 <1334958209.3295.39.camel@lade.trondhjem.org>
 <A74D78B5-728F-45EE-8A02-6FDBE0D5ABB2@netapp.com>
 <1334959106.3295.43.camel@lade.trondhjem.org>
In-Reply-To: <1334959106.3295.43.camel@lade.trondhjem.org>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_3992F476-0BD8-426D-BB31-1E61F6907608";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_3992F476-0BD8-426D-BB31-1E61F6907608
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On Apr 20, 2012, at 5:58 PM, Myklebust, Trond wrote:

> On Fri, 2012-04-20 at 21:48 +0000, Adamson, Dros wrote:
>> On Apr 20, 2012, at 5:43 PM, Myklebust, Trond wrote:
>>=20
>>> On Fri, 2012-04-20 at 21:38 +0000, Adamson, Dros wrote:
>>>=20
>>>> Yes, something like that could work, but we still have the same =
issue - dentry->d_fsdata never has [] escaping.
>>>=20
>>> That's a bug too...=20
>>=20
>> Right! This is what I've been talking about the whole time - I guess =
I didn't do a good job explaining it :)  The original bug (splitting =
return of nfs_path()) would be trivial to fix if d_fsdata had [] =
escaping.
>>=20
>> So I guess that answers my earlier question - we *do* want to change =
dev_name to include [] escaping.
>>=20
>> -dros
>=20
> Here is a patch from Jan Kara that does just this. I'll start by
> applying that...

Cool! dprintk debugging just led me there!

Why wasn't this patch applied earlier?  Just curious.

I'll post a new patch to fix splitting nfs_path().

-dros=

--Apple-Mail=_3992F476-0BD8-426D-BB31-1E61F6907608
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
MBwGCSqGSIb3DQEJBTEPFw0xMjA0MjAyMjA1MzJaMCMGCSqGSIb3DQEJBDEWBBQvtUH9KnNspLFL
1BS7HX1HMPogtzANBgkqhkiG9w0BAQEFAASCAQA+OhATetB1lcgKZuciIgcBJC9tn7CMf00MaoPE
VSEfrHlEKSTOe7p22l4OgWlSjIceWBMzfEcL6uN8Y3LozO7gDmajBdDfwnssL6Bd/VWKXKtzhHT4
OOtByRgF9uzVatBVeq96mbvVWxbNIBxuyoP4IYKEDXVayGjnfnrN8j0Wffa3uiNG/vHzLHgZztxr
f6am/8aSyertSevAxOy/5uIDAeTR8olm8r3L8hJ8tpECrwFcEQw0DQ614sSHXlhcsOonNoH5EDsz
9Dmty+Zz/SFvF80BUv8yz3kj0djw5xyrL0vPFqaM3VDZ3posZqRfNwC8TVLASx1wepfMAjPmhbsQ
AAAAAAAA

--Apple-Mail=_3992F476-0BD8-426D-BB31-1E61F6907608--
