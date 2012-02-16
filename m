Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:34549 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751354Ab2BPUwS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Feb 2012 15:52:18 -0500
Received: from sacrsexc2-prd.hq.netapp.com (sacrsexc2-prd.hq.netapp.com [10.99.115.28])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q1GKqG9m018934
	for <linux-nfs@vger.kernel.org>; Thu, 16 Feb 2012 12:52:17 -0800 (PST)
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Adamson, Dros" <Weston.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/3] NFSv4: Send implementation id with exchange_id
Date: Thu, 16 Feb 2012 20:52:06 +0000
Message-ID: <2399622F-3455-425B-AA3D-C0412EC4C0D2@netapp.com>
References: <1329409026-20466-1-git-send-email-dros@netapp.com>
 <1329424827.19793.11.camel@lade.trondhjem.org>
In-Reply-To: <1329424827.19793.11.camel@lade.trondhjem.org>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_83895B38-6419-4A23-BB2A-603EF61BA025";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_83895B38-6419-4A23-BB2A-603EF61BA025
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii


On Feb 16, 2012, at 3:40 PM, Myklebust, Trond wrote:

> On Thu, 2012-02-16 at 11:17 -0500, Weston Andros Adamson wrote:
>> Send the nfs implementation id in EXCHANGE_ID requests unless the =
module
>> parameter nfs.send_implementation_id is 0.
>>=20
>> This adds a CONFIG variable for the nii_domain that defaults to =
"kernel.org".
>>=20
>> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
>> ---
>> Documentation/kernel-parameters.txt |    9 ++++++++
>> fs/nfs/Kconfig                      |    8 +++++++
>> fs/nfs/nfs4xdr.c                    |   38 =
+++++++++++++++++++++++++++++++++-
>> 3 files changed, 53 insertions(+), 2 deletions(-)
>>=20
>> diff --git a/Documentation/kernel-parameters.txt =
b/Documentation/kernel-parameters.txt
>> index 1d369c6..7bae0fd 100644
>> --- a/Documentation/kernel-parameters.txt
>> +++ b/Documentation/kernel-parameters.txt
>> @@ -1678,6 +1678,15 @@ bytes respectively. Such letter suffixes can =
also be entirely omitted.
>> 			back to using the idmapper.
>> 			To turn off this behaviour, set the value to =
'0'.
>>=20
>> +	nfs.send_implementation_id =3D
>> +			[NFSv4.1] Send client implementation =
identification
>> +			information in exchange_id requests.
>> +			If zero, no implementation identification =
information
>> +			will be sent.
>> +			The default is to send the implementation =
identification
>> +			information.
>> +
>> +
>> 	nmi_debug=3D	[KNL,AVR32,SH] Specify one or more actions to =
take
>> 			when a NMI is triggered.
>> 			Format: [state][,regs][,debounce][,die]
>> diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
>> index ee86cfc..09f9e38 100644
>> --- a/fs/nfs/Kconfig
>> +++ b/fs/nfs/Kconfig
>> @@ -99,6 +99,14 @@ config PNFS_OBJLAYOUT
>> 	depends on NFS_FS && NFS_V4_1 && SCSI_OSD_ULD
>> 	default m
>>=20
>> +config NFS_V4_1_IMPLEMENTATION_ID_DOMAIN
>> +	string "NFSv4.1 Implementation ID Domain"
>> +	depends on NFS_V4_1
>> +	default "kernel.org"
>> +	help
>> +	  This value will be used in EXCHANGE_ID compounds to help =
identify
>> +	  the client implementation.
>=20
> This needs more fleshing out in order to explain what the purpose is
> (identify the DNS domainname of the distribution), and what format the
> string needs to take (DNS domainname). You might also follow up with a
> recommendation that if the NFS client is unchanged from the upstream
> kernel, then people should use the default 'kernel.org'.

Understood.

