Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:56756 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754710Ab1ESBCc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 May 2011 21:02:32 -0400
Date: Wed, 18 May 2011 21:02:31 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsd41: check the size of request
Message-ID: <20110519010231.GE26545@fieldses.org>
References: <4DD32BCF.8020905@cn.fujitsu.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4DD32BCF.8020905@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, May 18, 2011 at 10:15:43AM +0800, Mi Jinlong wrote:
> This patch just check request's size when it consists SEQUENCE.
> 
> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
> ---
>  fs/nfsd/nfs4state.c |   33 +++++++++++++++++++++++++++++++++
>  1 files changed, 33 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 4cf04e1..de4e6d4 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1725,6 +1725,38 @@ static void nfsd4_sequence_check_conn(struct nfsd4_conn *new, struct nfsd4_sessi
>  	return;
>  }
>  
> +static int nfsd4_check_request_size(struct nfsd4_compoundargs *args,
> +				    struct nfsd4_compound_state *cstate)
> +{
> +	int status = 0;
> +	struct xdr_buf *xb = &args->rqstp->rq_arg;
> +	struct nfsd4_session *session = NULL;
> +	u32 length, tlen = 0, pad = 8;
> +
> +	if (!nfsd4_has_session(cstate))
> +		return status;

If we're only called from nfsd4_sequence(), then this check is
redundant.  (It should always return true.)

> +
> +	session = cstate->session;
> +	if (session == NULL)
> +		return status;

Ditto, cstate->session was set by the caller just before calling us.

> +
> +	if (xb->page_len == 0) {
> +		length = (char *)args->p - (char *)xb->head[0].iov_base + pad;
> +	} else {
> +		if (xb->tail[0].iov_base && xb->tail[0].iov_len > 0)
> +			tlen = (char *)args->p - (char *)xb->tail[0].iov_base;
> +
> +		 length = xb->head[0].iov_len + xb->page_len + tlen + pad;
> +	}

There's gotta be something simpler....  Looking at svc_tcp_recvfrom.
Won't xb->len do it?

> +	dprintk("%s length %u, xb->page_len %u tlen %u pad %u\n", __func__,
> +		length, xb->page_len, tlen, pad);
> +
> +	if (length > session->se_fchannel.maxreq_sz)
> +		return nfserr_req_too_big;
> +
> +	return status;
> +}
> +
>  __be32
>  nfsd4_sequence(struct svc_rqst *rqstp,
>  	       struct nfsd4_compound_state *cstate,
> @@ -1789,6 +1821,7 @@ nfsd4_sequence(struct svc_rqst *rqstp,
>  	cstate->slot = slot;
>  	cstate->session = session;
>  
> +	status = nfsd4_check_request_size(rqstp->rq_argp, cstate);
>  out:
>  	/* Hold a session reference until done processing the compound. */
>  	if (cstate->session) {
> -- 
> 1.7.4.5
> 
> 
