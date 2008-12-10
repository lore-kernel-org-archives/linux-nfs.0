From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 03/27] NSM: Add xdr_stream-based XDR encoders
Date: Wed, 10 Dec 2008 15:36:39 -0500
Message-ID: <20081210203639.GC1212@fieldses.org>
References: <20081205235557.24075.12511.stgit@ingres.1015granger.net> <20081206000214.24075.58074.stgit@ingres.1015granger.net> <20081210203533.GB1212@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:55609 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754181AbYLJUgk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Dec 2008 15:36:40 -0500
In-Reply-To: <20081210203533.GB1212@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 10, 2008 at 03:35:33PM -0500, bfields wrote:
> On Fri, Dec 05, 2008 at 07:02:15PM -0500, Chuck Lever wrote:
> > Introduce xdr_stream-based XDR encoder functions.  These are more
> > careful about preventing RPC buffer overflows.
> 
> Looks fine, thanks; applied, with a superficial patch reorganization:
> for once this is a patch I think is too small.
> 
> My two rules of thumb:
> 
> 	- Callers for new code should be added at the same time as the
> 	  new code.
> 
> 	  (Otherwise it's not possible to judge the single patch on its
> 	  own, because you don't know whether the new (temporarily dead)
> 	  code is correct until you see it called.)
> 
> 	- When replacing code, I'd rather see the new code added in the
> 	  same patch that removes the old code.
> 
> 	  (Again, it's easier to judge the single patch on its own if
> 	  you see the side-by-side old-to-new comparison.)
> 
> Neither rule is an absolute.
> 
> In this case I think squashing the following four patches gives a
> reasonable result; I've applied the below (literally just the
> composition of the four patches) instead of 3--7.

(Oops, I meant 3--6.)

--b.

