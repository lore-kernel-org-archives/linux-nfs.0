Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:50264 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755821Ab1GFUTV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Jul 2011 16:19:21 -0400
Date: Wed, 6 Jul 2011 16:19:20 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [RFC][PATCH 2/2] nfsd41: try to check reply size before
 operation
Message-ID: <20110706201920.GA32275@fieldses.org>
References: <4E0C31B5.9090302@cn.fujitsu.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E0C31B5.9090302@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Jun 30, 2011 at 04:20:05PM +0800, Mi Jinlong wrote:
> Implementing each operation's enc_size, and try to check reply size 
> before operation.

This is one of our remaining server 4.1 todo's, and it's a lot of
not-especially-fun work--thanks for taking it on.

> @@ -3161,222 +3244,313 @@ struct nfsd4_enc_op {
>  static struct nfsd4_enc_op nfsd4_enc_ops[] = {
>  	[OP_ACCESS] = {
>  		.enc_func = (nfsd4_enc)nfsd4_encode_access,
> +		.enc_size = nfsd4_enc_access_sz,

Perhaps the new enc_size field should go into the nfsd4_operation array
instead of here in the nfsd4_enc_op array.

> +static u32 get_ops_max_rsz(struct nfsd4_compoundres *resp)
> +{
> +	struct nfsd4_compoundargs *args = resp->rqstp->rq_argp;
> +	struct nfsd4_op op = args->ops[resp->opcnt];
> +	int length = 0, maxcount = 0;
> +
> +	switch (op.opnum) {
> +	case OP_READ:
> +		maxcount = svc_max_payload(resp->rqstp);
> +		if (maxcount > op.u.read.rd_length)
> +			length = op.u.read.rd_length;
> +		else
> +			length = maxcount;
> +		break;
> +
> +	case OP_READDIR:
> +		if (op.u.readdir.rd_maxcount < PAGE_SIZE)
> +			length = op.u.readdir.rd_maxcount;
> +		else
> +			length = PAGE_SIZE;
> +		break;
> +	case OP_READLINK:
> +		length = PATH_MAX;
> +		break;

OP_GETATTR also needs special handling, as it may include
arbitrary-length acls and file owners.

Maybe we can enforce a small limit on file owners and not have to
calculate that on the fly.  ACLs, though, can definitely be very large.

Also, to prevent this switch from getting too long, I think it would be
better to add something like a get_max_resp_size() callback as another
field of the nfsd4_operation structure, and allow it to be NULL for most
operations (in which case enc_size will be used instead).

>  void
> @@ -3396,7 +3570,7 @@ nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
>  	       !nfsd4_enc_ops[op->opnum].enc_func);
>  	op->status = nfsd4_enc_ops[op->opnum].enc_func(resp, op->status, &op->u);
>  	/* nfsd4_check_drc_limit guarantees enough room for error status */
> -	if (!op->status && nfsd4_check_drc_limit(resp))
> +	if (!op->status && nfsd4_check_resp_limit(resp))
>  		op->status = nfserr_rep_too_big_to_cache;
>  status:

By the time we get here it's too late--we've already performed the
operation.

For getattr, readlink, readdir, etc., I think that's OK, as those
operations don't change anything.

But if it's a CREATE that crosses the limit, for example, then this
would be a problem: we'd create the file, and *then* return
rep_too_big_to_cache.

So I think this check should go in nfsd4_proc_compound(), before the
call to op_func().

--b.
