Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:12200 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751759Ab2CFRIK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Mar 2012 12:08:10 -0500
Received: from vmwexceht03-prd.hq.netapp.com ([10.106.76.241])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q26H8751000965
	for <linux-nfs@vger.kernel.org>; Tue, 6 Mar 2012 09:08:09 -0800 (PST)
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "Adamson, Dros" <Weston.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/3] NFSv4: parse and display server implementation ids
Date: Tue, 6 Mar 2012 17:08:09 +0000
Message-ID: <F2EBB85C-C7D1-44BF-8863-7CA5FC5203C5@netapp.com>
References: <1329510026-30403-1-git-send-email-dros@netapp.com>
 <1329510026-30403-3-git-send-email-dros@netapp.com>
 <4F522623.3070709@netapp.com> <1330904007.14357.13.camel@lade.trondhjem.org>
In-Reply-To: <1330904007.14357.13.camel@lade.trondhjem.org>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_3B5A2311-D0F7-4D7E-BB00-ADB49C543DD0";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_3B5A2311-D0F7-4D7E-BB00-ADB49C543DD0
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii


On Mar 4, 2012, at 6:33 PM, Myklebust, Trond wrote:

> On Sat, 2012-03-03 at 09:09 -0500, Bryan Schumaker wrote:
>> Hi Dros,
>>=20
>> On 02/17/2012 03:20 PM, Weston Andros Adamson wrote:
>>=20
>>> Shows the implementation ids in /proc/self/mountstats.  This doesn't =
break
>>> the nfs-utils mountstats tool.
>>>=20
>>> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
>>> ---
>>> fs/nfs/client.c           |    1 +
>>> fs/nfs/nfs4proc.c         |   21 +++++++++++++++++++++
>>> fs/nfs/nfs4xdr.c          |   42 =
+++++++++++++++++++++++++++++++++++++-----
>>> fs/nfs/super.c            |    8 ++++++++
>>> include/linux/nfs_fs_sb.h |    2 ++
>>> include/linux/nfs_xdr.h   |   15 +++++++--------
>>> 6 files changed, 76 insertions(+), 13 deletions(-)
>>>=20
>>=20
>> <snip>
>>=20
>>> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
>>> index d05024a..5462225 100644
>>> --- a/fs/nfs/super.c
>>> +++ b/fs/nfs/super.c
>>> @@ -809,6 +809,14 @@ static int nfs_show_stats(struct seq_file *m, =
struct dentry *root)
>>>=20
>>> 	seq_printf(m, "\n\tage:\t%lu", (jiffies - nfss->mount_time) / =
HZ);
>>>=20
>>> +	if (nfss->nfs_client && nfss->nfs_client->impl_id) {
>>> +		struct nfs41_impl_id *impl_id =3D =
nfss->nfs_client->impl_id;
>>=20
>>=20
>> "struct nfs41_impl_id" is only defined when CONFIG_NFS_V4_1 is =
enabled, so if I compile without NFS 4.1 enabled I get this error:
>>=20
>>  CC [M]  fs/nfs/super.o
>> /home/bjschuma/linux/modules/fs/nfs/super.c: In function =
'nfs_show_stats':
>> /home/bjschuma/linux/modules/fs/nfs/super.c:843:14: error: =
dereferencing pointer to incomplete type
>> /home/bjschuma/linux/modules/fs/nfs/super.c:843:29: error: =
dereferencing pointer to incomplete type
>> /home/bjschuma/linux/modules/fs/nfs/super.c:844:14: error: =
dereferencing pointer to incomplete type
>> /home/bjschuma/linux/modules/fs/nfs/super.c:844:37: error: =
dereferencing pointer to incomplete type
>> make[3]: *** [fs/nfs/super.o] Error 1

Oops!  Good catch Bryan!

>=20
> Hi Bryan & Dros
>=20
> I've applied the following patch to fix this issue. Please advise if
> you're still seeing compile problems when it is applied.
>=20
> =
8<------------------------------------------------------------------------=
----
> =46rom d032769b833d8fbaaa620a54300979dd5881d493 Mon Sep 17 00:00:00 =
2001
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date: Sun, 4 Mar 2012 18:12:57 -0500
> Subject: [PATCH] NFS: Fix a compile issue when !CONFIG_NFS_V4_1
>=20
> The attempt to display the implementation ID needs to be conditional =
on
> whether or not CONFIG_NFS_V4_1 is defined
>=20
> Reported-by: Bryan Schumaker <Bryan.Schumaker@netapp.com>
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> fs/nfs/super.c |   22 +++++++++++++++-------
> 1 files changed, 15 insertions(+), 7 deletions(-)
>=20
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index 3935a37..61419c9 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -785,8 +785,22 @@ static void show_pnfs(struct seq_file *m, struct =
nfs_server *server)
> 	else
> 		seq_printf(m, "not configured");
> }
> +
> +static void show_implementation_id(struct seq_file *m, struct =
nfs_server *nfss)
> +{
> +	if (nfss->nfs_client && nfss->nfs_client->impl_id) {
> +		struct nfs41_impl_id *impl_id =3D =
nfss->nfs_client->impl_id;
> +		seq_printf(m, "\n\timpl_id:\tname=3D'%s',domain=3D'%s',"
> +			   "date=3D'%llu,%u'",
> +			   impl_id->name, impl_id->domain,
> +			   impl_id->date.seconds, =
impl_id->date.nseconds);
> +	}
> +}
> #else
> static void show_pnfs(struct seq_file *m, struct nfs_server *server) =
{}
> +static void show_implementation_id(struct seq_file *m, struct =
nfs_server *nfss)
> +{
> +}
> #endif
> #endif
>=20
> @@ -836,13 +850,7 @@ static int nfs_show_stats(struct seq_file *m, =
struct dentry *root)
>=20
> 	seq_printf(m, "\n\tage:\t%lu", (jiffies - nfss->mount_time) / =
HZ);
>=20
> -	if (nfss->nfs_client && nfss->nfs_client->impl_id) {
> -		struct nfs41_impl_id *impl_id =3D =
nfss->nfs_client->impl_id;
> -		seq_printf(m, "\n\timpl_id:\tname=3D'%s',domain=3D'%s',"
> -			   "date=3D'%llu,%u'",
> -			   impl_id->name, impl_id->domain,
> -			   impl_id->date.seconds, =
impl_id->date.nseconds);
> -	}
> +	show_implementation_id(m, nfss);
>=20
> 	seq_printf(m, "\n\tcaps:\t");
> 	seq_printf(m, "caps=3D0x%x", nfss->caps);
> --=20
> 1.7.7.6

