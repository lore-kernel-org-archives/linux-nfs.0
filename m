From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 02/23] gss_krb5: Added and improved code comments
Date: Wed, 17 Mar 2010 13:10:48 -0400
Message-ID: <4BA10D18.2030407@oracle.com>
References: <1268845388-9516-1-git-send-email-steved@redhat.com> <1268845388-9516-3-git-send-email-steved@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:42903 "EHLO
	rcsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755056Ab0CQRL1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Mar 2010 13:11:27 -0400
In-Reply-To: <1268845388-9516-3-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/17/2010 01:02 PM, steved@redhat.com wrote:
> From: Kevin Coffman<kwc@citi.umich.edu>
>
> Signed-off-by: Steve Dickson<steved@redhat.com>
> ---
>   net/sunrpc/auth_gss/auth_gss.c        |   12 +++++++++---
>   net/sunrpc/auth_gss/gss_mech_switch.c |   14 ++++++++++++++
>   net/sunrpc/auth_gss/svcauth_gss.c     |   15 +++++++++++++++
>   3 files changed, 38 insertions(+), 3 deletions(-)
>
> diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
> index 7c50ea6..a268368 100644
> --- a/net/sunrpc/auth_gss/auth_gss.c
> +++ b/net/sunrpc/auth_gss/auth_gss.c
> @@ -1317,15 +1317,21 @@ gss_wrap_req_priv(struct rpc_cred *cred, struct gss_cl_ctx *ctx,
>   	inpages = snd_buf->pages + first;
>   	snd_buf->pages = rqstp->rq_enc_pages;
>   	snd_buf->page_base -= first<<  PAGE_CACHE_SHIFT;
> -	/* Give the tail its own page, in case we need extra space in the
> -	 * head when wrapping: */
> +	/*
> +	 * Give the tail its own page, in case we need extra space in the
> +	 * head when wrapping:
> +	 *
> +	 * call_allocate() allocates twice the slack space required
> +	 * by the authentication flavor to rq_callsize.
> +	 * For GSS, slack is GSS_CRED_SLACK.
> +	 */
>   	if (snd_buf->page_len || snd_buf->tail[0].iov_len) {
>   		tmp = page_address(rqstp->rq_enc_pages[rqstp->rq_enc_pages_num - 1]);
>   		memcpy(tmp, snd_buf->tail[0].iov_base, snd_buf->tail[0].iov_len);
>   		snd_buf->tail[0].iov_base = tmp;
>   	}
>   	maj_stat = gss_wrap(ctx->gc_gss_ctx, offset, snd_buf, inpages);
> -	/* RPC_SLACK_SPACE should prevent this ever happening: */
> +	/* slack space should prevent this ever happening: */
>   	BUG_ON(snd_buf->len>  snd_buf->buflen);
>   	status = -EIO;
>   	/* We're assuming that when GSS_S_CONTEXT_EXPIRED, the encryption was
> diff --git a/net/sunrpc/auth_gss/gss_mech_switch.c b/net/sunrpc/auth_gss/gss_mech_switch.c
> index 76e4c6f..28a84ef 100644
> --- a/net/sunrpc/auth_gss/gss_mech_switch.c
> +++ b/net/sunrpc/auth_gss/gss_mech_switch.c
> @@ -285,6 +285,20 @@ gss_verify_mic(struct gss_ctx		*context_handle,
>   				 mic_token);
>   }
>
> +/*
> + * This function is called from both the client and server code.
> + * Each makes guarantees about how much "slack" space is available
> + * for the underlying function in "buf"'s head and tail while
> + * performing the wrap.
> + *
> + * The client and server code allocate RPC_MAX_AUTH_SIZE extra
> + * space in both the head and tail which is available for use by
> + * the wrap function.
> + *
> + * Underlying functions should verify they do not use more than
> + * RPC_MAX_AUTH_SIZE of extra space in either the head or tail
> + * when performing the wrap.
> + */

gss_wrap is globally visible, so this should be a doxygen style comment, 
yes?

>   u32
>   gss_wrap(struct gss_ctx	*ctx_id,
>   	 int		offset,
> diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
> index e34bc53..4eec8ba 100644
> --- a/net/sunrpc/auth_gss/svcauth_gss.c
> +++ b/net/sunrpc/auth_gss/svcauth_gss.c
> @@ -1314,6 +1314,14 @@ svcauth_gss_wrap_resp_priv(struct svc_rqst *rqstp)
>   	inpages = resbuf->pages;
>   	/* XXX: Would be better to write some xdr helper functions for
>   	 * nfs{2,3,4}xdr.c that place the data right, instead of copying: */
> +
> +	/*
> +	 * If there is currently tail data, make sure there is
> +	 * room for the head, tail, and 2 * RPC_MAX_AUTH_SIZE in
> +	 * the page, and move the current tail data such that
> +	 * there is RPC_MAX_AUTH_SIZE slack space available in
> +	 * both the head and tail.
> +	 */
>   	if (resbuf->tail[0].iov_base) {
>   		BUG_ON(resbuf->tail[0].iov_base>= resbuf->head[0].iov_base
>   							+ PAGE_SIZE);
> @@ -1326,6 +1334,13 @@ svcauth_gss_wrap_resp_priv(struct svc_rqst *rqstp)
>   			resbuf->tail[0].iov_len);
>   		resbuf->tail[0].iov_base += RPC_MAX_AUTH_SIZE;
>   	}
> +	/*
> +	 * If there is no current tail data, make sure there is
> +	 * room for the head data, and 2 * RPC_MAX_AUTH_SIZE in the
> +	 * allotted page, and set up tail information such that there
> +	 * is RPC_MAX_AUTH_SIZE slack space available in both the
> +	 * head and tail.
> +	 */
>   	if (resbuf->tail[0].iov_base == NULL) {
>   		if (resbuf->head[0].iov_len + 2*RPC_MAX_AUTH_SIZE>  PAGE_SIZE)
>   			return -ENOMEM;


-- 
chuck[dot]lever[at]oracle[dot]com