> 
> (If we were to split this up more finely, I'd consider doing encoders
> separately from decoders, and/or SM_MON separately from SM_UNMON.)
> 
> --b.
> 
> commit fc88c50d16bbc43ab6a90107acbf45a0654d57ee
> Author: Chuck Lever <chuck.lever@oracle.com>
> Date:   Fri Dec 5 19:02:15 2008 -0500
> 
>     NSM: move to xdr_stream-based XDR encoders and decoders
>     
>     Introduce xdr_stream-based XDR encoder and decoder functions, which are
>     more careful about preventing RPC buffer overflows.
>     
>     Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>     Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> 
> diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
> index 0fc9836..81e1cc1 100644
> --- a/fs/lockd/mon.c
> +++ b/fs/lockd/mon.c
> @@ -193,21 +193,26 @@ nsm_create(void)
>   * Status Monitor wire protocol.
>   */
>  
> -static __be32 *xdr_encode_nsm_string(__be32 *p, char *string)
> +static int encode_nsm_string(struct xdr_stream *xdr, const char *string)
>  {
> -	size_t len = strlen(string);
> -
> -	if (len > SM_MAXSTRLEN)
> -		len = SM_MAXSTRLEN;
> -	return xdr_encode_opaque(p, string, len);
> +	const u32 len = strlen(string);
> +	__be32 *p;
> +
> +	if (unlikely(len > SM_MAXSTRLEN))
> +		return -EIO;
> +	p = xdr_reserve_space(xdr, sizeof(u32) + len);
> +	if (unlikely(p == NULL))
> +		return -EIO;
> +	xdr_encode_opaque(p, string, len);
> +	return 0;
>  }
>  
>  /*
>   * "mon_name" specifies the host to be monitored.
>   */
> -static __be32 *xdr_encode_mon_name(__be32 *p, struct nsm_args *argp)
> +static int encode_mon_name(struct xdr_stream *xdr, const struct nsm_args *argp)
>  {
> -	return xdr_encode_nsm_string(p, argp->mon_name);
> +	return encode_nsm_string(xdr, argp->mon_name);
>  }
>  
>  /*
> @@ -216,30 +221,35 @@ static __be32 *xdr_encode_mon_name(__be32 *p, struct nsm_args *argp)
>   * (via the NLMPROC_SM_NOTIFY call) that the state of host "mon_name"
>   * has changed.
>   */
> -static __be32 *xdr_encode_my_id(__be32 *p, struct nsm_args *argp)
> +static int encode_my_id(struct xdr_stream *xdr, const struct nsm_args *argp)
>  {
> -	p = xdr_encode_nsm_string(p, utsname()->nodename);
> -	if (!p)
> -		return ERR_PTR(-EIO);
> -
> +	int status;
> +	__be32 *p;
> +
> +	status = encode_nsm_string(xdr, utsname()->nodename);
> +	if (unlikely(status != 0))
> +		return status;
> +	p = xdr_reserve_space(xdr, 3 * sizeof(u32));
> +	if (unlikely(p == NULL))
> +		return -EIO;
>  	*p++ = htonl(argp->prog);
>  	*p++ = htonl(argp->vers);
>  	*p++ = htonl(argp->proc);
> -
> -	return p;
> +	return 0;
>  }
>  
>  /*
>   * The "mon_id" argument specifies the non-private arguments
>   * of an NSMPROC_MON or NSMPROC_UNMON call.
>   */
> -static __be32 *xdr_encode_mon_id(__be32 *p, struct nsm_args *argp)
> +static int encode_mon_id(struct xdr_stream *xdr, const struct nsm_args *argp)
>  {
> -	p = xdr_encode_mon_name(p, argp);
> -	if (!p)
> -		return ERR_PTR(-EIO);
> +	int status;
>  
> -	return xdr_encode_my_id(p, argp);
> +	status = encode_mon_name(xdr, argp);
> +	if (unlikely(status != 0))
> +		return status;
> +	return encode_my_id(xdr, argp);
>  }
>  
>  /*
> @@ -250,55 +260,71 @@ static __be32 *xdr_encode_mon_id(__be32 *p, struct nsm_args *argp)
>   * Linux provides the raw IP address of the monitored host,
>   * left in network byte order.
>   */
> -static __be32 *xdr_encode_priv(__be32 *p, struct nsm_args *argp)
> +static int encode_priv(struct xdr_stream *xdr, const struct nsm_args *argp)
>  {
> +	__be32 *p;
> +
> +	p = xdr_reserve_space(xdr, SM_PRIV_SIZE);
> +	if (unlikely(p == NULL))
> +		return -EIO;
>  	*p++ = argp->addr;
>  	*p++ = 0;
>  	*p++ = 0;
>  	*p++ = 0;
> -
> -	return p;
> +	return 0;
>  }
>  
> -static int
> -xdr_encode_mon(struct rpc_rqst *rqstp, __be32 *p, struct nsm_args *argp)
> +static int xdr_enc_mon(struct rpc_rqst *req, __be32 *p,
> +		       const struct nsm_args *argp)
>  {
> -	p = xdr_encode_mon_id(p, argp);
> -	if (IS_ERR(p))
> -		return PTR_ERR(p);
> -
> -	p = xdr_encode_priv(p, argp);
> -	if (IS_ERR(p))
> -		return PTR_ERR(p);
> +	struct xdr_stream xdr;
> +	int status;
>  
> -	rqstp->rq_slen = xdr_adjust_iovec(rqstp->rq_svec, p);
> -	return 0;
> +	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
> +	status = encode_mon_id(&xdr, argp);
> +	if (unlikely(status))
> +		return status;
> +	return encode_priv(&xdr, argp);
>  }
>  
> -static int
> -xdr_encode_unmon(struct rpc_rqst *rqstp, __be32 *p, struct nsm_args *argp)
> +static int xdr_enc_unmon(struct rpc_rqst *req, __be32 *p,
> +			 const struct nsm_args *argp)
>  {
> -	p = xdr_encode_mon_id(p, argp);
> -	if (IS_ERR(p))
> -		return PTR_ERR(p);
> -	rqstp->rq_slen = xdr_adjust_iovec(rqstp->rq_svec, p);
> -	return 0;
> +	struct xdr_stream xdr;
> +
> +	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
> +	return encode_mon_id(&xdr, argp);
>  }
>  
> -static int
> -xdr_decode_stat_res(struct rpc_rqst *rqstp, __be32 *p, struct nsm_res *resp)
> +static int xdr_dec_stat_res(struct rpc_rqst *rqstp, __be32 *p,
> +			    struct nsm_res *resp)
>  {
> +	struct xdr_stream xdr;
> +
> +	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
> +	p = xdr_inline_decode(&xdr, 2 * sizeof(u32));
> +	if (unlikely(p == NULL))
> +		return -EIO;
>  	resp->status = ntohl(*p++);
> -	resp->state = ntohl(*p++);
> -	dprintk("nsm: xdr_decode_stat_res status %d state %d\n",
> +	resp->state = ntohl(*p);
> +
> +	dprintk("lockd: xdr_dec_stat_res status %d state %d\n",
>  			resp->status, resp->state);
>  	return 0;
>  }
>  
> -static int
> -xdr_decode_stat(struct rpc_rqst *rqstp, __be32 *p, struct nsm_res *resp)
> +static int xdr_dec_stat(struct rpc_rqst *rqstp, __be32 *p,
> +			struct nsm_res *resp)
>  {
> -	resp->state = ntohl(*p++);
> +	struct xdr_stream xdr;
> +
> +	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
> +	p = xdr_inline_decode(&xdr, sizeof(u32));
> +	if (unlikely(p == NULL))
> +		return -EIO;
> +	resp->state = ntohl(*p);
> +
> +	dprintk("lockd: xdr_dec_stat state %d\n", resp->state);
>  	return 0;
>  }
>  
> @@ -314,8 +340,8 @@ xdr_decode_stat(struct rpc_rqst *rqstp, __be32 *p, struct nsm_res *resp)
>  static struct rpc_procinfo	nsm_procedures[] = {
>  [NSMPROC_MON] = {
>  		.p_proc		= NSMPROC_MON,
> -		.p_encode	= (kxdrproc_t) xdr_encode_mon,
> -		.p_decode	= (kxdrproc_t) xdr_decode_stat_res,
> +		.p_encode	= (kxdrproc_t)xdr_enc_mon,
> +		.p_decode	= (kxdrproc_t)xdr_dec_stat_res,
>  		.p_arglen	= SM_mon_sz,
>  		.p_replen	= SM_monres_sz,
>  		.p_statidx	= NSMPROC_MON,
> @@ -323,8 +349,8 @@ static struct rpc_procinfo	nsm_procedures[] = {
>  	},
>  [NSMPROC_UNMON] = {
>  		.p_proc		= NSMPROC_UNMON,
> -		.p_encode	= (kxdrproc_t) xdr_encode_unmon,
> -		.p_decode	= (kxdrproc_t) xdr_decode_stat,
> +		.p_encode	= (kxdrproc_t)xdr_enc_unmon,
> +		.p_decode	= (kxdrproc_t)xdr_dec_stat,
>  		.p_arglen	= SM_mon_id_sz,
>  		.p_replen	= SM_unmonres_sz,
>  		.p_statidx	= NSMPROC_UNMON,