Works for me.  I need to test with different CONFIG opts more often!

-dros=

--Apple-Mail=_3B5A2311-D0F7-4D7E-BB00-ADB49C543DD0
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
MBwGCSqGSIb3DQEJBTEPFw0xMjAzMDYxNzA4MDlaMCMGCSqGSIb3DQEJBDEWBBStck7XAa+XSDrs
w9/QGcxf1MyvLDANBgkqhkiG9w0BAQEFAASCAQA6fS7HKpYMQcSzjQl53yzsh+ek/TF2yXjAd38f
eVrQbPMkbkSY8qKKf8aBUw13dKJZ1+zGUvTSSdaBkecelsNwFlJjo3oNbZAiBXpN3mJg12kJ7ovt
qHtdRq6wn8TGv6WNPQxb5BkuWpLnIy8hc3aatHe0drX6YRKB3GW+BsfjBHN+e2esjVI7JvrUA6cT
+CIfZGqjSTqchKPNQZN0C+oUG2u4/C7T58y9Iq7BI9XcSEUp3UmVfjfG/5vXo6wFvuq97CgDKci6
pfoSRbh/UeoW+5dlfbSuNAxSRvNB/bBD7wf/YYBXayUqWibKHbiatmpAv/rtDWPvr+eShlp3JbBA
AAAAAAAA

--Apple-Mail=_3B5A2311-D0F7-4D7E-BB00-ADB49C543DD0--
