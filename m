Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:36514 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754290AbaDKLEs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Apr 2014 07:04:48 -0400
Date: Fri, 11 Apr 2014 07:04:45 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: steved@redhat.com, trond.myklebust@primarydata.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 5/5] gssd: scrape the acceptor name out of the context
Message-ID: <20140411070445.0dba29c5@tlielax.poochiereds.net>
In-Reply-To: <1397161863-29266-6-git-send-email-jlayton@redhat.com>
References: <1397161863-29266-1-git-send-email-jlayton@redhat.com>
	<1397161863-29266-6-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 10 Apr 2014 16:31:03 -0400
Jeff Layton <jlayton@redhat.com> wrote:

> ...and pass it to the kernel in the downcall. Legacy kernels will just
> ignore the extra data, but with a proposed kernel patch the kernel will
> grab this info and use it to verify requests on the v4.0 callback
> channel.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  utils/gssd/gssd_proc.c | 39 ++++++++++++++++++++++++++++-----------
>  1 file changed, 28 insertions(+), 11 deletions(-)
> 
> diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> index 7387cce010cf..d95e39416c28 100644
> --- a/utils/gssd/gssd_proc.c
> +++ b/utils/gssd/gssd_proc.c
> @@ -77,6 +77,7 @@
>  #include "context.h"
>  #include "nfsrpc.h"
>  #include "nfslib.h"
> +#include "gss_names.h"
>  
>  /*
>   * pollarray:
> @@ -683,16 +684,19 @@ parse_enctypes(char *enctypes)
>  
>  static void
>  do_downcall(int k5_fd, uid_t uid, struct authgss_private_data *pd,
> -	    gss_buffer_desc *context_token, OM_uint32 lifetime_rec)
> +	    gss_buffer_desc *context_token, OM_uint32 lifetime_rec,
> +	    gss_buffer_desc *acceptor)
>  {
>  	char    *buf = NULL, *p = NULL, *end = NULL;
>  	unsigned int timeout = context_timeout;
>  	unsigned int buf_size = 0;
>  
> -	printerr(1, "doing downcall lifetime_rec %u\n", lifetime_rec);
> +	printerr(1, "doing downcall: lifetime_rec=%u acceptor=%.*s\n",
> +		lifetime_rec, acceptor->length, acceptor->value);
>  	buf_size = sizeof(uid) + sizeof(timeout) + sizeof(pd->pd_seq_win) +
>  		sizeof(pd->pd_ctx_hndl.length) + pd->pd_ctx_hndl.length +
> -		sizeof(context_token->length) + context_token->length;
> +		sizeof(context_token->length) + context_token->length +
> +		acceptor->length;
>  	p = buf = malloc(buf_size);
>  	if (!buf)
>  		goto out_err;
> @@ -707,6 +711,8 @@ do_downcall(int k5_fd, uid_t uid, struct authgss_private_data *pd,
>  	if (WRITE_BYTES(&p, end, pd->pd_seq_win)) goto out_err;
>  	if (write_buffer(&p, end, &pd->pd_ctx_hndl)) goto out_err;
>  	if (write_buffer(&p, end, context_token)) goto out_err;
> +	if (acceptor->length > 0 &&
> +	    write_buffer(&p, end, acceptor)) goto out_err;

I think I'll need to make a minor change to this patch. In the event
that the acceptor has zero length, then I think we still want to add
the length to the downcall. That will allow us to extend the downcall
format again in the future if needed.

The only thing I'll need to do to fix that is to remove the
"acceptor->length > 0" check above. I'll do that and send a v2 patch
once I've given everyone a chance to comment on the set.

>  
>  	if (write(k5_fd, buf, p - buf) < p - buf) goto out_err;
>  	free(buf);
> @@ -1034,6 +1040,9 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
>  	gss_cred_id_t		gss_cred;
>  	OM_uint32		maj_stat, min_stat, lifetime_rec;
>  	pid_t			pid;
> +	gss_name_t		gacceptor;
> +	gss_OID			mech;
> +	gss_buffer_desc		acceptor  = {0};
>  
>  	pid = fork();
>  	switch(pid) {
> @@ -1174,15 +1183,22 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
>  		goto out_return_error;
>  	}
>  
> -	/* Grab the context lifetime to pass to the kernel. lifetime_rec
> -	 * is set to zero on error */
> -	maj_stat = gss_inquire_context(&min_stat, pd.pd_ctx, NULL, NULL,
> -				       &lifetime_rec, NULL, NULL, NULL, NULL);
> +	maj_stat = gss_inquire_context(&min_stat, pd.pd_ctx, NULL, &gacceptor,
> +				       &lifetime_rec, &mech, NULL, NULL, NULL);
>  
> -	if (maj_stat)
> -		printerr(1, "WARNING: Failed to inquire context for lifetme "
> -			    "maj_stat %u\n", maj_stat);
> +	if (maj_stat != GSS_S_COMPLETE) {
> +		printerr(1, "WARNING: Failed to inquire context "
> +			    "maj_stat (0x%x)\n", maj_stat);
> +	} else {
> +		get_hostbased_client_buffer(gacceptor, mech, &acceptor);
> +		gss_release_name(&min_stat, &gacceptor);
> +	}
>  
> +	/*
> +	 * The serialization can mean turning the ctx into a lucid context. If
> +	 * that happens then the original ctx is no longer valid, so we mustn't
> +	 * try to use if after this point.
> +	 */
>  	if (serialize_context_for_kernel(&pd.pd_ctx, &token, &krb5oid, NULL)) {
>  		printerr(0, "WARNING: Failed to serialize krb5 context for "
>  			    "user with uid %d for server %s\n",
> @@ -1190,9 +1206,10 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
>  		goto out_return_error;
>  	}
>  
> -	do_downcall(fd, uid, &pd, &token, lifetime_rec);
> +	do_downcall(fd, uid, &pd, &token, lifetime_rec, &acceptor);
>  
>  out:
> +	gss_release_buffer(&min_stat, &acceptor);
>  	if (token.value)
>  		free(token.value);
>  #ifdef HAVE_AUTHGSS_FREE_PRIVATE_DATA


-- 
Jeff Layton <jlayton@redhat.com>
