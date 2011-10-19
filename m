Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:5632 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751546Ab1JSQIK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Oct 2011 12:08:10 -0400
Subject: Re: [PATCH] pnfsd: dlm: fix bug in DS tcp/tcp6 address string
Mime-Version: 1.0 (Apple Message framework v1251.1)
Content-Type: multipart/signed; boundary="Apple-Mail=_9FFC7050-9049-494B-8AFE-FE402C961701"; protocol="application/pkcs7-signature"; micalg=sha1
From: Weston Andros Adamson <dros@netapp.com>
In-Reply-To: <4E9E1F3A.2090709@tonian.com>
Date: Wed, 19 Oct 2011 12:07:53 -0400
Cc: Olga Kornievskaia <aglo@citi.umich.edu>,
        Michael Groshans <groshans@umich.edu>,
        NFS list <linux-nfs@vger.kernel.org>
Message-Id: <51129BFD-588C-49F4-9BE1-8119E32CD1BB@netapp.com>
References: <4E9E1F3A.2090709@tonian.com>
To: Benny Halevy <bhalevy@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--Apple-Mail=_9FFC7050-9049-494B-8AFE-FE402C961701
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=iso-8859-1

Looks good to me.

-dros

On Oct 18, 2011, at 8:52 PM, Benny Halevy wrote:

> squash into "pnfsd: Correctly set netid to tcp or tcp6 for non-local =
exports"
>=20
> Currently, the code looks for ':' using strcspn that requires a null =
terminated string
> while the address buffer isn't null terminated.
>=20
> Instead, just use strnchr to look for a ':' and if not found assume
> it's an IPv4 address, otherwise it's IPv6
>=20
> Signed-off-by: Benny Halevy <bhalevy@tonian.com>
> ---
> fs/nfsd/nfs4pnfsdlm.c |    9 ++-------
> 1 files changed, 2 insertions(+), 7 deletions(-)
>=20
> diff --git a/fs/nfsd/nfs4pnfsdlm.c b/fs/nfsd/nfs4pnfsdlm.c
> index abc4d83..d07a6037 100644
> --- a/fs/nfsd/nfs4pnfsdlm.c
> +++ b/fs/nfsd/nfs4pnfsdlm.c
> @@ -328,13 +328,8 @@ static int nfsd4_pnfs_dlm_getdevinfo(struct =
super_block *sb,
> 		memcpy(daddr->r_addr.data + len, ".8.1", 4);
> 		daddr->r_addr.len =3D len + 4;
>=20
> -		if (strcspn(daddr->r_addr.data, ":") - 1 =3D=3D =
daddr->r_addr.len) {
> -			daddr->r_netid.data =3D "tcp";
> -			daddr->r_netid.len =3D 3;
> -		} else {
> -			daddr->r_netid.data =3D "tcp6";
> -			daddr->r_netid.len =3D 4;
> -		}
> +		daddr->r_netid.data =3D "tcp6";
> +		daddr->r_netid.len =3D strnchr(daddr->r_addr.data, len, =
':') ? 4 : 3;
>=20
> 		fdev.fl_device_list[i].fl_multipath_length =3D 1;
> 		fdev.fl_device_list[i].fl_multipath_list =3D daddr;
> --=20
> 1.7.6
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--Apple-Mail=_9FFC7050-9049-494B-8AFE-FE402C961701
Content-Disposition: attachment;
	filename=smime.p7s
Content-Type: application/pkcs7-signature;
	name=smime.p7s
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
MBwGCSqGSIb3DQEJBTEPFw0xMTEwMTkxNjA3NTNaMCMGCSqGSIb3DQEJBDEWBBSNbQrb454sUXyI
npR+M0PI+2jiozANBgkqhkiG9w0BAQEFAASCAQCisncsJuXdxV6GU0ly+K0+pLBxWnQWhJODBx96
nVvqvATQWKOjbfLjRVVLnXiwS1Oxg1bUjnPjjY2sEtsmZkU80RwvvWxgetOdcspE0NSn3HPRpStC
dZI784/Yw1GcTEkFhd3GC3NZIcy3EHWTQuSRcUM3rlVI/Scs/SrjA8KuFyG1bqVR7qhaeFbh1rzZ
PKKy5aiLsiAB/fDYPszU0R0Wr8+4U8PA4AwzP021yeAvAAiP23Bl6giE+RglHljqE6XYQ+b6KFr/
3xHnP9VMJkub+vBV4tD0Z+RFGIsWjk2BEo4s715Fcio2YoU4ruhqJ6YFfhXGhpzaoqJgxfx+OGi4
AAAAAAAA

--Apple-Mail=_9FFC7050-9049-494B-8AFE-FE402C961701--
