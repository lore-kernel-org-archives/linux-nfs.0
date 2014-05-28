Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f179.google.com ([209.85.220.179]:62995 "EHLO
	mail-vc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754328AbaE1X3g (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 May 2014 19:29:36 -0400
Received: by mail-vc0-f179.google.com with SMTP id im17so13327840vcb.10
        for <linux-nfs@vger.kernel.org>; Wed, 28 May 2014 16:29:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.02.1405071257320.25707@chino.kir.corp.google.com>
References: <2562595.ix17LO7uqe@fb07-iapwap2>
	<alpine.DEB.2.02.1405050241180.11071@chino.kir.corp.google.com>
	<20140505070812.470c66bd@tlielax.poochiereds.net>
	<alpine.DEB.2.02.1405071257320.25707@chino.kir.corp.google.com>
Date: Wed, 28 May 2014 19:29:35 -0400
Message-ID: <CAHQdGtQiimjhdz2KJrCHDcDqcGja6c+9XndD37RMzQK5RfcX3A@mail.gmail.com>
Subject: Re: [patch] net, sunrpc: suppress allocation warning in rpc_malloc()
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: David Rientjes <rientjes@google.com>
Cc: David Miller <davem@davemloft.net>, Jeff Layton <jlayton@poochiereds.net>,
        Marc Dietrich <marvin24@gmx.de>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Mel Gorman <mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 7, 2014 at 4:03 PM, David Rientjes <rientjes@google.com> wrote:
> rpc_malloc() allocates with GFP_NOWAIT without making any attempt at
> reclaim so it easily fails when low on memory.  This ends up spamming the
> kernel log:
>
> SLAB: Unable to allocate memory on node 0 (gfp=0x4000)
>   cache: kmalloc-8192, object size: 8192, order: 1
>   node 0: slabs: 207/207, objs: 207/207, free: 0
> rekonq: page allocation failure: order:1, mode:0x204000
> CPU: 2 PID: 14321 Comm: rekonq Tainted: G           O  3.15.0-rc3-12.gfc9498b-desktop+ #6
> Hardware name: System manufacturer System Product Name/M4A785TD-V EVO, BIOS 2105    07/23/2010
>  0000000000000000 ffff880010ff17d0 ffffffff815e693c 0000000000204000
>  ffff880010ff1858 ffffffff81137bd2 0000000000000000 0000001000000000
>  ffff88011ffebc38 0000000000000001 0000000000204000 ffff88011ffea000
> Call Trace:
>  [<ffffffff815e693c>] dump_stack+0x4d/0x6f
>  [<ffffffff81137bd2>] warn_alloc_failed+0xd2/0x140
>  [<ffffffff8113be19>] __alloc_pages_nodemask+0x7e9/0xa30
>  [<ffffffff811824a8>] kmem_getpages+0x58/0x140
>  [<ffffffff81183de6>] fallback_alloc+0x1d6/0x210
>  [<ffffffff81183be3>] ____cache_alloc_node+0x123/0x150
>  [<ffffffff81185953>] __kmalloc+0x203/0x490
>  [<ffffffffa06b0ee2>] rpc_malloc+0x32/0xa0 [sunrpc]
>  [<ffffffffa06a6999>] call_allocate+0xb9/0x170 [sunrpc]
>  [<ffffffffa06b19d8>] __rpc_execute+0x88/0x460 [sunrpc]
>  [<ffffffffa06b2da9>] rpc_execute+0x59/0xc0 [sunrpc]
>  [<ffffffffa06a932b>] rpc_run_task+0x6b/0x90 [sunrpc]
>  [<ffffffffa077b5c1>] nfs4_call_sync_sequence+0x51/0x80 [nfsv4]
>  [<ffffffffa077d45d>] _nfs4_do_setattr+0x1ed/0x280 [nfsv4]
>  [<ffffffffa0782a72>] nfs4_do_setattr+0x72/0x180 [nfsv4]
>  [<ffffffffa078334c>] nfs4_proc_setattr+0xbc/0x140 [nfsv4]
>  [<ffffffffa074a7e8>] nfs_setattr+0xd8/0x240 [nfs]
>  [<ffffffff811baa71>] notify_change+0x231/0x380
>  [<ffffffff8119cf5c>] chmod_common+0xfc/0x120
>  [<ffffffff8119df80>] SyS_chmod+0x40/0x90
>  [<ffffffff815f4cfd>] system_call_fastpath+0x1a/0x1f
> ...
>
> If the allocation fails, simply return NULL and avoid spamming the kernel
> log.
>
> Reported-by: Marc Dietrich <marvin24@gmx.de>
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  net/sunrpc/sched.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
>
> diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
> --- a/net/sunrpc/sched.c
> +++ b/net/sunrpc/sched.c
> @@ -832,7 +832,8 @@ static void rpc_async_schedule(struct work_struct *work)
>   * @size: requested byte size
>   *
>   * To prevent rpciod from hanging, this allocator never sleeps,
> - * returning NULL if the request cannot be serviced immediately.
> + * returning NULL and suppressing warning if the request cannot be serviced
> + * immediately.
>   * The caller can arrange to sleep in a way that is safe for rpciod.
>   *
>   * Most requests are 'small' (under 2KiB) and can be serviced from a
> @@ -845,7 +846,7 @@ static void rpc_async_schedule(struct work_struct *work)
>  void *rpc_malloc(struct rpc_task *task, size_t size)
>  {
>         struct rpc_buffer *buf;
> -       gfp_t gfp = GFP_NOWAIT;
> +       gfp_t gfp = GFP_NOWAIT | __GFP_NOWARN;
>
>         if (RPC_IS_SWAPPER(task))
>                 gfp |= __GFP_MEMALLOC;


Thanks! Applied.

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
