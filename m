Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:33505 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754974Ab2DTTnc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Apr 2012 15:43:32 -0400
Received: from vmwexceht05-prd.hq.netapp.com (vmwexceht05-prd.hq.netapp.com [10.106.77.35])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q3KJhGjH009928
	for <linux-nfs@vger.kernel.org>; Fri, 20 Apr 2012 12:43:16 -0700 (PDT)
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS4: fix referrals with IPv6 mounts
Date: Fri, 20 Apr 2012 19:43:14 +0000
Message-ID: <879899F5-8B07-4232-A7AA-C282B4D1F618@netapp.com>
References: <1334949705-33393-1-git-send-email-dros@netapp.com>
In-Reply-To: <1334949705-33393-1-git-send-email-dros@netapp.com>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_E902A3D4-C568-435C-8CEA-ABDFF7C8AA29";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_E902A3D4-C568-435C-8CEA-ABDFF7C8AA29
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

Oops, this should probably CC stable@ too.

-dros

On Apr 20, 2012, at 3:21 PM, Weston Andros Adamson wrote:

> nfs4_path() was parsing the path component by splitting on the first =
colon.
> This is wrong when an IPv6 address is used to mount a server.
>=20
> For example, having mounted 'fc00::10:/export', nfs4_path() returned
> ':10:/export'.  This causes referrals (using IPv4 or IPv6 addresses) =
to fail
> in nfs4_validate_fspath().
>=20
> Parsing the path component by using the *last* colon works with
> IPv6 as well as IPv4 addrs.
>=20
> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
> ---
> fs/nfs/nfs4namespace.c |    2 +-
> 1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
> index 9c8eca3..dd3dd30 100644
> --- a/fs/nfs/nfs4namespace.c
> +++ b/fs/nfs/nfs4namespace.c
> @@ -59,7 +59,7 @@ static char *nfs4_path(struct dentry *dentry, char =
*buffer, ssize_t buflen)
> 	char *limit;
> 	char *path =3D nfs_path(&limit, dentry, buffer, buflen);
> 	if (!IS_ERR(path)) {
> -		char *colon =3D strchr(path, ':');
> +		char *colon =3D strrchr(path, ':');
> 		if (colon && colon < limit)
> 			path =3D colon + 1;
> 	}
> --=20
> 1.7.4.4
>=20


--Apple-Mail=_E902A3D4-C568-435C-8CEA-ABDFF7C8AA29
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
MBwGCSqGSIb3DQEJBTEPFw0xMjA0MjAxOTQzMTdaMCMGCSqGSIb3DQEJBDEWBBT4sUA925KqSRqR
OVssCGO1U2ddfDANBgkqhkiG9w0BAQEFAASCAQCDoxQ+FhXB0vgYHNSZH8V+hoHDNxr3vGnCEGSv
ANv2jf/PzfzkTwVEXt+yizGiPvQ0kFqQhDAVJCW/780TAqCHizl7vF634APaJC23dRfJSjatXQyz
x8v9jo8043SPJzWVf4yKkUP5AxZEaY5SBKIvsq6PA5UiiTGd0IqXGdXyoP3P+NFTEVM65FqLePZi
N+1eGlMx60o6fj15zzsl+qbW+1yc7rkFcJPh6tDnP91G3WbhWlOqvRQOVYbrVsolDWIrGi9T1jYA
iy6YNeRbqgR7VOi+b0RKEndaRg9i7jqBvw+U1262vqDrB8NuUX0nvSSlrxAaa9SIXEwxjvX/QJyp
AAAAAAAA

--Apple-Mail=_E902A3D4-C568-435C-8CEA-ABDFF7C8AA29--
