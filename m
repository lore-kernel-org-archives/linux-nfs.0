Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:10395 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753477Ab2E2PFz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 May 2012 11:05:55 -0400
Received: from vmwexceht02-prd.hq.netapp.com (vmwexceht02-prd.hq.netapp.com [10.106.76.240])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q4TF5tqc022798
	for <linux-nfs@vger.kernel.org>; Tue, 29 May 2012 08:05:55 -0700 (PDT)
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 5/8] NFSv4.1: Move NFSPROC4_CLNT_BIND_CONN_TO_SESSION to
 the end of the operations
Date: Tue, 29 May 2012 15:05:54 +0000
Message-ID: <ACF824E6-0473-4E05-9350-8808A180AC15@netapp.com>
References: <1337983402-24677-1-git-send-email-Trond.Myklebust@netapp.com>
 <1337983402-24677-2-git-send-email-Trond.Myklebust@netapp.com>
 <1337983402-24677-3-git-send-email-Trond.Myklebust@netapp.com>
 <1337983402-24677-4-git-send-email-Trond.Myklebust@netapp.com>
 <1337983402-24677-5-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1337983402-24677-5-git-send-email-Trond.Myklebust@netapp.com>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_4AD5D31B-208F-4DF7-B606-2AAD61950086";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_4AD5D31B-208F-4DF7-B606-2AAD61950086
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On May 25, 2012, at 6:03 PM, Trond Myklebust wrote:

> For backward compatibility with nfs-utils.

Can you expand on that a bit? I put them where they are because they are =
in order of operation id (bind_conn_to_session =3D 41, exchange_id =3D =
42).

If we really must only add to the end of the list, we really should have =
a comment above nfs4_procedures, etc.

-dros=20

>=20
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> Cc: Weston Andros Adamson <dros@netapp.com>
> ---
> fs/nfs/nfs4xdr.c     |    4 ++--
> include/linux/nfs4.h |    2 +-
> 2 files changed, 3 insertions(+), 3 deletions(-)
>=20
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index a6b95b7..1d4d259 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -7221,8 +7221,6 @@ struct rpc_procinfo	nfs4_procedures[] =3D {
> 	PROC(RELEASE_LOCKOWNER,	enc_release_lockowner,	=
dec_release_lockowner),
> 	PROC(SECINFO,		enc_secinfo,		dec_secinfo),
> #if defined(CONFIG_NFS_V4_1)
> -	PROC(BIND_CONN_TO_SESSION,
> -			enc_bind_conn_to_session, =
dec_bind_conn_to_session),
> 	PROC(EXCHANGE_ID,	enc_exchange_id,	=
dec_exchange_id),
> 	PROC(CREATE_SESSION,	enc_create_session,	=
dec_create_session),
> 	PROC(DESTROY_SESSION,	enc_destroy_session,	=
dec_destroy_session),
> @@ -7237,6 +7235,8 @@ struct rpc_procinfo	nfs4_procedures[] =3D {
> 	PROC(TEST_STATEID,	enc_test_stateid,	=
dec_test_stateid),
> 	PROC(FREE_STATEID,	enc_free_stateid,	=
dec_free_stateid),
> 	PROC(GETDEVICELIST,	enc_getdevicelist,	=
dec_getdevicelist),
> +	PROC(BIND_CONN_TO_SESSION,
> +			enc_bind_conn_to_session, =
dec_bind_conn_to_session),
> #endif /* CONFIG_NFS_V4_1 */
> };
>=20
> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
> index a2b71cb..54006a9 100644
> --- a/include/linux/nfs4.h
> +++ b/include/linux/nfs4.h
> @@ -593,7 +593,6 @@ enum {
> 	NFSPROC4_CLNT_SECINFO,
>=20
> 	/* nfs41 */
> -	NFSPROC4_CLNT_BIND_CONN_TO_SESSION,
> 	NFSPROC4_CLNT_EXCHANGE_ID,
> 	NFSPROC4_CLNT_CREATE_SESSION,
> 	NFSPROC4_CLNT_DESTROY_SESSION,
> @@ -608,6 +607,7 @@ enum {
> 	NFSPROC4_CLNT_TEST_STATEID,
> 	NFSPROC4_CLNT_FREE_STATEID,
> 	NFSPROC4_CLNT_GETDEVICELIST,
> +	NFSPROC4_CLNT_BIND_CONN_TO_SESSION,
> };
>=20
> /* nfs41 types */
> --=20
> 1.7.7.6
>=20


--Apple-Mail=_4AD5D31B-208F-4DF7-B606-2AAD61950086
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
MBwGCSqGSIb3DQEJBTEPFw0xMjA1MjkxNTA1NTRaMCMGCSqGSIb3DQEJBDEWBBTz7d66tLLSzw0v
befdaZPGnlUxLzANBgkqhkiG9w0BAQEFAASCAQCqhjNYg8OR4taAlOBWjq/KUyWb4Gq6/ANOanT/
YcP5EUDWebtm+dk0P9wFTYRuZFGY0WDw4MGfuyEeOYrhakhjV/isTYWgGMX8R7mTUoWSn6wGaWxD
H1LwBHeP48NTxbjR7kWAh1sysTxvCvaFNS5W/hP5MyGSaNunkxkEk9Riwc+kaoCM5JSfHGmXCx8S
9gD4mSY7RFCwQqxQGvVYUPOFMcoyLEDOzlbmCSfNgkx99QfgFqAb13c9wL4T8awbHPIqS34Yu4ks
Iy1SGRx2z8H8qih1CAD6U3/4mdF8qGjdGB0xqL/SeuXxiyfC5433Gcj1SFU/vOsuiV9N/1jY9uS1
AAAAAAAA

--Apple-Mail=_4AD5D31B-208F-4DF7-B606-2AAD61950086--