>=20
>> +
>> config ROOT_NFS
>> 	bool "Root file system on NFS"
>> 	depends on NFS_FS=3Dy && IP_PNP
>> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
>> index ae78343..70ded94 100644
>> --- a/fs/nfs/nfs4xdr.c
>> +++ b/fs/nfs/nfs4xdr.c
>> @@ -44,6 +44,8 @@
>> #include <linux/pagemap.h>
>> #include <linux/proc_fs.h>
>> #include <linux/kdev_t.h>
>> +#include <linux/module.h>
>> +#include <linux/utsname.h>
>> #include <linux/sunrpc/clnt.h>
>> #include <linux/sunrpc/msg_prot.h>
>> #include <linux/sunrpc/gss_api.h>
>> @@ -271,7 +273,12 @@ static int nfs4_stat_to_errno(int);
>> 				1 /* flags */ + \
>> 				1 /* spa_how */ + \
>> 				0 /* SP4_NONE (for now) */ + \
>> -				1 /* zero implemetation id array */)
>> +				1 /* implemetation id array of size 1 */ =
+ \
>> +				1 /* nii_domain */ + \
>> +				XDR_QUADLEN(NFS4_OPAQUE_LIMIT) + \
>> +				1 /* nii_name */ + \
>> +				XDR_QUADLEN(NFS4_OPAQUE_LIMIT) + \
>> +				3 /* nii_date */)
>> #define decode_exchange_id_maxsz (op_decode_hdr_maxsz + \
>> 				2 /* eir_clientid */ + \
>> 				1 /* eir_sequenceid */ + \
>> @@ -838,6 +845,12 @@ const u32 nfs41_maxread_overhead =3D =
((RPC_MAX_HEADER_WITH_AUTH +
>> 				    XDR_UNIT);
>> #endif /* CONFIG_NFS_V4_1 */
>>=20
>> +static unsigned short send_implementation_id =3D 1;
>> +
>> +module_param(send_implementation_id, ushort, 0644);
>> +MODULE_PARM_DESC(send_implementation_id,
>> +		"Send implementation ID with NFSv4.1 exchange_id");
>> +
>> static const umode_t nfs_type2fmt[] =3D {
>> 	[NF4BAD] =3D 0,
>> 	[NF4REG] =3D S_IFREG,
>> @@ -1766,6 +1779,8 @@ static void encode_exchange_id(struct =
xdr_stream *xdr,
>> 			       struct compound_hdr *hdr)
>> {
>> 	__be32 *p;
>> +	char impl_name[260]; /* 4 strs max 64 each, spaces and null */
>                        ^^^^ Shouldn't you be putting this in terms of
> NFS4_OPAQUE_LIMIT etc like you did above?

The NFS4_OPAQUE_LIMIT is from the spec - that is, a server could make an =
nii_name string that big. =20
Creating the client's nii_name is bound by utsname() size limits =
(__NEW_UTS_LEN =3D 64).

If you'd prefer me to just use NFS4_OPAQUE_LIMIT, I have no problem with =
it.

>=20
>> +	int len =3D 0;
>>=20
>> 	p =3D reserve_space(xdr, 4 + sizeof(args->verifier->data));
>> 	*p++ =3D cpu_to_be32(OP_EXCHANGE_ID);
>> @@ -1776,7 +1791,26 @@ static void encode_exchange_id(struct =
xdr_stream *xdr,
>> 	p =3D reserve_space(xdr, 12);
>> 	*p++ =3D cpu_to_be32(args->flags);
>> 	*p++ =3D cpu_to_be32(0);	/* zero length state_protect4_a =
*/
>> -	*p =3D cpu_to_be32(0);	/* zero length implementation id array =
*/
>> +
>> +	if (send_implementation_id)
>> +		len =3D snprintf(impl_name, sizeof(impl_name), "%s %s %s =
%s",
>> +			       utsname()->sysname, utsname()->release,
>> +			       utsname()->version, utsname()->machine);
>> +
>=20
> Can we put in a compile-time check on
> CONFIG_NFS_V4_1_IMPLEMENTATION_ID_DOMAIN here to make sure that the
> length is bounded?

Yes, good call.  It should also check to make sure its not an empty =
string -- some servers (pynfs at least) blow up when you send a string =
of size 0 here.

>=20
>> +	if (len > 0) {
>> +		*p =3D cpu_to_be32(1);	/* implementation id array =
length=3D1 */
>> +
>> +		encode_string(xdr,
>> +			=
strlen(CONFIG_NFS_V4_1_IMPLEMENTATION_ID_DOMAIN),
>> +			CONFIG_NFS_V4_1_IMPLEMENTATION_ID_DOMAIN);
>> +		encode_string(xdr, len, impl_name);
>> +		/* just send zeros for nii_date - the date is in =
nii_name */
>> +		p =3D reserve_space(xdr, 12);
>> +		p =3D xdr_encode_hyper(p, 0);
>> +		*p =3D cpu_to_be32(0);
>> +	} else
>> +		*p =3D cpu_to_be32(0);	/* implementation id array =
length=3D0 */
>> +
>> 	hdr->nops++;
>> 	hdr->replen +=3D decode_exchange_id_maxsz;
>> }

Thanks,
-dros=

--Apple-Mail=_83895B38-6419-4A23-BB2A-603EF61BA025
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
MBwGCSqGSIb3DQEJBTEPFw0xMjAyMTYyMDUyMDdaMCMGCSqGSIb3DQEJBDEWBBQS65mo5HQN8CnQ
T+6rDa+W7Sjm4zANBgkqhkiG9w0BAQEFAASCAQBokqtkGkMeTaSM5nlD0kdIoimCBlYdcmeLHtV4
84FA60ucfoLoWZj8gxtOfuPVT2hhOcjYCMZJbGxvLxuoA2L8KR1uPzW0j+71ZVs5P9EpsUISGWxc
6S5Py+8WlE/0WuNhDS0fODlOziHfDRrs70ZBiNg1HrmNDanMefIuQBRRKNlpopqORqd7Vd/7emlP
UOjiuZHYaJJvejNNlpi1xAQ10moPVCYT60xfgkGbG/GNAHMmf0aWCNh2qaF9NgNuxja6WeMyVGQx
KyWutIQJQQEC+ogRt1XFSJlhjBsz9iEa2ICYjPGun2BH0N9YTLRe3piENA+n76zip8AjxJcHxY4d
AAAAAAAA

--Apple-Mail=_83895B38-6419-4A23-BB2A-603EF61BA025--
