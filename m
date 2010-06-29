From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: [PATCH] SQUASHME: pnfs: check for read_buf error in
	decode_pnfs_layoutrecall_args
Date: Tue, 29 Jun 2010 08:22:25 -0400
Message-ID: <AANLkTiku06tjr1NCt4kJMJOlDne11zhRHKkJMc67-DvR@mail.gmail.com>
References: <1277808956-7694-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:50669 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751472Ab0F2MW1 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jun 2010 08:22:27 -0400
Received: by pxi8 with SMTP id 8so2275287pxi.19
        for <linux-nfs@vger.kernel.org>; Tue, 29 Jun 2010 05:22:26 -0700 (PDT)
In-Reply-To: <1277808956-7694-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I see that NFS4ERR_RESOURCE is returned throughout callback_xdr.c ,but
it is not a legal error return for NFSv4.1. -ENOMEM would be better.

-->Andy

On Tue, Jun 29, 2010 at 6:55 AM, Benny Halevy <bhalevy@panasas.com> wro=
te:
> read_buf may return NULL. return NFS4ERR_RESOURCE in this case.
>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
> =A0fs/nfs/callback_xdr.c | =A0 =A08 ++++++++
> =A01 files changed, 8 insertions(+), 0 deletions(-)
>
> diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
> index 7e34bb3..2f69f0d 100644
> --- a/fs/nfs/callback_xdr.c
> +++ b/fs/nfs/callback_xdr.c
> @@ -247,6 +247,10 @@ static __be32 decode_pnfs_layoutrecall_args(stru=
ct svc_rqst *rqstp,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0p =3D read_buf(xdr, 2 * sizeof(uint64_=
t));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(p =3D=3D NULL)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 status =3D htonl(NFS4ER=
R_RESOURCE);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0p =3D xdr_decode_hyper(p, &args->cbl_s=
eg.offset);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0p =3D xdr_decode_hyper(p, &args->cbl_s=
eg.length);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0status =3D decode_stateid(xdr, &args->=
cbl_stateid);
> @@ -254,6 +258,10 @@ static __be32 decode_pnfs_layoutrecall_args(stru=
ct svc_rqst *rqstp,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
> =A0 =A0 =A0 =A0} else if (args->cbl_recall_type =3D=3D RETURN_FSID) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0p =3D read_buf(xdr, 2 * sizeof(uint64_=
t));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(p =3D=3D NULL)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 status =3D htonl(NFS4ER=
R_RESOURCE);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0p =3D xdr_decode_hyper(p, &args->cbl_f=
sid.major);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0p =3D xdr_decode_hyper(p, &args->cbl_f=
sid.minor);
> =A0 =A0 =A0 =A0}
> --
> 1.6.6.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
