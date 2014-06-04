Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36156 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751500AbaFDVDj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Jun 2014 17:03:39 -0400
Date: Wed, 4 Jun 2014 17:03:38 -0400
To: Dave Wysochanski <dwysocha@redhat.com>
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/1] Simplify logic in cache_listeners_exist - only
 return true if someone has the file open.
Message-ID: <20140604210321.GB5603@fieldses.org>
References: <1401891580-28510-1-git-send-email-dwysocha@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1401891580-28510-1-git-send-email-dwysocha@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 04, 2014 at 10:19:40AM -0400, Dave Wysochanski wrote:
> The logic inside cache_listeners_exist contains heuristics to
> determine whether there is a userspace process listening to the cache
> file.  If there is a listener, the kernel will send a request to service
> the cache to userspace, and wait for a response.
> 
> The logic is a bit hard to read, here's some comments which explain the
> existing logic:
>        /*
>         * If at least one process has the channel file open currently,
>         * someone is listening
>         */
>        if (atomic_read(&detail->readers))
>                return true;
>        /*
>         * If no process has ever opened the channel file,
>         * no one is listening
>         */
>        if (detail->last_close == 0)
>                /* This cache was never opened */
>                return false;
>        /*
>         * If the last time we closed the file was more than 30 seconds
>         * ago, no one is listening.
>         */
>        if (detail->last_close < seconds_since_boot() - 30)
>                /*
>                 * We allow for the possibility that someone might
>                 * restart a userspace daemon without restarting the
>                 * server; but after 30 seconds, we give up.
>                 */
>                 return false;
>        /*
>         * In all other cases, assume someone is listening
>         */
>        return true;
> 
> The logic is unduly complicated and unfortunately can be 'fooled' into
> thinking some userspace listener daemon exists when it does not.  For
> example, we've seen where a simple diagnostic process reading all files
> in /proc/net/rpc (for example, tarring the files up into an archive) can
> fool the kernel due to this logic.  Once fooled, the kernel will then
> send requests to validate the cache to userspace thinking some 'cache listener'
> exists, and will timeout.  In the case of the nfs server, this leads to
> silently dropped NFS requests due to failing RPC authentication.
> A simple while loop as follows is enough to DoS the NFS server indefinitely:
> while true; do
>    cat /proc/net/rpc/auth.unix.gid/channel>/dev/null
>    sleep 3
> done
> 
> While a better userspace / kernel registration mechanism for cache listeners
> would be the best solution, for now let's just simplify this logic by requiring
> that there actually be someone holding the 'channel' file open for the kernel
> to consider there's someone actually listening and servicing the cache.
> 
> The only downside is that now userspace daemons which restart will be noticed
> by the kernel during the restart, but I think this makes sense since there's
> no guarantee the listener will come back.

I think this makes sense, thanks, applying.

--b.

> 
> Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
> ---
>  net/sunrpc/cache.c | 14 +-------------
>  1 file changed, 1 insertion(+), 13 deletions(-)
> 
> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
> index ae333c1..d5adefc 100644
> --- a/net/sunrpc/cache.c
> +++ b/net/sunrpc/cache.c
> @@ -1137,19 +1137,7 @@ static void warn_no_listener(struct cache_detail *detail)
>  
>  static bool cache_listeners_exist(struct cache_detail *detail)
>  {
> -	if (atomic_read(&detail->readers))
> -		return true;
> -	if (detail->last_close == 0)
> -		/* This cache was never opened */
> -		return false;
> -	if (detail->last_close < seconds_since_boot() - 30)
> -		/*
> -		 * We allow for the possibility that someone might
> -		 * restart a userspace daemon without restarting the
> -		 * server; but after 30 seconds, we give up.
> -		 */
> -		 return false;
> -	return true;
> +	return atomic_read(&detail->readers);
>  }
>  
>  /*
> -- 
> 1.9.3
> 
