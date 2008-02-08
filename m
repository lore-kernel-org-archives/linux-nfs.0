From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] knfsd: Remove NLM_HOST_MAX and associated logic.
Date: Thu, 7 Feb 2008 22:55:08 -0500
Message-ID: <20080208035508.GC7117@fieldses.org>
References: <20080208130300.14320.patches@notabene> <1080208020337.14371@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: J.Bruce@suse.de, Fields@suse.de, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jeff Layton <jlayton@redhat.com>
To: NeilBrown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pie.citi.umich.edu ([141.211.133.115]:50486 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756174AbYBHDzM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Feb 2008 22:55:12 -0500
In-Reply-To: <1080208020337.14371@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 08, 2008 at 01:03:37PM +1100, NeilBrown wrote:
> 
> Lockd caches information about hosts that have recently held locks it
> expedite the taking of further locks.

Applied, thanks!--b.

> 
> It periodically discards this information for hosts that have not been
> used for a few minutes.
> 
> lockd currently has a value NLM_HOST_MAX, and changes the 'garbage
> collection' behaviour when the number of hosts exceeds this threshold.
> 
> However it's behaviour in strange an likely not what was intended.
> When the number of hosts exceeds the max, it scans *less* often (every
> 2 minutes vs every minute) and allows unused host information to
> remain around longer (5 minutes instead of 2).
> 
> Having this limit is of dubious value anyway, and we have not
> suffered from the code not getting the limit right, so remove the
> limit altogether.  We go with the larger values (discard 5 minute old
> hosts every 2 minutes) as that is probably safer.
> 
> Maybe the periodic garbage collection should be replace to with
> 'shrinker' handler so we just respond to memory pressure....
> 
> Acked-by: Jeff Layton <jlayton@redhat.com>
> Signed-off-by: Neil Brown <neilb@suse.de>
> 
> ### Diffstat output
>  ./fs/lockd/host.c |    9 +++------
>  1 file changed, 3 insertions(+), 6 deletions(-)
> 
> diff .prev/fs/lockd/host.c ./fs/lockd/host.c
> --- .prev/fs/lockd/host.c	2008-02-07 14:20:54.000000000 +1100
> +++ ./fs/lockd/host.c	2008-02-08 12:54:28.000000000 +1100
> @@ -19,12 +19,11 @@
>  
>  
>  #define NLMDBG_FACILITY		NLMDBG_HOSTCACHE
> -#define NLM_HOST_MAX		64
>  #define NLM_HOST_NRHASH		32
>  #define NLM_ADDRHASH(addr)	(ntohl(addr) & (NLM_HOST_NRHASH-1))
>  #define NLM_HOST_REBIND		(60 * HZ)
> -#define NLM_HOST_EXPIRE		((nrhosts > NLM_HOST_MAX)? 300 * HZ : 120 * HZ)
> -#define NLM_HOST_COLLECT	((nrhosts > NLM_HOST_MAX)? 120 * HZ :  60 * HZ)
> +#define NLM_HOST_EXPIRE		(300 * HZ)
> +#define NLM_HOST_COLLECT	(120 * HZ)
>  
>  static struct hlist_head	nlm_hosts[NLM_HOST_NRHASH];
>  static unsigned long		next_gc;
> @@ -142,9 +141,7 @@ nlm_lookup_host(int server, const struct
>  	INIT_LIST_HEAD(&host->h_granted);
>  	INIT_LIST_HEAD(&host->h_reclaim);
>  
> -	if (++nrhosts > NLM_HOST_MAX)
> -		next_gc = 0;
> -
> +	nrhosts++;
>  out:
>  	mutex_unlock(&nlm_host_mutex);
>  	return host;
> -
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
