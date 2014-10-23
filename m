Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f45.google.com ([209.85.192.45]:45800 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754146AbaJWLyd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Oct 2014 07:54:33 -0400
Received: by mail-qg0-f45.google.com with SMTP id q107so533021qgd.4
        for <linux-nfs@vger.kernel.org>; Thu, 23 Oct 2014 04:54:32 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Thu, 23 Oct 2014 07:54:30 -0400
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org,
        Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] nfsd4: fix response size estimation for OP_SEQUENCE
Message-ID: <20141023075430.2b21eab7@tlielax.poochiereds.net>
In-Reply-To: <20141021131406.GE9863@fieldses.org>
References: <20141017212446.GC3474@fieldses.org>
	<20141021103631.GB21863@infradead.org>
	<20141021131406.GE9863@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 21 Oct 2014 09:14:06 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Tue, Oct 21, 2014 at 03:36:31AM -0700, Christoph Hellwig wrote:
> > On Fri, Oct 17, 2014 at 05:24:46PM -0400, J. Bruce Fields wrote:
> > > From: "J. Bruce Fields" <bfields@redhat.com>
> > > 
> > > We added this new estimator function but forgot to hook it up.  The
> > > effect is that NFSv4.1 won't do zero-copy reads.
> > > 
> > > The estimate was also wrong by 8 bytes.
> > 
> > This would affect 4.0 and 4.2 as well, wouldn't it?
> 
> It was introduced in 4.1, so yes to 4.2, no to 4.1.
> 
> Also, this still had an arithmetic mistake. Fixed version follows.
> 
> Also my tests are failing due to an unrelated crash in 18-rc1 which I
> want to track down before sending this in.
> 
> --b.
> 
> commit d1d84c9626bb3a519863b3ffc40d347166f9fb83
> Author: J. Bruce Fields <bfields@redhat.com>
> Date:   Thu Aug 21 15:04:31 2014 -0400
> 
>     nfsd4: fix response size estimation for OP_SEQUENCE
>     
>     We added this new estimator function but forgot to hook it up.  The
>     effect is that NFSv4.1 (and greater) won't do zero-copy reads.
>     
>     The estimate was also wrong by 8 bytes.
>     
>     Fixes: ccae70a9ee41 "nfsd4: estimate sequence response size"
>     Cc: stable@vger.kernel.org
>     Reported-by: Chuck Lever <chucklever@gmail.com>
>     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index cdeb3cf..f4bd578 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -1589,7 +1589,8 @@ static inline u32 nfsd4_rename_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op
>  static inline u32 nfsd4_sequence_rsize(struct svc_rqst *rqstp,
>  				       struct nfsd4_op *op)
>  {
> -	return NFS4_MAX_SESSIONID_LEN + 20;
> +	return (op_encode_hdr_size
> +		+ XDR_QUADLEN(NFS4_MAX_SESSIONID_LEN) + 5) * sizeof(__be32);
>  }
>  
>  static inline u32 nfsd4_setattr_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
> @@ -1893,6 +1894,7 @@ static struct nfsd4_operation nfsd4_ops[] = {
>  		.op_func = (nfsd4op_func)nfsd4_sequence,
>  		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_AS_FIRST_OP,
>  		.op_name = "OP_SEQUENCE",
> +		.op_rsize_bop = (nfsd4op_rsize)nfsd4_sequence_rsize,
>  	},
>  	[OP_DESTROY_CLIENTID] = {
>  		.op_func = (nfsd4op_func)nfsd4_destroy_clientid,
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


With the earlier version of this patch, I was seeing a bunch of these
messages:

[56121.351277] RPC request reserved 124 but used 136
[56121.532839] RPC request reserved 204 but used 208
[56121.574473] RPC request reserved 116 but used 128
[56121.634628] RPC request reserved 204 but used 208
[56121.663675] RPC request reserved 116 but used 128

...but this version seems to have silenced those warnings. You can add:

Tested-by: Jeff Layton <jlayton@primarydata.com>
