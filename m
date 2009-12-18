From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] sunrpc: on successful gss error pipe write, don't
 return error
Date: Fri, 18 Dec 2009 09:11:08 -0500
Message-ID: <1261145468.3229.7.camel@localhost>
References: <1261144574-1642-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:26276 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753778AbZLROMP convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Dec 2009 09:12:15 -0500
In-Reply-To: <1261144574-1642-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-12-18 at 08:56 -0500, Jeff Layton wrote: 
> When handling the gssd downcall, the kernel should distinguish between a
> successful downcall that contains an error code and a failed downcall
> (i.e. where the parsing failed or some other sort of problem occurred).
> 
> In the former case, gss_pipe_downcall should be returning the number of
> bytes written to the pipe instead of an error.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  net/sunrpc/auth_gss/auth_gss.c |   21 +++++++++++++++++----
>  1 files changed, 17 insertions(+), 4 deletions(-)
> 
> diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
> index 3c3c50f..03cc5a4 100644
> --- a/net/sunrpc/auth_gss/auth_gss.c
> +++ b/net/sunrpc/auth_gss/auth_gss.c
> @@ -184,7 +184,8 @@ gss_alloc_context(void)
>  
>  #define GSSD_MIN_TIMEOUT (60 * 60)
>  static const void *
> -gss_fill_context(const void *p, const void *end, struct gss_cl_ctx *ctx, struct gss_api_mech *gm)
> +gss_fill_context(const void *p, const void *end, struct gss_cl_ctx *ctx,
> +		 struct gss_api_mech *gm, ssize_t *downcall_err)
>  {
>  	const void *q;
>  	unsigned int seclen;
> @@ -208,6 +209,7 @@ gss_fill_context(const void *p, const void *end, struct gss_cl_ctx *ctx, struct
>  	if (ctx->gc_win == 0) {
>  		/* in which case, p points to  an error code which we ignore */
>  		p = ERR_PTR(-EACCES);
> +		*downcall_err = -EACCES;
>  		goto err;
>  	}
>  	/* copy the opaque wire context */
> @@ -641,10 +643,21 @@ gss_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
>  	list_del_init(&gss_msg->list);
>  	spin_unlock(&inode->i_lock);
>  
> -	p = gss_fill_context(p, end, ctx, gss_msg->auth->mech);
> +	err = 0;
> +	p = gss_fill_context(p, end, ctx, gss_msg->auth->mech, &err);
>  	if (IS_ERR(p)) {
> -		err = PTR_ERR(p);
> -		gss_msg->msg.errno = (err == -EAGAIN) ? -EAGAIN : -EACCES;
> +		/*
> +		 * a non-zero downcall_err indicates that downcall write was
> +		 * OK, but contained a zero gc_win (and hence an error code).
> +		 */
> +		if (err) {
> +			gss_msg->msg.errno = err;
> +			err = mlen;
> +		} else {
> +			err = PTR_ERR(p);
> +			gss_msg->msg.errno = (err == -EAGAIN) ?
> +							-EAGAIN : -EACCES;
> +		}
>  		goto err_release_msg;
>  	}
>  	gss_msg->ctx = gss_get_ctx(ctx);

Is this extra parameter really necessary? Can't we just distinguish
between EACCES, which means that the downcall was successful, but
contained an error, and EFAULT/ENOMEM/ENOSYS, which are context creation
errors.

BTW: while looking at this, I spotted a nasty bug in
gss_import_sec_context_kerberos(). If the kzalloc() call fails, we will
return a random error code since 'p' still points to a valid memory
location...

Trond
