Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41101 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756624Ab3GKVBN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Jul 2013 17:01:13 -0400
Date: Thu, 11 Jul 2013 17:01:12 -0400
To: David Jeffery <djeffery@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] lockd: protect nlm_blocked access in nlmsvc_retry_blocked
Message-ID: <20130711210112.GB1033@fieldses.org>
References: <20130710171903.GA30834@fury.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130710171903.GA30834@fury.redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 10, 2013 at 01:19:50PM -0400, David Jeffery wrote:
> In nlmsvc_retry_blocked, the check that the list is non-empty and acquiring
> the pointer of the first entry is unprotected by any lock.  This allows a rare
> race condition when there is only one entry on the list.  A function such as
> nlmsvc_grant_callback() can be called, which will temporarily remove the entry
> from the list.  Between the list_empty() and list_entry(),the list may become
> empty, causing an invalid pointer to be used as an nlm_block, leading to a
> possible crash.
> 
> This patch adds the nlm_block_lock around these calls to prevent concurrent
> use of the nlm_blocked list.

Thanks!  Looks like this bug probably originated from
f904be9cc77f361d37d71468b13ff3d1a1823dea  "lockd: Mostly remove BKL from
the server" ?

Applying for 3.11.

--b.

> 
> Signed-off-by: David Jeffery <djeffery@redhat.com>
> 
> 
> --- a/fs/lockd/svclock.c
> +++ b/fs/lockd/svclock.c
> @@ -951,6 +951,7 @@ nlmsvc_retry_blocked(void)
>  	unsigned long	timeout = MAX_SCHEDULE_TIMEOUT;
>  	struct nlm_block *block;
>  
> +	spin_lock(&nlm_blocked_lock);
>  	while (!list_empty(&nlm_blocked) && !kthread_should_stop()) {
>  		block = list_entry(nlm_blocked.next, struct nlm_block, b_list);
>  
> @@ -960,6 +961,7 @@ nlmsvc_retry_blocked(void)
>  			timeout = block->b_when - jiffies;
>  			break;
>  		}
> +		spin_unlock(&nlm_blocked_lock);
>  
>  		dprintk("nlmsvc_retry_blocked(%p, when=%ld)\n",
>  			block, block->b_when);
> @@ -969,7 +971,9 @@ nlmsvc_retry_blocked(void)
>  			retry_deferred_block(block);
>  		} else
>  			nlmsvc_grant_blocked(block);
> +		spin_lock(&nlm_blocked_lock);
>  	}
> +	spin_unlock(&nlm_blocked_lock);
>  
>  	return timeout;
>  }
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
