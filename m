Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:58607 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754940Ab2GBPR4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Jul 2012 11:17:56 -0400
Date: Mon, 2 Jul 2012 11:17:51 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Trond.Myklebust@netapp.com
Cc: harshula@redhat.com, linux-nfs@vger.kernel.org, mgorman@suse.de,
        jan.kratochvil@redhat.com
Subject: Re: [RFC PATCH v2] nfs: skip commit in releasepage if we're freeing
 memory for fs-related reasons
Message-ID: <20120702111751.3ac78d2c@tlielax.poochiereds.net>
In-Reply-To: <1340897113-18449-1-git-send-email-jlayton@redhat.com>
References: <1340895773.5293.18.camel@lade.trondhjem.org>
	<1340897113-18449-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 28 Jun 2012 11:25:13 -0400
Jeff Layton <jlayton@redhat.com> wrote:

> We've had some reports of a deadlock where rpciod ends up with a stack
> trace like this:
> 
>     PID: 2507   TASK: ffff88103691ab40  CPU: 14  COMMAND: "rpciod/14"
>      #0 [ffff8810343bf2f0] schedule at ffffffff814dabd9
>      #1 [ffff8810343bf3b8] nfs_wait_bit_killable at ffffffffa038fc04 [nfs]
>      #2 [ffff8810343bf3c8] __wait_on_bit at ffffffff814dbc2f
>      #3 [ffff8810343bf418] out_of_line_wait_on_bit at ffffffff814dbcd8
>      #4 [ffff8810343bf488] nfs_commit_inode at ffffffffa039e0c1 [nfs]
>      #5 [ffff8810343bf4f8] nfs_release_page at ffffffffa038bef6 [nfs]
>      #6 [ffff8810343bf528] try_to_release_page at ffffffff8110c670
>      #7 [ffff8810343bf538] shrink_page_list.clone.0 at ffffffff81126271
>      #8 [ffff8810343bf668] shrink_inactive_list at ffffffff81126638
>      #9 [ffff8810343bf818] shrink_zone at ffffffff8112788f
>     #10 [ffff8810343bf8c8] do_try_to_free_pages at ffffffff81127b1e
>     #11 [ffff8810343bf958] try_to_free_pages at ffffffff8112812f
>     #12 [ffff8810343bfa08] __alloc_pages_nodemask at ffffffff8111fdad
>     #13 [ffff8810343bfb28] kmem_getpages at ffffffff81159942
>     #14 [ffff8810343bfb58] fallback_alloc at ffffffff8115a55a
>     #15 [ffff8810343bfbd8] ____cache_alloc_node at ffffffff8115a2d9
>     #16 [ffff8810343bfc38] kmem_cache_alloc at ffffffff8115b09b
>     #17 [ffff8810343bfc78] sk_prot_alloc at ffffffff81411808
>     #18 [ffff8810343bfcb8] sk_alloc at ffffffff8141197c
>     #19 [ffff8810343bfce8] inet_create at ffffffff81483ba6
>     #20 [ffff8810343bfd38] __sock_create at ffffffff8140b4a7
>     #21 [ffff8810343bfd98] xs_create_sock at ffffffffa01f649b [sunrpc]
>     #22 [ffff8810343bfdd8] xs_tcp_setup_socket at ffffffffa01f6965 [sunrpc]
>     #23 [ffff8810343bfe38] worker_thread at ffffffff810887d0
>     #24 [ffff8810343bfee8] kthread at ffffffff8108dd96
>     #25 [ffff8810343bff48] kernel_thread at ffffffff8100c1ca
> 
> rpciod is trying to allocate memory for a new socket to talk to the
> server. The VM ends up calling ->releasepage to get more memory, and it
> tries to do a blocking commit. That commit can't succeed however without
> a connected socket, so we deadlock.
> 
> Fix this by setting PF_FSTRANS on the workqueue task prior to doing the
> socket allocation, and having nfs_release_page check for that flag when
> deciding whether to do a commit call. Also, set PF_FSTRANS
> unconditionally in rpc_async_schedule since that function can also do
> allocations sometimes.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/nfs/file.c                   |    7 +++++--
>  net/sunrpc/sched.c              |    2 ++
>  net/sunrpc/xprtrdma/transport.c |    3 ++-
>  net/sunrpc/xprtsock.c           |   10 ++++++++++
>  4 files changed, 19 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> index a6708e6b..9075769 100644
> --- a/fs/nfs/file.c
> +++ b/fs/nfs/file.c
> @@ -459,8 +459,11 @@ static int nfs_release_page(struct page *page, gfp_t gfp)
>  
>  	dfprintk(PAGECACHE, "NFS: release_page(%p)\n", page);
>  
> -	/* Only do I/O if gfp is a superset of GFP_KERNEL */
> -	if (mapping && (gfp & GFP_KERNEL) == GFP_KERNEL) {
> +	/* Only do I/O if gfp is a superset of GFP_KERNEL, and we're not
> +	 * doing this memory reclaim for a fs-related allocation.
> +	 */
> +	if (mapping && (gfp & GFP_KERNEL) == GFP_KERNEL &&
> +	    !(current->flags & PF_FSTRANS)) {
>  		int how = FLUSH_SYNC;
>  
>  		/* Don't let kswapd deadlock waiting for OOM RPC calls */
> diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
> index 994cfea..eda32ae 100644
> --- a/net/sunrpc/sched.c
> +++ b/net/sunrpc/sched.c
> @@ -790,7 +790,9 @@ void rpc_execute(struct rpc_task *task)
>  
>  static void rpc_async_schedule(struct work_struct *work)
>  {
> +	current->flags |= PF_FSTRANS;
>  	__rpc_execute(container_of(work, struct rpc_task, u.tk_work));
> +	current->flags &= ~PF_FSTRANS;
>  }
>  
>  /**
> diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
> index b446e10..06cdbff 100644
> --- a/net/sunrpc/xprtrdma/transport.c
> +++ b/net/sunrpc/xprtrdma/transport.c
> @@ -200,6 +200,7 @@ xprt_rdma_connect_worker(struct work_struct *work)
>  	int rc = 0;
>  
>  	if (!xprt->shutdown) {
> +		current->flags |= PF_FSTRANS;
>  		xprt_clear_connected(xprt);
>  
>  		dprintk("RPC:       %s: %sconnect\n", __func__,
> @@ -212,10 +213,10 @@ xprt_rdma_connect_worker(struct work_struct *work)
>  
>  out:
>  	xprt_wake_pending_tasks(xprt, rc);
> -
>  out_clear:
>  	dprintk("RPC:       %s: exit\n", __func__);
>  	xprt_clear_connecting(xprt);
> +	current->flags &= ~PF_FSTRANS;
>  }
>  
>  /*
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 890b03f..b88c6bf 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -1895,6 +1895,8 @@ static void xs_local_setup_socket(struct work_struct *work)
>  	if (xprt->shutdown)
>  		goto out;
>  
> +	current->flags |= PF_FSTRANS;
> +
>  	clear_bit(XPRT_CONNECTION_ABORT, &xprt->state);
>  	status = __sock_create(xprt->xprt_net, AF_LOCAL,
>  					SOCK_STREAM, 0, &sock, 1);
> @@ -1928,6 +1930,7 @@ static void xs_local_setup_socket(struct work_struct *work)
>  out:
>  	xprt_clear_connecting(xprt);
>  	xprt_wake_pending_tasks(xprt, status);
> +	current->flags &= ~PF_FSTRANS;
>  }
>  
>  static void xs_udp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
> @@ -1970,6 +1973,8 @@ static void xs_udp_setup_socket(struct work_struct *work)
>  	if (xprt->shutdown)
>  		goto out;
>  
> +	current->flags |= PF_FSTRANS;
> +
>  	/* Start by resetting any existing state */
>  	xs_reset_transport(transport);
>  	sock = xs_create_sock(xprt, transport,
> @@ -1988,6 +1993,7 @@ static void xs_udp_setup_socket(struct work_struct *work)
>  out:
>  	xprt_clear_connecting(xprt);
>  	xprt_wake_pending_tasks(xprt, status);
> +	current->flags &= ~PF_FSTRANS;
>  }
>  
>  /*
> @@ -2113,6 +2119,8 @@ static void xs_tcp_setup_socket(struct work_struct *work)
>  	if (xprt->shutdown)
>  		goto out;
>  
> +	current->flags |= PF_FSTRANS;
> +
>  	if (!sock) {
>  		clear_bit(XPRT_CONNECTION_ABORT, &xprt->state);
>  		sock = xs_create_sock(xprt, transport,
> @@ -2162,6 +2170,7 @@ static void xs_tcp_setup_socket(struct work_struct *work)
>  	case -EINPROGRESS:
>  	case -EALREADY:
>  		xprt_clear_connecting(xprt);
> +		current->flags &= ~PF_FSTRANS;
>  		return;
>  	case -EINVAL:
>  		/* Happens, for instance, if the user specified a link
> @@ -2174,6 +2183,7 @@ out_eagain:
>  out:
>  	xprt_clear_connecting(xprt);
>  	xprt_wake_pending_tasks(xprt, status);
> +	current->flags &= ~PF_FSTRANS;
>  }
>  
>  /**

I've given a backported version of the above patch to a customer and
they're testing it now. It may be some time before we have any results
however. In the meantime, someone reported this bug against Fedora 16
which is a similar situation:

    https://bugzilla.redhat.com/show_bug.cgi?id=834808

Here's the stack trace of interest:

# cat /proc/pid-of-openvpn/stack 
[<ffffffffa08484a9>] nfs_wait_bit_killable+0x39/0x90 [nfs]
[<ffffffffa085737a>] nfs_commit_inode+0xaa/0x250 [nfs]
[<ffffffffa0845f14>] nfs_release_page+0x84/0xa0 [nfs]
[<ffffffff811205f2>] try_to_release_page+0x32/0x50
[<ffffffff81133e62>] shrink_page_list+0x792/0x9a0
[<ffffffff81134484>] shrink_inactive_list+0x184/0x4f0
[<ffffffff81134fc8>] shrink_mem_cgroup_zone+0x448/0x5d0
[<ffffffff811351c6>] shrink_zone+0x76/0xa0
[<ffffffff81135564>] do_try_to_free_pages+0x104/0x5c0
[<ffffffff81135cfb>] try_to_free_pages+0xab/0x170
[<ffffffff811299dc>] __alloc_pages_nodemask+0x53c/0x8f0
[<ffffffff81161273>] alloc_pages_current+0xa3/0x110
[<ffffffff8116c2e5>] new_slab+0x245/0x2f0
[<ffffffff815ed28d>] __slab_alloc+0x32b/0x440
[<ffffffff8116f2b7>] __kmalloc_node_track_caller+0x97/0x1f0
[<ffffffff814d9678>] __alloc_skb+0x78/0x230
[<ffffffff814d3fbc>] sock_alloc_send_pskb+0x1ac/0x2f0
[<ffffffff814d4115>] sock_alloc_send_skb+0x15/0x20
[<ffffffff81520861>] __ip_append_data+0x711/0xa10
[<ffffffff81522bd0>] ip_make_skb+0xd0/0x110
[<ffffffff815464ef>] udp_sendmsg+0x2df/0x990
[<ffffffff81550f24>] inet_sendmsg+0x64/0xb0
[<ffffffff814cedc7>] sock_sendmsg+0x117/0x130
[<ffffffff814d22bd>] sys_sendto+0x13d/0x190
[<ffffffff815fc5e9>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff

Here, they're mounting over openvpn and it deadlocks in a similar
fashion. The openvpn process is to get memory to send a frame on the
"physical" connection, but that won't happen until the commit comes
back.

Perhaps we should also take something like the (untested) patch below
on top of the patch above? Note that kswapd always has PF_MEMALLOC set:

-----------------[snip]--------------------

nfs: broaden the cases where we use a non-blocking commit in releasepage

Currently, we just do a non-blocking commit when called from kswapd, but
that still gives us some cases where we end up blocking after recursing
back into the filesystem. Instead, turn that check into a check for
PF_MEMALLOC so that we never block when trying to free memory in order to
satisfy an allocation.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/file.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 9075769..61d3670 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -466,8 +466,8 @@ static int nfs_release_page(struct page *page, gfp_t gfp)
 	    !(current->flags & PF_FSTRANS)) {
 		int how = FLUSH_SYNC;
 
-		/* Don't let kswapd deadlock waiting for OOM RPC calls */
-		if (current_is_kswapd())
+		/* Don't block if we're freeing for a memory allocation */
+		if (current->flags & PF_MEMALLOC)
 			how = 0;
 		nfs_commit_inode(mapping->host, how);
 	}
-- 
1.7.7.6

