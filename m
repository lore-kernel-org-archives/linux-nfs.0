Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:57924 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752053AbcHPTOU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Aug 2016 15:14:20 -0400
Date: Tue, 16 Aug 2016 15:14:19 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: eliminate cb_minorversion field
Message-ID: <20160816191419.GA32722@fieldses.org>
References: <1471368567-28954-1-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1471368567-28954-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 16, 2016 at 01:29:27PM -0400, Jeff Layton wrote:
> We already have that info in the client pointer. No need to pass around
> a copy.

Thanks, applying for 4.9.--b.

> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/nfsd/nfs4callback.c | 7 +++----
>  fs/nfsd/state.h        | 1 -
>  2 files changed, 3 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> index 04c68d900324..dbef646c6a2d 100644
> --- a/fs/nfsd/nfs4callback.c
> +++ b/fs/nfsd/nfs4callback.c
> @@ -448,7 +448,7 @@ static int decode_cb_sequence4res(struct xdr_stream *xdr,
>  {
>  	int status;
>  
> -	if (cb->cb_minorversion == 0)
> +	if (cb->cb_clp->cl_minorversion == 0)
>  		return 0;
>  
>  	status = decode_cb_op_status(xdr, OP_CB_SEQUENCE, &cb->cb_seq_status);
> @@ -485,7 +485,7 @@ static void nfs4_xdr_enc_cb_recall(struct rpc_rqst *req, struct xdr_stream *xdr,
>  	const struct nfs4_delegation *dp = cb_to_delegation(cb);
>  	struct nfs4_cb_compound_hdr hdr = {
>  		.ident = cb->cb_clp->cl_cb_ident,
> -		.minorversion = cb->cb_minorversion,
> +		.minorversion = cb->cb_clp->cl_minorversion,
>  	};
>  
>  	encode_cb_compound4args(xdr, &hdr);
> @@ -594,7 +594,7 @@ static void nfs4_xdr_enc_cb_layout(struct rpc_rqst *req,
>  		container_of(cb, struct nfs4_layout_stateid, ls_recall);
>  	struct nfs4_cb_compound_hdr hdr = {
>  		.ident = 0,
> -		.minorversion = cb->cb_minorversion,
> +		.minorversion = cb->cb_clp->cl_minorversion,
>  	};
>  
>  	encode_cb_compound4args(xdr, &hdr);
> @@ -862,7 +862,6 @@ static void nfsd4_cb_prepare(struct rpc_task *task, void *calldata)
>  	struct nfs4_client *clp = cb->cb_clp;
>  	u32 minorversion = clp->cl_minorversion;
>  
> -	cb->cb_minorversion = minorversion;
>  	/*
>  	 * cb_seq_status is only set in decode_cb_sequence4res,
>  	 * and so will remain 1 if an rpc level failure occurs.
> diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
> index b95adf9a1595..0bdc79cb359c 100644
> --- a/fs/nfsd/state.h
> +++ b/fs/nfsd/state.h
> @@ -63,7 +63,6 @@ typedef struct {
>  
>  struct nfsd4_callback {
>  	struct nfs4_client *cb_clp;
> -	u32 cb_minorversion;
>  	struct rpc_message cb_msg;
>  	const struct nfsd4_callback_ops *cb_ops;
>  	struct work_struct cb_work;
> -- 
> 2.7.4
