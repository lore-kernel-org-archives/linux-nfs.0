Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.openrapids.net ([64.15.138.104]:58403 "EHLO
	blackscsi.openrapids.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932332Ab2J2Mmd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Oct 2012 08:42:33 -0400
Date: Mon, 29 Oct 2012 08:42:29 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: torvalds@linux-foundation.org, tj@kernel.org, akpm@linux-foundation.org,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org,
        mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com,
        ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org,
        eric.dumazet@gmail.com, axboe@kernel.dk, agk@redhat.com,
        dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com,
        teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org,
        fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com,
        ejt@redhat.com, snitzer@redhat.com, edumazet@google.com,
        linux-nfs@vger.kernel.org, dev@openvswitch.org,
        rds-devel@oss.oracle.com, lw@cn.fujitsu.com
Subject: Re: [PATCH v7 09/16] SUNRPC/cache: use new hashtable implementation
Message-ID: <20121029124229.GC11733@Krystal>
References: <1351450948-15618-1-git-send-email-levinsasha928@gmail.com> <1351450948-15618-9-git-send-email-levinsasha928@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1351450948-15618-9-git-send-email-levinsasha928@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

* Sasha Levin (levinsasha928@gmail.com) wrote:
> Switch cache to use the new hashtable implementation. This reduces the amount of
> generic unrelated code in the cache implementation.
> 
> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
> ---
>  net/sunrpc/cache.c | 20 +++++++++-----------
>  1 file changed, 9 insertions(+), 11 deletions(-)
> 
> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
> index fc2f7aa..0490546 100644
> --- a/net/sunrpc/cache.c
> +++ b/net/sunrpc/cache.c
> @@ -28,6 +28,7 @@
>  #include <linux/workqueue.h>
>  #include <linux/mutex.h>
>  #include <linux/pagemap.h>
> +#include <linux/hashtable.h>
>  #include <asm/ioctls.h>
>  #include <linux/sunrpc/types.h>
>  #include <linux/sunrpc/cache.h>
> @@ -524,19 +525,18 @@ EXPORT_SYMBOL_GPL(cache_purge);
>   * it to be revisited when cache info is available
>   */
>  
> -#define	DFR_HASHSIZE	(PAGE_SIZE/sizeof(struct list_head))
> -#define	DFR_HASH(item)	((((long)item)>>4 ^ (((long)item)>>13)) % DFR_HASHSIZE)
> +#define	DFR_HASH_BITS	9

If we look at a bit of history, mainly commit:

commit 1117449276bb909b029ed0b9ba13f53e4784db9d
Author: NeilBrown <neilb@suse.de>
Date:   Thu Aug 12 17:04:08 2010 +1000

    sunrpc/cache: change deferred-request hash table to use hlist.


we'll notice that the only reason why the prior DFR_HASHSIZE was using

  (PAGE_SIZE/sizeof(struct list_head))

instead of

  (PAGE_SIZE/sizeof(struct hlist_head))

is because it has been forgotten in that commit. The intent there is to
make the hash table array fit the page size.

By defining DFR_HASH_BITS arbitrarily to "9", this indeed fulfills this
purpose on architectures with 4kB page size and 64-bit pointers, but not
on some powerpc configurations, and Tile architectures, which have more
exotic 64kB page size, and of course on the far less exotic 32-bit
pointer architectures.

So defining e.g.:

#include <linux/log2.h>

#define DFR_HASH_BITS  (PAGE_SHIFT - ilog2(BITS_PER_LONG))

would keep the intended behavior in all cases: use one page for the hash
array.

Thanks,

Mathieu

-- 
Mathieu Desnoyers
Operating System Efficiency R&D Consultant
EfficiOS Inc.
http://www.efficios.com
