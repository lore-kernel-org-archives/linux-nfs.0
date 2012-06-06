Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:12545 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753977Ab2FFN7d (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Jun 2012 09:59:33 -0400
Received: from vmwexceht02-prd.hq.netapp.com (vmwexceht02-prd.hq.netapp.com [10.106.76.240])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q56DxHUA013091
	for <linux-nfs@vger.kernel.org>; Wed, 6 Jun 2012 06:59:17 -0700 (PDT)
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>,
        "Isaman, Fred" <Fred.Isaman@netapp.com>
Subject: Re: [PATCH] NFS: Fix a commit bug
Date: Wed, 6 Jun 2012 13:59:15 +0000
Message-ID: <73EB71C8-FD1B-4508-8474-D87C9B7312EC@netapp.com>
References: <1338936204-20168-1-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1338936204-20168-1-git-send-email-Trond.Myklebust@netapp.com>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_4177BF56-1599-4740-AE63-53D238DDCC82";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_4177BF56-1599-4740-AE63-53D238DDCC82
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

ACK - This fixes the problem I was seeing!

For the list, we were seeing duplicate writes sent to unstable servers =
even though the COMMIT succeeds (with matching verf):

 - mount a server that returns writes with committed =3D UNSTABLE4
 - run "dd if=3D/dev/zero of=3D/mnt/foo bs=3D1024 count=3D10240"
 - umount
 - in wireshark, you'll see the COMMIT succeed, but after a short pause =
there will be a flurry of FILE_SYNC4 writes that are duplicates (same =
ranges, data) of the writes associated with the COMMIT.

-dros

On Jun 5, 2012, at 6:43 PM, Trond Myklebust wrote:

> The new commit code fails to copy the verifier into the wb_verf field
> of _all_ the nfs_page structures; it only copies it into the first =
entry.
> The consequence is that most requests end up failing to match in
> nfs_commit_release.
>=20
> Fix is to copy the verifier into the req->wb_verf field in
> nfs_write_completion.
>=20
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> Cc: Fred Isaman <iisaman@netapp.com>
> ---
> fs/nfs/direct.c         |    4 ++--
> fs/nfs/write.c          |    7 ++++---
> include/linux/nfs_xdr.h |    2 ++
> 3 files changed, 8 insertions(+), 5 deletions(-)
>=20
> diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
> index 23d170b..b5385a7 100644
> --- a/fs/nfs/direct.c
> +++ b/fs/nfs/direct.c
> @@ -710,12 +710,12 @@ static void nfs_direct_write_completion(struct =
nfs_pgio_header *hdr)
> 			if (dreq->flags =3D=3D =
NFS_ODIRECT_RESCHED_WRITES)
> 				bit =3D NFS_IOHDR_NEED_RESCHED;
> 			else if (dreq->flags =3D=3D 0) {
> -				memcpy(&dreq->verf, &req->wb_verf,
> +				memcpy(&dreq->verf, hdr->verf,
> 				       sizeof(dreq->verf));
> 				bit =3D NFS_IOHDR_NEED_COMMIT;
> 				dreq->flags =3D NFS_ODIRECT_DO_COMMIT;
> 			} else if (dreq->flags =3D=3D =
NFS_ODIRECT_DO_COMMIT) {
> -				if (memcmp(&dreq->verf, &req->wb_verf, =
sizeof(dreq->verf))) {
> +				if (memcmp(&dreq->verf, hdr->verf, =
sizeof(dreq->verf))) {
> 					dreq->flags =3D =
NFS_ODIRECT_RESCHED_WRITES;
> 					bit =3D NFS_IOHDR_NEED_RESCHED;
> 				} else
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index e6fe3d6..4d6861c 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -80,6 +80,7 @@ struct nfs_write_header *nfs_writehdr_alloc(void)
> 		INIT_LIST_HEAD(&hdr->rpc_list);
> 		spin_lock_init(&hdr->lock);
> 		atomic_set(&hdr->refcnt, 0);
> +		hdr->verf =3D &p->verf;
> 	}
> 	return p;
> }
> @@ -619,6 +620,7 @@ static void nfs_write_completion(struct =
nfs_pgio_header *hdr)
> 			goto next;
> 		}
> 		if (test_bit(NFS_IOHDR_NEED_COMMIT, &hdr->flags)) {
> +			memcpy(&req->wb_verf, hdr->verf, =
sizeof(req->wb_verf));
> 			nfs_mark_request_commit(req, hdr->lseg, &cinfo);
> 			goto next;
> 		}
> @@ -1255,15 +1257,14 @@ static void nfs_writeback_release_common(void =
*calldata)
> 	struct nfs_write_data	*data =3D calldata;
> 	struct nfs_pgio_header *hdr =3D data->header;
> 	int status =3D data->task.tk_status;
> -	struct nfs_page *req =3D hdr->req;
>=20
> 	if ((status >=3D 0) && nfs_write_need_commit(data)) {
> 		spin_lock(&hdr->lock);
> 		if (test_bit(NFS_IOHDR_NEED_RESCHED, &hdr->flags))
> 			; /* Do nothing */
> 		else if (!test_and_set_bit(NFS_IOHDR_NEED_COMMIT, =
&hdr->flags))
> -			memcpy(&req->wb_verf, &data->verf, =
sizeof(req->wb_verf));
> -		else if (memcmp(&req->wb_verf, &data->verf, =
sizeof(req->wb_verf)))
> +			memcpy(hdr->verf, &data->verf, =
sizeof(*hdr->verf));
> +		else if (memcmp(hdr->verf, &data->verf, =
sizeof(*hdr->verf)))
> 			set_bit(NFS_IOHDR_NEED_RESCHED, &hdr->flags);
> 		spin_unlock(&hdr->lock);
> 	}
> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
> index 7519bae..8aadd90 100644
> --- a/include/linux/nfs_xdr.h
> +++ b/include/linux/nfs_xdr.h
> @@ -1237,6 +1237,7 @@ struct nfs_pgio_header {
> 	struct list_head	rpc_list;
> 	atomic_t		refcnt;
> 	struct nfs_page		*req;
> +	struct nfs_writeverf	*verf;
> 	struct pnfs_layout_segment *lseg;
> 	loff_t			io_start;
> 	const struct rpc_call_ops *mds_ops;
> @@ -1274,6 +1275,7 @@ struct nfs_write_data {
> struct nfs_write_header {
> 	struct nfs_pgio_header	header;
> 	struct nfs_write_data	rpc_data;
> +	struct nfs_writeverf	verf;
> };
>=20
> struct nfs_mds_commit_info {
> --=20
> 1.7.10.2
>=20


--Apple-Mail=_4177BF56-1599-4740-AE63-53D238DDCC82
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
MBwGCSqGSIb3DQEJBTEPFw0xMjA2MDYxMzU5MjFaMCMGCSqGSIb3DQEJBDEWBBTKEdYR6vAZX3kC
4XKpWHZzQ4BiRDANBgkqhkiG9w0BAQEFAASCAQANAFDuTVPqyk6rO6VgK5tFgiGMswolEGE6Rp6+
rJKFEZNjOp8YgAiGAcBZgWxZ1zsaAU64X7MAjBOi3EhxuDJrEPLgqTfpwFCHUhlkUPBsHiHmHvop
Z45/69H/rLXQKa1/6gcp2xcOtJTsNuCu+3wYQ1GOAKtruAbviJKWhJ8ou1Grz6qxEvaSPZZ5B/yT
gKW+Zz6upeCcAYarl+LhpWk/cJ4TN9RrHrCleoknmnZH3/J8WACcVXBpb/wc+O8qgxIBrUt718xQ
t9TOrR9yxPffl7rnmWRSgf1uzkDRCTPAyzDKqVMZqEHobtHmWv263xj6jRqJTuV2Ksz/MuMqUDmG
AAAAAAAA

--Apple-Mail=_4177BF56-1599-4740-AE63-53D238DDCC82--
