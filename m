Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53468 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751952AbaGQUQu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Jul 2014 16:16:50 -0400
Date: Thu, 17 Jul 2014 16:16:50 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] nfsd: silence sparse warning about accessing credentials
Message-ID: <20140717201649.GF30442@fieldses.org>
References: <1405443576-28348-1-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1405443576-28348-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 15, 2014 at 12:59:36PM -0400, Jeff Layton wrote:
> sparse says:
> 
>     fs/nfsd/auth.c:31:38: warning: incorrect type in argument 1 (different address spaces)
>     fs/nfsd/auth.c:31:38:    expected struct cred const *cred
>     fs/nfsd/auth.c:31:38:    got struct cred const [noderef] <asn:4>*real_cred
> 
> Add a new accessor for the ->real_cred and use that to fetch the
> pointer. Accessing current->real_cred directly is actually quite safe
> since we know that they can't go away so this is mostly a cosmetic fixup
> to silence sparse.

Thanks, applying, absent any objections.

--b.

> 
> Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> ---
>  fs/nfsd/auth.c       | 2 +-
>  include/linux/cred.h | 9 +++++++++
>  2 files changed, 10 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/auth.c b/fs/nfsd/auth.c
> index 72f44823adbb..9d46a0bdd9f9 100644
> --- a/fs/nfsd/auth.c
> +++ b/fs/nfsd/auth.c
> @@ -28,7 +28,7 @@ int nfsd_setuser(struct svc_rqst *rqstp, struct svc_export *exp)
>  	validate_process_creds();
>  
>  	/* discard any old override before preparing the new set */
> -	revert_creds(get_cred(current->real_cred));
> +	revert_creds(get_cred(current_real_cred()));
>  	new = prepare_creds();
>  	if (!new)
>  		return -ENOMEM;
> diff --git a/include/linux/cred.h b/include/linux/cred.h
> index f61d6c8f5ef3..b2d0820837c4 100644
> --- a/include/linux/cred.h
> +++ b/include/linux/cred.h
> @@ -259,6 +259,15 @@ static inline void put_cred(const struct cred *_cred)
>  	rcu_dereference_protected(current->cred, 1)
>  
>  /**
> + * current_real_cred - Access the current task's objective credentials
> + *
> + * Access the objective credentials of the current task.  RCU-safe,
> + * since nobody else can modify it.
> + */
> +#define current_real_cred() \
> +	rcu_dereference_protected(current->real_cred, 1)
> +
> +/**
>   * __task_cred - Access a task's objective credentials
>   * @task: The task to query
>   *
> -- 
> 1.9.3
> 
