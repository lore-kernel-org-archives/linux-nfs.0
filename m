Return-Path: <SRS0=dgFe=QL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E8D7C282C4
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Feb 2019 19:04:16 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5D4372082E
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Feb 2019 19:04:16 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729765AbfBDTEP (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 4 Feb 2019 14:04:15 -0500
Received: from fieldses.org ([173.255.197.46]:51694 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729323AbfBDTEP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 4 Feb 2019 14:04:15 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 6D6F41CE7; Mon,  4 Feb 2019 14:04:14 -0500 (EST)
Date:   Mon, 4 Feb 2019 14:04:14 -0500
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-nfs@vger.kernel.org, simo@redhat.com
Subject: Re: [PATCH RFC 01/10] SUNRPC: Remove some dprintk() call sites from
 auth functions
Message-ID: <20190204190414.GA1816@fieldses.org>
References: <20190201195538.11389.96106.stgit@manet.1015granger.net>
 <20190201195731.11389.69008.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190201195731.11389.69008.stgit@manet.1015granger.net>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Feb 01, 2019 at 02:57:31PM -0500, Chuck Lever wrote:
> Clean up: Reduce dprintk noise by removing dprintk() call sites
> from hot path that do not report exceptions. These are usually
> replaceable with function graph tracing.

Yeah, dprintk's sometimes much to verbose to be useful, thanks for
looking at this.  How are you deciding what the hot paths are?

--b.

> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  net/sunrpc/auth.c      |   29 -----------------------------
>  net/sunrpc/auth_unix.c |    9 +--------
>  2 files changed, 1 insertion(+), 37 deletions(-)
> 
> diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
> index 8dfab61..275e84e 100644
> --- a/net/sunrpc/auth.c
> +++ b/net/sunrpc/auth.c
> @@ -17,10 +17,6 @@
>  #include <linux/sunrpc/gss_api.h>
>  #include <linux/spinlock.h>
>  
> -#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
> -# define RPCDBG_FACILITY	RPCDBG_AUTH
> -#endif
> -
>  #define RPC_CREDCACHE_DEFAULT_HASHBITS	(4)
>  struct rpc_cred_cache {
>  	struct hlist_head	*hashtable;
> @@ -267,8 +263,6 @@ static int param_get_hashtbl_sz(char *buffer, const struct kernel_param *kp)
>  		}
>  	}
>  	rcu_read_unlock();
> -
> -	dprintk("RPC:       %s returns %d\n", __func__, result);
>  	return result;
>  }
>  EXPORT_SYMBOL_GPL(rpcauth_list_flavors);
> @@ -636,9 +630,6 @@ struct rpc_cred *
>  	struct rpc_cred *ret;
>  	const struct cred *cred = current_cred();
>  
> -	dprintk("RPC:       looking up %s cred\n",
> -		auth->au_ops->au_name);
> -
>  	memset(&acred, 0, sizeof(acred));
>  	acred.cred = cred;
>  	ret = auth->au_ops->lookup_cred(auth, &acred, flags);
> @@ -670,8 +661,6 @@ struct rpc_cred *
>  	};
>  	struct rpc_cred *ret;
>  
> -	dprintk("RPC: %5u looking up %s cred\n",
> -		task->tk_pid, task->tk_client->cl_auth->au_ops->au_name);
>  	ret = auth->au_ops->lookup_cred(auth, &acred, lookupflags);
>  	put_cred(acred.cred);
>  	return ret;
> @@ -688,8 +677,6 @@ struct rpc_cred *
>  
>  	if (!acred.principal)
>  		return NULL;
> -	dprintk("RPC: %5u looking up %s machine cred\n",
> -		task->tk_pid, task->tk_client->cl_auth->au_ops->au_name);
>  	return auth->au_ops->lookup_cred(auth, &acred, lookupflags);
>  }
>  
> @@ -698,8 +685,6 @@ struct rpc_cred *
>  {
>  	struct rpc_auth *auth = task->tk_client->cl_auth;
>  
> -	dprintk("RPC: %5u looking up %s cred\n",
> -		task->tk_pid, auth->au_ops->au_name);
>  	return rpcauth_lookupcred(auth, lookupflags);
>  }
>  
> @@ -776,9 +761,6 @@ struct rpc_cred *
>  {
>  	struct rpc_cred	*cred = task->tk_rqstp->rq_cred;
>  
> -	dprintk("RPC: %5u marshaling %s cred %p\n",
> -		task->tk_pid, cred->cr_auth->au_ops->au_name, cred);
> -
>  	return cred->cr_ops->crmarshal(task, p);
>  }
>  
> @@ -787,9 +769,6 @@ struct rpc_cred *
>  {
>  	struct rpc_cred	*cred = task->tk_rqstp->rq_cred;
>  
> -	dprintk("RPC: %5u validating %s cred %p\n",
> -		task->tk_pid, cred->cr_auth->au_ops->au_name, cred);
> -
>  	return cred->cr_ops->crvalidate(task, p);
>  }
>  
> @@ -808,8 +787,6 @@ static void rpcauth_wrap_req_encode(kxdreproc_t encode, struct rpc_rqst *rqstp,
>  {
>  	struct rpc_cred *cred = task->tk_rqstp->rq_cred;
>  
> -	dprintk("RPC: %5u using %s cred %p to wrap rpc data\n",
> -			task->tk_pid, cred->cr_ops->cr_name, cred);
>  	if (cred->cr_ops->crwrap_req)
>  		return cred->cr_ops->crwrap_req(task, encode, rqstp, data, obj);
>  	/* By default, we encode the arguments normally. */
> @@ -833,8 +810,6 @@ static void rpcauth_wrap_req_encode(kxdreproc_t encode, struct rpc_rqst *rqstp,
>  {
>  	struct rpc_cred *cred = task->tk_rqstp->rq_cred;
>  
> -	dprintk("RPC: %5u using %s cred %p to unwrap rpc data\n",
> -			task->tk_pid, cred->cr_ops->cr_name, cred);
>  	if (cred->cr_ops->crunwrap_resp)
>  		return cred->cr_ops->crunwrap_resp(task, decode, rqstp,
>  						   data, obj);
> @@ -865,8 +840,6 @@ static void rpcauth_wrap_req_encode(kxdreproc_t encode, struct rpc_rqst *rqstp,
>  			goto out;
>  		cred = task->tk_rqstp->rq_cred;
>  	}
> -	dprintk("RPC: %5u refreshing %s cred %p\n",
> -		task->tk_pid, cred->cr_auth->au_ops->au_name, cred);
>  
>  	err = cred->cr_ops->crrefresh(task);
>  out:
> @@ -880,8 +853,6 @@ static void rpcauth_wrap_req_encode(kxdreproc_t encode, struct rpc_rqst *rqstp,
>  {
>  	struct rpc_cred *cred = task->tk_rqstp->rq_cred;
>  
> -	dprintk("RPC: %5u invalidating %s cred %p\n",
> -		task->tk_pid, cred->cr_auth->au_ops->au_name, cred);
>  	if (cred)
>  		clear_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags);
>  }
> diff --git a/net/sunrpc/auth_unix.c b/net/sunrpc/auth_unix.c
> index 387f6b3..fc8a591 100644
> --- a/net/sunrpc/auth_unix.c
> +++ b/net/sunrpc/auth_unix.c
> @@ -28,8 +28,6 @@
>  static struct rpc_auth *
>  unx_create(const struct rpc_auth_create_args *args, struct rpc_clnt *clnt)
>  {
> -	dprintk("RPC:       creating UNIX authenticator for client %p\n",
> -			clnt);
>  	refcount_inc(&unix_auth.au_count);
>  	return &unix_auth;
>  }
> @@ -37,7 +35,6 @@
>  static void
>  unx_destroy(struct rpc_auth *auth)
>  {
> -	dprintk("RPC:       destroying UNIX authenticator %p\n", auth);
>  }
>  
>  /*
> @@ -48,10 +45,6 @@
>  {
>  	struct rpc_cred *ret = mempool_alloc(unix_pool, GFP_NOFS);
>  
> -	dprintk("RPC:       allocating UNIX cred for uid %d gid %d\n",
> -			from_kuid(&init_user_ns, acred->cred->fsuid),
> -			from_kgid(&init_user_ns, acred->cred->fsgid));
> -
>  	rpcauth_init_cred(ret, acred, auth, &unix_credops);
>  	ret->cr_flags = 1UL << RPCAUTH_CRED_UPTODATE;
>  	return ret;
> @@ -61,7 +54,7 @@
>  unx_free_cred_callback(struct rcu_head *head)
>  {
>  	struct rpc_cred *rpc_cred = container_of(head, struct rpc_cred, cr_rcu);
> -	dprintk("RPC:       unx_free_cred %p\n", rpc_cred);
> +
>  	put_cred(rpc_cred->cr_cred);
>  	mempool_free(rpc_cred, unix_pool);
>  }
