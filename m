Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:35503 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752821AbdBTNTb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Feb 2017 08:19:31 -0500
Received: by mail-io0-f193.google.com with SMTP id m98so4539135iod.2
        for <linux-nfs@vger.kernel.org>; Mon, 20 Feb 2017 05:19:31 -0800 (PST)
Subject: Re: [PATCH 1/6] NFSv4: fix getacl head length estimation
To: "J. Bruce Fields" <bfields@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>
References: <1487470070-32358-1-git-send-email-bfields@redhat.com>
 <1487470070-32358-2-git-send-email-bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org, Andreas Gruenbacher <agruenba@redhat.com>,
        Weston Andros Adamson <dros@primarydata.com>,
        Kinglong Mee <kinglongmee@gmail.com>
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <81d554b6-7b8d-51e8-c7ad-b23acd70f717@gmail.com>
Date: Mon, 20 Feb 2017 21:19:14 +0800
MIME-Version: 1.0
In-Reply-To: <1487470070-32358-2-git-send-email-bfields@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2/19/2017 10:07, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> Bitmap and attrlen follow immediately after the op reply header, so I'm
> not sure what this extra "+1" was for.
> 
> Consequences of this are just minor efficiency (extra calls to
> xdr_shrink_bufhead).
> 
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  fs/nfs/nfs4xdr.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index e9255cb453e6..bb95dd2edeef 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -2524,7 +2524,7 @@ static void nfs4_xdr_enc_getacl(struct rpc_rqst *req, struct xdr_stream *xdr,
>  	encode_compound_hdr(xdr, req, &hdr);
>  	encode_sequence(xdr, &args->seq_args, &hdr);
>  	encode_putfh(xdr, args->fh, &hdr);
> -	replen = hdr.replen + op_decode_hdr_maxsz + 1;

The +1 is set at 28f566942c "NFS: use dynamically computed compound_hdr.replen
for xdr_inline_pages offset", 

@@ -1827,20 +1806,18 @@ nfs4_xdr_enc_getacl(struct rpc_rqst *req, __be32 *p,
        xdr_init_encode(&xdr, &req->rq_snd_buf, p);
        encode_compound_hdr(&xdr, req, &hdr);
        encode_putfh(&xdr, args->fh, &hdr);
+       replen = hdr.replen + nfs4_fattr_bitmap_maxsz + 1;
        encode_getattr_two(&xdr, FATTR4_WORD0_ACL, 0, &hdr);

-       /* set up reply buffer: */
-       replen = (RPC_REPHDRSIZE + auth->au_rslack + NFS4_dec_getacl_sz) << 2;
-       xdr_inline_pages(&req->rq_rcv_buf, replen,
+       xdr_inline_pages(&req->rq_rcv_buf, replen << 2,
                args->acl_pages, args->acl_pgbase, args->acl_len);
        encode_nops(&hdr);
        return 0;

#define NFS4_dec_getacl_sz      (compound_decode_hdr_maxsz + \
                                decode_sequence_maxsz + \
                                decode_putfh_maxsz + \
                                *decode_getacl_maxsz*)

#define decode_getacl_maxsz     (op_decode_hdr_maxsz + \
                                 nfs4_fattr_bitmap_maxsz + 1)

But, forget remove it at commit bf118a342f,
"NFSv4: include bitmap in nfsv4 get acl data".

Reviewed-by: Kinglong Mee <kinglongmee@gmail.com>

thanks,
Kinglong Mee
> +	replen = hdr.replen + op_decode_hdr_maxsz;
>  	encode_getattr_two(xdr, FATTR4_WORD0_ACL, 0, &hdr);
>  
>  	xdr_inline_pages(&req->rq_rcv_buf, replen << 2,
> 
