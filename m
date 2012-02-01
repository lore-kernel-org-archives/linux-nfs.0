Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:46560 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755156Ab2BATi2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Feb 2012 14:38:28 -0500
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/2] NFS: add mount option 'v4.1'
Date: Wed, 1 Feb 2012 19:38:03 +0000
Message-ID: <3747B57D-6684-4FB3-B7E3-CED61116C485@netapp.com>
References: <1328122817-661-1-git-send-email-dros@netapp.com>
 <1328122817-661-2-git-send-email-dros@netapp.com>
 <16B8D5D9-4373-474E-A54A-AF853AC59153@oracle.com>
In-Reply-To: <16B8D5D9-4373-474E-A54A-AF853AC59153@oracle.com>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_AAC92210-FF35-49E1-A7A9-EF81F9EC0F34";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_AAC92210-FF35-49E1-A7A9-EF81F9EC0F34
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

Fine with me.

-dros

On Feb 1, 2012, at 2:17 PM, Chuck Lever wrote:

> Hi-
>=20
> I think we should co-ordinate with Solaris on this administrative =
interface.  Can we discuss in Santa Clara?
>=20
> On Feb 1, 2012, at 2:00 PM, Weston Andros Adamson wrote:
>=20
>>=20
>> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
>> ---
>> I was already messing around with mountoptions and figured "why not".
>> It's been joked (?) that 4.1 really should have been NFSv5!=20
>>=20
>> fs/nfs/super.c |    8 +++++++-
>> 1 files changed, 7 insertions(+), 1 deletions(-)
>>=20
>> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
>> index 50baca1..801b060 100644
>> --- a/fs/nfs/super.c
>> +++ b/fs/nfs/super.c
>> @@ -80,7 +80,7 @@ enum {
>> 	Opt_cto, Opt_nocto,
>> 	Opt_ac, Opt_noac,
>> 	Opt_lock, Opt_nolock,
>> -	Opt_v2, Opt_v3, Opt_v4,
>> +	Opt_v2, Opt_v3, Opt_v4, Opt_v4_1,
>> 	Opt_udp, Opt_tcp, Opt_rdma,
>> 	Opt_acl, Opt_noacl,
>> 	Opt_rdirplus, Opt_nordirplus,
>> @@ -136,6 +136,7 @@ static const match_table_t =
nfs_mount_option_tokens =3D {
>> 	{ Opt_v2, "v2" },
>> 	{ Opt_v3, "v3" },
>> 	{ Opt_v4, "v4" },
>> +	{ Opt_v4_1, "v4.1" },
>> 	{ Opt_udp, "udp" },
>> 	{ Opt_tcp, "tcp" },
>> 	{ Opt_rdma, "rdma" },
>> @@ -1172,6 +1173,11 @@ static int nfs_parse_mount_options(char *raw,
>> 			mnt->flags &=3D ~NFS_MOUNT_VER3;
>> 			mnt->version =3D 4;
>> 			break;
>> +		case Opt_v4_1:
>> +			mnt->flags &=3D ~NFS_MOUNT_VER3;
>> +			mnt->version =3D 4;
>> +			mnt->minorversion =3D 1;
>> +			break;
>> 		case Opt_udp:
>> 			mnt->flags &=3D ~NFS_MOUNT_TCP;
>> 			mnt->nfs_server.protocol =3D XPRT_TRANSPORT_UDP;
>> --=20
>> 1.7.4.4
>>=20
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
> --=20
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
>=20
>=20
>=20
>=20


--Apple-Mail=_AAC92210-FF35-49E1-A7A9-EF81F9EC0F34
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
MBwGCSqGSIb3DQEJBTEPFw0xMjAyMDExOTM4MDRaMCMGCSqGSIb3DQEJBDEWBBS62knuzDyvJ7b/
7Uh2Dfu5YuKsjjANBgkqhkiG9w0BAQEFAASCAQBFUPipwS9xo62WaPlOB5WRfKHgoo9wjOr98Ce6
5Qeun0YDcE1ltmipBQquv6EV0xTT7loDALgzq4+hNAAJ9zxrAy+6QW3QY6rfmehzXaIiY4+y9rvN
pQFFT4yNKonuSCKnbeW8F1mF5LNscduEeSS9D2//zyYjbXNtENhQr/4UXg2e8zuh7szmlPbG7GTA
pg2aK372U+Qs5ZqaTI74KEwsLxOeFt2UykAMEa6WDvcGB3KYLfPQy4k1xfIOlL5JVofZz0BPb0wn
+25wygjgsMyRCeB8/TNr2JqkV1ZIWy+XvNO6uk+I0hquFSQsY1Y8uuoQ75HJUw3Tz2kw0YH/cJmb
AAAAAAAA

--Apple-Mail=_AAC92210-FF35-49E1-A7A9-EF81F9EC0F34--
