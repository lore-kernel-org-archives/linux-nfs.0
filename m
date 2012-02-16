Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:61868 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754067Ab2BPWIo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Feb 2012 17:08:44 -0500
Received: from svlrsexc2-prd.hq.netapp.com (svlrsexc2-prd.hq.netapp.com [10.57.115.31])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q1GM8hBN008698
	for <linux-nfs@vger.kernel.org>; Thu, 16 Feb 2012 14:08:43 -0800 (PST)
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Adamson, Dros" <Weston.Adamson@netapp.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "Adamson, Andy" <William.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH Version 2 1/1] NFSv4.1 set the cl_hostname for data
 servers
Date: Thu, 16 Feb 2012 22:08:38 +0000
Message-ID: <B2C8E6B1-523D-4890-B433-64B2BCB5B9AD@netapp.com>
References: <1329426646-2074-1-git-send-email-andros@netapp.com>
 <1329427752.19793.30.camel@lade.trondhjem.org>
 <18B83A3A-12E1-42D8-AE93-9BC2C5FDB136@netapp.com>
In-Reply-To: <18B83A3A-12E1-42D8-AE93-9BC2C5FDB136@netapp.com>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_89D89729-FE2E-4796-9864-49296829CFD8";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_89D89729-FE2E-4796-9864-49296829CFD8
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii


On Feb 16, 2012, at 5:00 PM, Adamson, Dros wrote:

>=20
> On Feb 16, 2012, at 4:29 PM, Myklebust, Trond wrote:
>=20
>> On Thu, 2012-02-16 at 16:10 -0500, andros@netapp.com wrote:
>>> From: Andy Adamson <andros@netapp.com>
>>>=20
>>> Used by /proc/fs/nfsfs/servers
>>>=20
>>> Signed-off-by: Andy Adamson <andros@netapp.com>
>>> ---
>>> fs/nfs/client.c            |    3 ++-
>>> fs/nfs/internal.h          |    3 ++-
>>> fs/nfs/nfs4filelayoutdev.c |   11 ++++++++++-
>>> 3 files changed, 14 insertions(+), 3 deletions(-)
>>>=20
>>> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
>>> index d0f850f..c625284 100644
>>> --- a/fs/nfs/client.c
>>> +++ b/fs/nfs/client.c
>>> @@ -1443,7 +1443,7 @@ error:
>>> */
>>> struct nfs_client *nfs4_set_ds_client(struct nfs_client* mds_clp,
>>> 		const struct sockaddr *ds_addr,
>>> -		int ds_addrlen, int ds_proto)
>>> +		int ds_addrlen, int ds_proto, char *ds_hostname)
>>=20
>> Can you make this (and the other instances below) 'const char *', so
>> that we avoid any confusion? Otherwise it looks more or less OK...
>>=20
>> Note that we should consider splitting da->da_remotestr into a
>> hostname/port part at some point so that we avoid the copy below.
>=20
> da_remotestr (and ds_remotestr) were meant to be for display only (and =
iirc they can actually be NULL).

^^ dprintk() display, that is.

>=20
> The right way to do this is from the actual sin_addr (da_addr).
>=20
> -dros


--Apple-Mail=_89D89729-FE2E-4796-9864-49296829CFD8
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
MBwGCSqGSIb3DQEJBTEPFw0xMjAyMTYyMjA4MzhaMCMGCSqGSIb3DQEJBDEWBBQpY6Dn9G/uLK1Q
nwn+PcnZFO/8xTANBgkqhkiG9w0BAQEFAASCAQAk3+IdptUsYc3bkU3Kme9ag8Wzo0T81Slm5ym2
/A+2+ExKb2Za1M+hLkaC53l7VzPBsVIa7P0Y/dzGWThFEGN0iC1tcjc5Omh+vv6OoREGQGZlX4Fk
PEEA0Tk70tqm4ZTWbWNFJj7Q9Pu56NRSz5OeWaaJ/pKL+KWx0dMD+8r6h3KBebBWe+UBT1FrINVh
/ofZvcHo6nAdb516XPWHpOGZUVanyNBAovxggHysSUdXxtPjNhBliRPSPAhegAU26Jrb6kRXk7xy
yZ+W//V780RS0AxmZvu2GyGbLgM9Dz8UEUFbKI/r3v7fQiJIiQNuhGN0h6eTGUcY5un/XYVfurtP
AAAAAAAA

--Apple-Mail=_89D89729-FE2E-4796-9864-49296829CFD8--
