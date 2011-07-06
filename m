Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:46869 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753546Ab1GFQ0v (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Jul 2011 12:26:51 -0400
Date: Wed, 6 Jul 2011 12:26:50 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2 v2] nfsd41: error out when client sets maxreq_sz
 or, maxresp_sz too small
Message-ID: <20110706162650.GB30349@fieldses.org>
References: <4E0EDE78.1060208@cn.fujitsu.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E0EDE78.1060208@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, Jul 02, 2011 at 05:01:44PM +0800, Mi Jinlong wrote:
> According to RFC5661, 18.36.3, 
> 
>  "if the client selects a value for ca_maxresponsesize such that
>   a replier on a channel could never send a response,the server
>   SHOULD return NFS4ERR_TOOSMALL in the CREATE_SESSION reply."
> 
> This patch let server error out when client sets maxreq_sz less than
> SEQUENCE request size, and maxresp_sz less than a SEQUENCE reply size.
> 
> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
> ---
>  fs/nfsd/nfs4xdr.c |   26 +++++++++++++++++++++++++-
>  1 files changed, 25 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 9901811..bece272 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -1135,11 +1135,25 @@ nfsd4_decode_create_session(struct nfsd4_compoundargs *argp,
>  {
>  	DECODE_HEAD;
>  
> -	u32 dummy;
> +	struct xdr_buf *xb = &argp->rqstp->rq_arg;
> +	u32 dummy, minreqlen = 0, minresplen = 0;
>  	char *machine_name;
>  	int i;
>  	int nr_secflavs;
>  
> +	/* RPC header length and tag, minorversion, Opt count*/
> +	minreqlen = (char *)argp->p - ((char *)argp->end - xb->len);
> +	/* length with a SEQUENCE operation */
> +	minreqlen = minreqlen + sizeof(struct nfs4_sessionid)
> +		    + 4 * sizeof(__be32);
> +
> +	/* RPC header, status, tag len */
> +	minresplen = argp->rqstp->rq_res.head[0].iov_len + 2 * sizeof(__be32)
> +		     /* tag, opt count, opcode, op status */
> +		     + ALIGN(argp->taglen, 4) + 3 * sizeof(__be32)
> +		     /* sessionid, seqid, 3 * slotid, status*/
> +		     + sizeof(struct nfs4_sessionid) + 5 * sizeof(__be32);
> +

Could you just calculate this as a constant, assuming the smallest
possible credential and verifier?  NFSD_MIN_HDR_SEQ_SZ may be what you
need for the reply.

Calculating it dynamically here using the cred and verifier size from
the create_session request might be more accurate--or it might not, as
there's no guarantee the same size cred adn verifier will be used for
later rpc's.

But that's OK, our goal here isn't to get this 100% correct, as that's
not possible, it's just to add a sanity check that may help catch a
crazy client.

>  	READ_BUF(16);
>  	COPYMEM(&sess->clientid, 8);
>  	READ32(sess->seqid);
> @@ -1149,7 +1163,17 @@ nfsd4_decode_create_session(struct nfsd4_compoundargs *argp,
>  	READ_BUF(28);
>  	READ32(dummy); /* headerpadsz is always 0 */
>  	READ32(sess->fore_channel.maxreq_sz);
> +	if (sess->fore_channel.maxreq_sz < minreqlen) {
> +		status = nfserr_toosmall;

Have you checked whether that error actually gets back to the client?

I think it gets turned into a bad_xdr error at some point.

We probably want this in nfsd4_create_session instead.

--b.

> +		goto out;
> +	}
> +
>  	READ32(sess->fore_channel.maxresp_sz);
> +	if (sess->fore_channel.maxresp_sz < minresplen) {
> +		status = nfserr_toosmall;
> +		goto out;
> +	}
> +
>  	READ32(sess->fore_channel.maxresp_cached);
>  	READ32(sess->fore_channel.maxops);
>  	READ32(sess->fore_channel.maxreqs);
> -- 
> 1.7.5.4
> 
> 
> 
