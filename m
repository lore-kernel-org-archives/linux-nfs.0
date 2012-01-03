Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52504 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753644Ab2ACW55 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Jan 2012 17:57:57 -0500
Date: Tue, 3 Jan 2012 17:57:57 -0500
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/4] svcrpc: fix double-free on shutdown of nfsd after
 changing pool mode
Message-ID: <20120103225757.GA9294@fieldses.org>
References: <1325631381-9231-1-git-send-email-bfields@redhat.com>
 <1325631381-9231-4-git-send-email-bfields@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1325631381-9231-4-git-send-email-bfields@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 03, 2012 at 05:56:20PM -0500, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> The pool_to and to_pool fields of the global svc_pool_map are freed on
> shutdown, but are initialized in nfsd startup only in the
> SVC_POOL_PERCPU and SVC_POOL_PERNODE cases.
> 
> They *are* initialized to zero on kernel startup.  So as long as you use
> only SVC_POOL_GLOBAL (the default), this will never be a problem.
> 
> You're also OK if you only ever use SVC_POOL_PERCPU or SVC_POOL_PERNODE.
> 
> However, the following sequence events leads to a double-free:
> 
> 	1. set SVC_POOL_PERCPU or SVC_POOL_PERNODE
> 	2. start nfsd: both fields are initialized.
> 	3. shutdown nfsd: both fields are freed.
> 	4. set SVC_POOL_GLOBAL
> 	5. start nfsd: the fields are left untouched.
> 	6. shutdown nfsd: now we try to free them again.
> 
> Step 4 is actually unnecessary, since (for some bizarre reason), nfsd
> automatically resets the pool mode to SVC_POOL_GLOBAL on shutdown.
> 
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>

Oops, also adding a stable cc for this.

--b.

> ---
>  net/sunrpc/svc.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> index e9632bb..1dd5fd0 100644
> --- a/net/sunrpc/svc.c
> +++ b/net/sunrpc/svc.c
> @@ -167,6 +167,7 @@ svc_pool_map_alloc_arrays(struct svc_pool_map *m, unsigned int maxpools)
>  
>  fail_free:
>  	kfree(m->to_pool);
> +	m->to_pool = NULL;
>  fail:
>  	return -ENOMEM;
>  }
> @@ -287,7 +288,9 @@ svc_pool_map_put(void)
>  	if (!--m->count) {
>  		m->mode = SVC_POOL_DEFAULT;
>  		kfree(m->to_pool);
> +		m->to_pool = NULL;
>  		kfree(m->pool_to);
> +		m->pool_to = NULL;
>  		m->npools = 0;
>  	}
>  
> -- 
> 1.7.5.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
