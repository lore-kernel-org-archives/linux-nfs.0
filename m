From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/9] Some improvements to request deferral and related
	code
Date: Fri, 11 Sep 2009 17:07:29 -0400
Message-ID: <20090911210729.GG5701@fieldses.org>
References: <20090909062539.20462.67466.stgit@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: NeilBrown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:35966 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756808AbZIKVHZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Sep 2009 17:07:25 -0400
In-Reply-To: <20090909062539.20462.67466.stgit-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 09, 2009 at 04:32:54PM +1000, NeilBrown wrote:
> Hi,
>  here again are those patches from request deferral improvement set
>  that have not yet been applied.
> 
>  I had previously missed the cache lookups in svcauth_gss, and have now
>  made them work correctly.
> 
>  I also discovered that for NFSv4.1 and later, the current deferral
>  scheme is disabled once the request gets into the NFS layer (i.e. out
>  of the RPC layer).  I don't know that 4.0 doesn't disable it as well
>  - maybe the problems it can cause are more severe with 4.1?

Yes, I think we'd need special handling of the sequence operation, at
least.  I can't recall exactly what the issue was, but we just decided
to give up on deferrals entirely until they were handled in some better
way....

> With
>  this patch set included it might be acceptable to disable the current
>  scheme for 4.0.

Great, thanks.

--b.

> 
>  I believe this is ready for wider testing and probably mainline
>  inclusion.
> 
> Thanks,
> NeilBrown
> 
> 
> ---
> 
> NeilBrown (9):
>       sunrpc: close connection when a request is irretrievably lost.
>       sunrpc/cache: change deferred-request hash table to use hlist.
>       nfsd/idmap: drop special request deferal in favour of improved default.
>       sunrpc/cache: retry cache lookups that return -ETIMEDOUT
>       sunrpc/cache: allow threads to block while waiting for cache update.
>       sunrpc/cache: avoid variable over-loading in cache_defer_req
>       sunrpc/cache: use list_del_init for the list_head entries in cache_deferred_req
>       sunrpc/cache: simplify cache_fresh_locked and cache_fresh_unlocked.
>       sunrpc/cache: change cache_defer_req to return -ve error, not boolean.
> 
> 
>  fs/nfsd/export.c                  |   18 ++++++
>  fs/nfsd/nfs4idmap.c               |  105 ++++------------------------------
>  include/linux/sunrpc/cache.h      |    5 +-
>  include/linux/sunrpc/svcauth.h    |   10 ++-
>  net/sunrpc/auth_gss/svcauth_gss.c |   29 ++++++---
>  net/sunrpc/cache.c                |  115 ++++++++++++++++++++++++-------------
>  net/sunrpc/svc.c                  |    3 +
>  net/sunrpc/svc_xprt.c             |   11 ++++
>  net/sunrpc/svcauth_unix.c         |   34 +++++++++--
>  9 files changed, 176 insertions(+), 154 deletions(-)
> 
> -- 
> Signature
> 
