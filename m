Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:36455 "EHLO
        mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755796AbdELSmX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 12 May 2017 14:42:23 -0400
Received: by mail-qk0-f181.google.com with SMTP id u75so54828422qka.3
        for <linux-nfs@vger.kernel.org>; Fri, 12 May 2017 11:42:23 -0700 (PDT)
Message-ID: <1494614541.4227.12.camel@redhat.com>
Subject: Re: [PATCH 33/33] nfsd4: const-ify nfsd4_ops
From: Jeff Layton <jlayton@redhat.com>
To: Christoph Hellwig <hch@lst.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Date: Fri, 12 May 2017 14:42:21 -0400
In-Reply-To: <20170512161701.22468-34-hch@lst.de>
References: <20170512161701.22468-1-hch@lst.de>
         <20170512161701.22468-34-hch@lst.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2017-05-12 at 18:17 +0200, Christoph Hellwig wrote:
> nfsd4_ops contains function pointers, and marking it as constant avoids
> it being able to be used as an attach vector for code injections.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/nfsd/nfs4proc.c | 13 ++++++-------
>  1 file changed, 6 insertions(+), 7 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index e814c1946f6e..fe6cb5b6d31c 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -1584,7 +1584,7 @@ struct nfsd4_operation {
>  			union nfsd4_op_u *);
>  };
>  
> -static struct nfsd4_operation nfsd4_ops[];
> +static const struct nfsd4_operation nfsd4_ops[];
>  
>  static const char *nfsd4_op_name(unsigned opnum);
>  
> @@ -1621,7 +1621,7 @@ static __be32 nfs41_check_op_ordering(struct nfsd4_compoundargs *args)
>  	return nfs_ok;
>  }
>  
> -static inline struct nfsd4_operation *OPDESC(struct nfsd4_op *op)
> +static inline const struct nfsd4_operation *OPDESC(struct nfsd4_op *op)
>  {
>  	return &nfsd4_ops[op->opnum];
>  }
> @@ -1639,10 +1639,9 @@ static bool need_wrongsec_check(struct svc_rqst *rqstp)
>  	struct nfsd4_compoundargs *argp = rqstp->rq_argp;
>  	struct nfsd4_op *this = &argp->ops[resp->opcnt - 1];
>  	struct nfsd4_op *next = &argp->ops[resp->opcnt];
> -	struct nfsd4_operation *thisd;
> -	struct nfsd4_operation *nextd;
> +	const struct nfsd4_operation *thisd = OPDESC(this);
> +	const struct nfsd4_operation *nextd;
>  
> -	thisd = OPDESC(this);
>  	/*
>  	 * Most ops check wronsec on our own; only the putfh-like ops
>  	 * have special rules.
> @@ -1695,7 +1694,7 @@ nfsd4_proc_compound(struct svc_rqst *rqstp)
>  	struct nfsd4_compoundargs *args = rqstp->rq_argp;
>  	struct nfsd4_compoundres *resp = rqstp->rq_resp;
>  	struct nfsd4_op	*op;
> -	struct nfsd4_operation *opdesc;
> +	const struct nfsd4_operation *opdesc;
>  	struct nfsd4_compound_state *cstate = &resp->cstate;
>  	struct svc_fh *current_fh = &cstate->current_fh;
>  	struct svc_fh *save_fh = &cstate->save_fh;
> @@ -2109,7 +2108,7 @@ static inline u32 nfsd4_seek_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
>  	return (op_encode_hdr_size + 3) * sizeof(__be32);
>  }
>  
> -static struct nfsd4_operation nfsd4_ops[] = {
> +static const struct nfsd4_operation nfsd4_ops[] = {
>  	[OP_ACCESS] = {
>  		.op_func = nfsd4_access,
>  		.op_name = "OP_ACCESS",

...and I'll save us some emails. You can add my Reviewed-by to the whole
set. Nice cleanup/prophylaxis!

-- 
Jeff Layton <jlayton@redhat.com>
