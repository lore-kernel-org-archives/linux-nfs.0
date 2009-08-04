From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 10/12] sunrpc: fix memory leak in unix_gid cache.
Date: Tue, 4 Aug 2009 16:55:54 -0400
Message-ID: <20090804205554.GC24758@fieldses.org>
References: <20090804051145.15929.11356.stgit@notabene.brown> <20090804052239.15929.71459.stgit@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: NeilBrown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:52323 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752680AbZHDUzy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Aug 2009 16:55:54 -0400
In-Reply-To: <20090804052239.15929.71459.stgit-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 04, 2009 at 03:22:39PM +1000, NeilBrown wrote:
> When we look up an entry in the uid->gidlist cache, we take
> a reference to the content but don't drop the reference to the
> cache entry.  So it never gets freed.

Applied, thanks.  (It doesn't seem to depend on the others.)

--b.

> 
> Signed-off-by: NeilBrown <neilb@suse.de>
> ---
> 
>  net/sunrpc/svcauth_unix.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
> index f2de152..0afeb30 100644
> --- a/net/sunrpc/svcauth_unix.c
> +++ b/net/sunrpc/svcauth_unix.c
> @@ -660,6 +660,7 @@ static int unix_gid_find(uid_t uid, struct group_info **gip,
>  	case 0:
>  		*gip = ug->gi;
>  		get_group_info(*gip);
> +		cache_put(&ug->h, &unix_gid_cache);
>  		return 0;
>  	case -ETIMEDOUT:
>  		prevug = ug;
> 
> 
