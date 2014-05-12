Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:58573 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753013AbaELISB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 May 2014 04:18:01 -0400
Date: Mon, 12 May 2014 01:18:01 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org, Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 06/43] nfsd4: fix encoding of out-of-space replies
Message-ID: <20140512081801.GA14194@infradead.org>
References: <1399841568-19716-1-git-send-email-bfields@redhat.com>
 <1399841568-19716-7-git-send-email-bfields@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1399841568-19716-7-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, May 11, 2014 at 04:52:11PM -0400, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> If nfsd4_check_resp_size() returns an error then we should really be
> truncating the reply here, otherwise we may leave extra garbage at the
> end of the rpc reply.
> 
> Also add a warning to catch any cases where our reply-size estimates may
> be wrong in the case of a non-idempotent operation.
> 
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  fs/nfsd/nfs4xdr.c |   22 +++++++++++++++++++++-
>  1 file changed, 21 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 6cdd660..fb40dd1 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -3633,6 +3633,7 @@ nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
>  {
>  	struct nfs4_stateowner *so = resp->cstate.replay_owner;
>  	__be32 *statp;
> +	nfsd4_enc encoder;
>  	__be32 *p;
>  
>  	RESERVE_SPACE(8);
> @@ -3644,10 +3645,29 @@ nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
>  		goto status;
>  	BUG_ON(op->opnum < 0 || op->opnum >= ARRAY_SIZE(nfsd4_enc_ops) ||
>  	       !nfsd4_enc_ops[op->opnum]);
> -	op->status = nfsd4_enc_ops[op->opnum](resp, op->status, &op->u);
> +	encoder = nfsd4_enc_ops[op->opnum];
> +	op->status = encoder(resp, op->status, &op->u);

What is the point of the encoder variable that gets set and used a line
later the only time?

