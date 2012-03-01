Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:5665 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755359Ab2CAWQX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Mar 2012 17:16:23 -0500
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 04/15] NFS: Reduce debugging noise from
 encode_compound_hdr
Date: Thu, 1 Mar 2012 22:15:59 +0000
Message-ID: <4360FE31-101D-48A1-B9C3-00CA6D8D1F87@netapp.com>
References: <20120301215755.2138.73488.stgit@degas.1015granger.net>
 <20120301220048.2138.1342.stgit@degas.1015granger.net>
In-Reply-To: <20120301220048.2138.1342.stgit@degas.1015granger.net>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_BAC80525-3443-4D98-8856-3DFFD2B06D67";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_BAC80525-3443-4D98-8856-3DFFD2B06D67
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=windows-1252

On Mar 1, 2012, at 5:00 PM, Chuck Lever wrote:

> Get rid of
>=20
>  encode_compound: tag=3D
>=20
> when XDR debugging is enabled.  The current Linux client never sets
> compound tags.
>=20
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>=20
> fs/nfs/nfs4xdr.c |    2 ++
> 1 files changed, 2 insertions(+), 0 deletions(-)
>=20
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index 4ca87cb..d1b7914d 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -889,7 +889,9 @@ static void encode_compound_hdr(struct xdr_stream =
*xdr,
> 	 * but this is not required as a MUST for the server to do so. =
*/
> 	hdr->replen =3D RPC_REPHDRSIZE + auth->au_rslack + 3 + =
hdr->taglen;
>=20
> +#if 0
> 	dprintk("encode_compound: tag=3D%.*s\n", (int)hdr->taglen, =
hdr->tag);
> +#endif

We probably don't want to #if 0 this out.  Either remove the line, or do =
something like:

if (hdr->taglen > 0)
	dprintk(=85);

This way, if we ever do have a tag set, it'll be displayed.

Thanks for suggesting this -- getting rid of useless dprintk output is a =
good thing!

-dros

> 	BUG_ON(hdr->taglen > NFS4_MAXTAGLEN);
> 	p =3D reserve_space(xdr, 4 + hdr->taglen + 8);
> 	p =3D xdr_encode_opaque(p, hdr->tag, hdr->taglen);
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--Apple-Mail=_BAC80525-3443-4D98-8856-3DFFD2B06D67
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
MBwGCSqGSIb3DQEJBTEPFw0xMjAzMDEyMjE1NTlaMCMGCSqGSIb3DQEJBDEWBBQ114N2xJnDIZV7
g4FHJd36NdXTEDANBgkqhkiG9w0BAQEFAASCAQC8UYyNNV5ISjG1WfwZlU2LOS/oZeNvhralROSC
9Z6cjByMMmopDNDBCkofdSjKG7fvuHJ+j6fKLG/GEsGd52nesejwwp1gV0G0P7/cItmCcRzjcsZ0
3LTMzbYXG9dW/dQD8LJjw3tIh81bRwJdnh6HjYWDIz3y/ARaoJicNbVfppY6eyN7cXJ3tHAWy+Kh
FEr8Xs7U7Yfu+gGZAKoir75Xq/QHJ/C0lVjy7maV82t/XuiBaebL4whaKQXnXPo8d+JXRph6Hycl
4LeW9AY0RGxMVWpe35njVYoNLVdSdykPRYI7l3oTM6quBeqHcnAlQQD81sMFHPM8LAQM2qs0iDSV
AAAAAAAA

--Apple-Mail=_BAC80525-3443-4D98-8856-3DFFD2B06D67--
