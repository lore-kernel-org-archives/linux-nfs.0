Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:14359 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755942Ab2BGSa1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Feb 2012 13:30:27 -0500
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: Boaz Harrosh <bharrosh@panasas.com>
CC: Chuck Lever <chuck.lever@oracle.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: add mount options 'v4.0' and 'v4.1'
Date: Tue, 7 Feb 2012 18:30:05 +0000
Message-ID: <904F47FA-7497-49DA-B1DF-C113ACB26059@netapp.com>
References: <1328633351-1741-1-git-send-email-dros@netapp.com>
 <A5356E85-1E22-4C4C-A30C-58A912AE3C9F@oracle.com>
 <4F316BC4.4030504@panasas.com>
In-Reply-To: <4F316BC4.4030504@panasas.com>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_EC04A69E-01A5-4B4F-9344-151CC40B51C1";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_EC04A69E-01A5-4B4F-9344-151CC40B51C1
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii


On Feb 7, 2012, at 1:21 PM, Boaz Harrosh wrote:

> On 02/07/2012 06:59 PM, Chuck Lever wrote:
>> Hi-
>>=20
>> On Feb 7, 2012, at 11:49 AM, Weston Andros Adamson wrote:
>>>=20
>>> NFS: add mount options 'v4.0' and 'v4.1'
>=20
> Good god thanks, that'll be nice.
>=20
> Why did we have to suffer for 5 years without it? ;-)
>=20
>>> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
>>> ---
>>> Updated to add 'v4.0' as trond requested.
>>>=20
>>> We'll talk about this change at connectathon.
>>>=20
>>> This 'just works' with mount.nfs(8) -- v.* options are passed to the=20=

>>> kernel with no modifications needed.
>>=20
>> I'm more concerned about version auto-negotation.
>>=20
>=20
> If we are at it can we also have a "this-version-only" option which
> disables "auto-negotation"

Trond seems to have a plan for this.  I'll defer to him.

-dros

>=20
> I know that's an hard one
>=20
> OK we'll talk at CON12.
>=20
> Thanks Andy
> Boaz
>=20
>>>=20
>>> fs/nfs/super.c |   14 +++++++++++++-
>>> 1 files changed, 13 insertions(+), 1 deletions(-)
>>>=20
>>> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
>>> index b88e023..d89cee2 100644
>>> --- a/fs/nfs/super.c
>>> +++ b/fs/nfs/super.c
>>> @@ -80,7 +80,7 @@ enum {
>>> 	Opt_cto, Opt_nocto,
>>> 	Opt_ac, Opt_noac,
>>> 	Opt_lock, Opt_nolock,
>>> -	Opt_v2, Opt_v3, Opt_v4,
>>> +	Opt_v2, Opt_v3, Opt_v4, Opt_v4_0, Opt_v4_1,
>>> 	Opt_udp, Opt_tcp, Opt_rdma,
>>> 	Opt_acl, Opt_noacl,
>>> 	Opt_rdirplus, Opt_nordirplus,
>>> @@ -136,6 +136,8 @@ static const match_table_t =
nfs_mount_option_tokens =3D {
>>> 	{ Opt_v2, "v2" },
>>> 	{ Opt_v3, "v3" },
>>> 	{ Opt_v4, "v4" },
>>> +	{ Opt_v4_0, "v4.0" },
>>> +	{ Opt_v4_1, "v4.1" },
>>> 	{ Opt_udp, "udp" },
>>> 	{ Opt_tcp, "tcp" },
>>> 	{ Opt_rdma, "rdma" },
>>> @@ -1172,6 +1174,16 @@ static int nfs_parse_mount_options(char *raw,
>>> 			mnt->flags &=3D ~NFS_MOUNT_VER3;
>>> 			mnt->version =3D 4;
>>> 			break;
>>> +		case Opt_v4_0:
>>> +			mnt->flags &=3D ~NFS_MOUNT_VER3;
>>> +			mnt->version =3D 4;
>>> +			mnt->minorversion =3D 0;
>>> +			break;
>>> +		case Opt_v4_1:
>>> +			mnt->flags &=3D ~NFS_MOUNT_VER3;
>>> +			mnt->version =3D 4;
>>> +			mnt->minorversion =3D 1;
>>> +			break;
>>> 		case Opt_udp:
>>> 			mnt->flags &=3D ~NFS_MOUNT_TCP;
>>> 			mnt->nfs_server.protocol =3D XPRT_TRANSPORT_UDP;
>>> --=20
>>> 1.7.4.4
>>>=20
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>=20
>=20


--Apple-Mail=_EC04A69E-01A5-4B4F-9344-151CC40B51C1
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
MBwGCSqGSIb3DQEJBTEPFw0xMjAyMDcxODMwMDZaMCMGCSqGSIb3DQEJBDEWBBSLawiCX7j4Masm
zIShBLo9QANBHjANBgkqhkiG9w0BAQEFAASCAQAKoFNrsg90WW2u7PczjIq6ALcv+i3mB36WmnhT
ZZwONMkKOv4VRc0m3QkpWhE74z1VTr2ggh3vKLuNNT6me4wE9lrD/Ma3H/1W65lp+AuTC2HHszKX
pvWns6HBOVuBC+kqNPys4gZ7EfQ3Ole9L1Cb2t9F05Td0bcXyI07/R0gfQ6Xop8E/nVXbk/zyHTD
O5VHnMDrGEGxLctqwna7Pv30wmcR/1H6hLp9fMGwP5nna3PHYwscvfeQeWkIdV1OpKERRPCAQ8BI
iEUhqpgBt3RhQR1R+zIACgZ2VXx5rxo9brZOXyT12k16fYOBVUYJk7yx2D6axbB3Em17GqPhQA86
AAAAAAAA

--Apple-Mail=_EC04A69E-01A5-4B4F-9344-151CC40B51C1--
