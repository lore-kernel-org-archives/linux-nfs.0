From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 08/15] SUNRPC: Ensure rpcauth_prune_expired() respects
 the nr_to_scan parameter
Date: Fri, 14 May 2010 15:18:59 -0400
Message-ID: <4BEDA223.9080701@oracle.com>
References: <1273784901-25599-1-git-send-email-Trond.Myklebust@netapp.com>	 <1273784901-25599-2-git-send-email-Trond.Myklebust@netapp.com>	 <1273784901-25599-3-git-send-email-Trond.Myklebust@netapp.com>	 <1273784901-25599-4-git-send-email-Trond.Myklebust@netapp.com>	 <1273784901-25599-5-git-send-email-Trond.Myklebust@netapp.com>	 <1273784901-25599-6-git-send-email-Trond.Myklebust@netapp.com>	 <1273784901-25599-7-git-send-email-Trond.Myklebust@netapp.com>	 <1273784901-25599-8-git-send-email-Trond.Myklebust@netapp.com>	 <4BED7BAD.20509@oracle.com> <1273857200.4732.2.camel@localhost.localdomain>	 <4BED894A.6090507@oracle.com>	 <1273860432.4732.30.camel@localhost.localdomain> <1273862242.4732.39.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:32099 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753991Ab0ENTTh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 May 2010 15:19:37 -0400
In-Reply-To: <1273862242.4732.39.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/14/10 02:37 PM, Trond Myklebust wrote:
> On Fri, 2010-05-14 at 14:07 -0400, Trond Myklebust wrote:
>> On Fri, 2010-05-14 at 13:32 -0400, Chuck Lever wrote:
>>> When mm calls with nr_to_scan set to zero, it doesn't expect a -1
>>> return, it just uses the returned value.  mm checks for a -1 return only
>>> when a non-zero scan count argument is passed.
>>>
>>> So the check you added here (and in the access cache shrinker) to return
>>> -1 when the gfp_mask doesn't contain GFP_KERNEL could cause some
>>> trouble.  It would be safer if we return -1 _after_ checking for
>>> nr_to_scan == 0.
>>
>> Oh... You're referring to the change that was added in Patch 6/15
>> SUNRPC: Dont run rpcauth_cache_shrinker() when gfp_mask is GFP_NOFS? I
>> got confused...

Sorry.

>> I can perhaps rather add a check for nr_to_scan != 0 in that patch...
>
> OK... How about the following? (and ditto for the access cache shrinker)

A comment that explains the choice of return codes might be nice, but 
yeah, I guess that will work.  It avoids the need to take the 
rpc_credcache_lock in cases where you can't do any shrinkage anyway.

So, for the series:

Reviewed-by: Chuck Lever <chuck.lever@oracle.com>

Looked at patch 2 and 3, but my understanding of gss and v4 reclaim 
isn't terribly extensive.  I didn't see anything egregious in those two, 
but I can't really comment intelligently on the high-level logic changes.

> --------------------------------------------------------------------------------------------
>> From 8048209c54b95046a23cd994b3d0520757ea5845 Mon Sep 17 00:00:00 2001
> From: Trond Myklebust<Trond.Myklebust@netapp.com>
> Date: Thu, 13 May 2010 12:51:03 -0400
> Subject: [PATCH 06/15] SUNRPC: Dont run rpcauth_cache_shrinker() when gfp_mask is GFP_NOFS
>
> Under some circumstances, put_rpccred() can end up allocating memory, so
> check the gfp_mask to prevent deadlocks.
>
> Signed-off-by: Trond Myklebust<Trond.Myklebust@netapp.com>
> ---
>   net/sunrpc/auth.c |    2 ++
>   1 files changed, 2 insertions(+), 0 deletions(-)
>
> diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
> index 95afe79..0667a36 100644
> --- a/net/sunrpc/auth.c
> +++ b/net/sunrpc/auth.c
> @@ -270,6 +270,8 @@ rpcauth_cache_shrinker(int nr_to_scan, gfp_t gfp_mask)
>   	LIST_HEAD(free);
>   	int res;
>
> +	if ((gfp_mask&  GFP_KERNEL) != GFP_KERNEL)
> +		return (nr_to_scan == 0) ? 0 : -1;
>   	if (list_empty(&cred_unused))
>   		return 0;
>   	spin_lock(&rpc_credcache_lock);

