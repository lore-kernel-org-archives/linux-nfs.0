From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 08/15] SUNRPC: Ensure rpcauth_prune_expired() respects
 the nr_to_scan parameter
Date: Fri, 14 May 2010 12:34:53 -0400
Message-ID: <4BED7BAD.20509@oracle.com>
References: <1273784901-25599-1-git-send-email-Trond.Myklebust@netapp.com> <1273784901-25599-2-git-send-email-Trond.Myklebust@netapp.com> <1273784901-25599-3-git-send-email-Trond.Myklebust@netapp.com> <1273784901-25599-4-git-send-email-Trond.Myklebust@netapp.com> <1273784901-25599-5-git-send-email-Trond.Myklebust@netapp.com> <1273784901-25599-6-git-send-email-Trond.Myklebust@netapp.com> <1273784901-25599-7-git-send-email-Trond.Myklebust@netapp.com> <1273784901-25599-8-git-send-email-Trond.Myklebust@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:55293 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755094Ab0ENQfL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 May 2010 12:35:11 -0400
In-Reply-To: <1273784901-25599-8-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/13/10 05:08 PM, Trond Myklebust wrote:
> Signed-off-by: Trond Myklebust<Trond.Myklebust@netapp.com>
> ---
>   net/sunrpc/auth.c |    5 ++---
>   1 files changed, 2 insertions(+), 3 deletions(-)
>
> diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
> index 2213dc5..5fb02ac 100644
> --- a/net/sunrpc/auth.c
> +++ b/net/sunrpc/auth.c
> @@ -236,6 +236,8 @@ rpcauth_prune_expired(struct list_head *free, int nr_to_scan)
>
>   	list_for_each_entry_safe(cred, next,&cred_unused, cr_lru) {
>
> +		if (nr_to_scan-- == 0)
> +			break;
>   		/*
>   		 * Enforce a 60 second garbage collection moratorium
>   		 * Note that the cred_unused list must be time-ordered.
> @@ -255,11 +257,8 @@ rpcauth_prune_expired(struct list_head *free, int nr_to_scan)
>   			get_rpccred(cred);
>   			list_add_tail(&cred->cr_lru, free);
>   			rpcauth_unhash_cred_locked(cred);
> -			nr_to_scan--;
>   		}
>   		spin_unlock(cache_lock);
> -		if (nr_to_scan == 0)
> -			break;
>   	}
>   	return (number_cred_unused / 100) * sysctl_vfs_cache_pressure;
>   }

It looks to me like the mm calls our cache shrinker with nr_to_scan set 
to zero when it just wants this return value, and nothing more.  But the 
logic here seems to assume that nr_to_scan == 0 means shrink as much as 
you can.  Am I reading this correctly?
