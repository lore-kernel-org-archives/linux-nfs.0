Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:50931 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753245Ab1GFQnI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Jul 2011 12:43:08 -0400
Date: Wed, 6 Jul 2011 12:43:07 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/2 v2] nfsd41: check the size of request
Message-ID: <20110706164306.GC30349@fieldses.org>
References: <4E0EDEBE.8040902@cn.fujitsu.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E0EDEBE.8040902@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, Jul 02, 2011 at 05:02:54PM +0800, Mi Jinlong wrote:
> This patch just check request's size when it consists SEQUENCE.
> 
> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
> ---
>  fs/nfsd/nfs4state.c |   16 ++++++++++++++++
>  1 files changed, 16 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index e98f3c2..17e30bf 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1736,6 +1736,21 @@ static bool nfsd4_session_too_many_ops(struct svc_rqst *rqstp, struct nfsd4_sess
>  	return args->opcnt > session->se_fchannel.maxops;
>  }
>  
> +static int nfsd4_check_request_size(struct nfsd4_compoundargs *args,
> +				    struct nfsd4_session *session)
> +{
> +	struct xdr_buf *xb = &args->rqstp->rq_arg;
> +
> +	/* Only SEQUENCE operation */
> +	if (args->opcnt == 1)
> +		return 0;

Do we need this special check?

Sure, it's possible that a crazy client could set se_fchannel.maxreq_sz
too small, and then we'd get a failure here even when they only sent a
single sequence.  Such a client gets what it deserves.

Seems OK otherwise.

Of course, dealing with the maximum response size is going to be the
difficult part.

--b.

> +
> +	if (xb->len > session->se_fchannel.maxreq_sz)
> +		return nfserr_req_too_big;
> +
> +	return 0;
> +}
> +
>  __be32
>  nfsd4_sequence(struct svc_rqst *rqstp,
>  	       struct nfsd4_compound_state *cstate,
> @@ -1804,6 +1819,7 @@ nfsd4_sequence(struct svc_rqst *rqstp,
>  	cstate->slot = slot;
>  	cstate->session = session;
>  
> +	status = nfsd4_check_request_size(rqstp->rq_argp, session);
>  out:
>  	/* Hold a session reference until done processing the compound. */
>  	if (cstate->session) {
> -- 
> 1.7.5.4
> 
> 
> 
