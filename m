Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:32836 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751339Ab1AXWkg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Jan 2011 17:40:36 -0500
Date: Mon, 24 Jan 2011 17:40:32 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: nbowler@elliptictech.com, trond.myklebust@netapp.com,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] NLM: Fix "kernel BUG at fs/lockd/host.c:417!" or
 ".../host.c:283!"
Message-ID: <20110124224031.GB22575@fieldses.org>
References: <20110124204332.1878.35846.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110124204332.1878.35846.stgit@matisse.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Jan 24, 2011 at 03:50:26PM -0500, Chuck Lever wrote:
> Nick Bowler <nbowler@elliptictech.com> reports:
> 
> > We were just having some NFS server troubles, and my client machine
> > running 2.6.38-rc1+ (specifically, commit 2b1caf6ed7b888c95) crashed
> > hard (syslog output appended to this mail).
> >
> > I'm not sure what the exact timeline was or how to reproduce this,
> > but the server was rebooted during all this.  Since I've never seen
> > this happen before, it is possibly a regression from previous kernel
> > releases.  However, I recently updated my nfs-utils (on the client) to
> > version 1.2.3, so that might be related as well.
> 
>   [ BUG output redacted ]
> 
> When done searching, the for_each_host loop in next_host_state() falls
> through and returns the final host on the host chain without bumping
> it's reference count.
> 
> Since the host's ref count is only one at that point, releasing the
> host in nlm_host_rebooted() attempts to destroy the host prematurely,
> and therefore hits a BUG().
> 
> Likely, the original intent of the for_each_host behavior in
> next_host_state() was to handle the case when the host chain is empty.
> Searching the chain and finding no suitable host to return needs to be
> handled as well.
> 
> Defensively restructure next_host_state() always to return NULL when
> the loop falls through.
> 
> Introduced by commit b10e30f6 "lockd: reorganize nlm_host_rebooted".

Whoops, thanks for finding that.  The fix looks right to me.

--b.

> 
> Cc: J. Bruce Fields <bfields@fieldses.org>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
> I was able to reproduce this BUG on my client running 2.6.38-rc2
> from earlier today.  Here is a proposed fix.  I can't reproduce the
> BUG with this patch applied.
> 
> However, my reproducer hit the BUG in nlmsvc_release_host().  Nick hit
> roughly the same BUG in nlmclnt_release_host(), which suggests his
> "client" was also acting as a server.  The symptoms are similar enough
> that I believe this patch should be sufficient to address both cases.
> 
> 
>  fs/lockd/host.c |    9 +++++----
>  1 files changed, 5 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/lockd/host.c b/fs/lockd/host.c
> index 5f1bcb2..b7c99bf 100644
> --- a/fs/lockd/host.c
> +++ b/fs/lockd/host.c
> @@ -520,7 +520,7 @@ static struct nlm_host *next_host_state(struct hlist_head *cache,
>  					struct nsm_handle *nsm,
>  					const struct nlm_reboot *info)
>  {
> -	struct nlm_host *host = NULL;
> +	struct nlm_host *host;
>  	struct hlist_head *chain;
>  	struct hlist_node *pos;
>  
> @@ -532,12 +532,13 @@ static struct nlm_host *next_host_state(struct hlist_head *cache,
>  			host->h_state++;
>  
>  			nlm_get_host(host);
> -			goto out;
> +			mutex_unlock(&nlm_host_mutex);
> +			return host;
>  		}
>  	}
> -out:
> +
>  	mutex_unlock(&nlm_host_mutex);
> -	return host;
> +	return NULL;
>  }
>  
>  /**
> 
