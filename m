Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:48370 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752224AbbBQOty (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Feb 2015 09:49:54 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t1HEnrxp025874
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Tue, 17 Feb 2015 09:49:54 -0500
Message-ID: <54E3550E.4070106@redhat.com>
Date: Tue, 17 Feb 2015 14:49:50 +0000
From: Steven Whitehouse <swhiteho@redhat.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
CC: Don Howard <dhoward@redhat.com>, Steve Dickson <SteveD@redhat.com>
Subject: Re: [RHEL 6.2.z PATCH] [fs] nfs: skip commit in releasepage if we:re
 freeing memory for fs-related reasons (fwd)
References: <alpine.LFD.2.10.1502170645430.11793@piolet>
In-Reply-To: <alpine.LFD.2.10.1502170645430.11793@piolet>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

On 17/02/15 14:47, Don Howard wrote:
> Hi Steven, Steve -
>
> Not sure if you spotted this yet.  It's a hotfix request, we could use
> some help with speedy review.  We've got one reply from bcodding thus far.
>
> Thanks!
>
> --
> -Don
> dhoward@redhat.com
Copying in the NFS team - please take a look and ACK on rhkernel-list if 
you have a spare moment. Thanks,

Steve.
>
> ---------- Forwarded message ----------
> Date: Fri, 13 Feb 2015 15:17:40 +0000
> From: Phillip Lougher <plougher@redhat.com>
> Reply-To: Red Hat INTERNAL-ONLY kernel discussion list
>      <rhkernel-list@redhat.com>
> To: rhkernel-list@redhat.com
> Cc: steved@redhat.com, jlayton@redhat.com, swhiteho@redhat.com
> Subject: [RHEL 6.2.z PATCH] [fs] nfs: skip commit in releasepage if we:re	freeing
>       memory for fs-related reasons
>
> BZ: https://bugzilla.redhat.com/show_bug.cgi?id=1192326
> Brew: http://brewweb.devel.redhat.com/brew/taskinfo?taskID=8732178
>
> Backport of following Rhel-6.4 patch to Rhel-6.2.z.
>
> This patch does not apply to 6.2.z because it is missing the
> patch-set added in BZ 785823 (11 patches).
>
> However, the patch is easy to backport because the failure is due to:
>
> 1. Attempting to patch functionality added in the above patch-set,
>     specifically xs_local_setup_socket()
>
>     This part of the patch has been discarded.
>
> 2. Patching two other functions (which are identical), but patch
>     fails to fuzz them due to the functions having moved
>     significantly in the file (again due to the above patch-set).
>
> -------
>      Message-id: <1343730895-2575-1-git-send-email-jlayton@redhat.com>
>      Patchwork-id: 49134
>      O-Subject: [RHEL6 PATCH] BZ#832434: nfs: skip commit in releasepage if we're freeing memory for fs-related reasons
>      Bugzilla: 832434
>      RH-Acked-by: Steve Dickson <SteveD@redhat.com>
>
>      This patch is not yet in mainline, but is in Trond's tree and should
>      make its way to mainline soon. The bug is here:
>
>          https://bugzilla.redhat.com/show_bug.cgi?id=832434
>
>      ...and the customer that reported it has been successfully testing a
>      backport of this patch to a 6.1.z kernel. The commit ID in Trond's
>      tree is 5cf02d09b50b1ee1c2d536c9cf64af5a7d433f56, but that could change
>      by the time it gets merged into mainline.
>
>      Upstream patch description follows:
>
>      ----------------------[snip]-----------------------
>
>      We've had some reports of a deadlock where rpciod ends up with a stack
>      trace like this:
>
>          PID: 2507   TASK: ffff88103691ab40  CPU: 14  COMMAND: "rpciod/14"
>           #0 [ffff8810343bf2f0] schedule at ffffffff814dabd9
>           #1 [ffff8810343bf3b8] nfs_wait_bit_killable at ffffffffa038fc04 [nfs]
>           #2 [ffff8810343bf3c8] __wait_on_bit at ffffffff814dbc2f
>           #3 [ffff8810343bf418] out_of_line_wait_on_bit at ffffffff814dbcd8
>           #4 [ffff8810343bf488] nfs_commit_inode at ffffffffa039e0c1 [nfs]
>           #5 [ffff8810343bf4f8] nfs_release_page at ffffffffa038bef6 [nfs]
>           #6 [ffff8810343bf528] try_to_release_page at ffffffff8110c670
>           #7 [ffff8810343bf538] shrink_page_list.clone.0 at ffffffff81126271
>           #8 [ffff8810343bf668] shrink_inactive_list at ffffffff81126638
>           #9 [ffff8810343bf818] shrink_zone at ffffffff8112788f
>          #10 [ffff8810343bf8c8] do_try_to_free_pages at ffffffff81127b1e
>          #11 [ffff8810343bf958] try_to_free_pages at ffffffff8112812f
>          #12 [ffff8810343bfa08] __alloc_pages_nodemask at ffffffff8111fdad
>          #13 [ffff8810343bfb28] kmem_getpages at ffffffff81159942
>          #14 [ffff8810343bfb58] fallback_alloc at ffffffff8115a55a
>          #15 [ffff8810343bfbd8] ____cache_alloc_node at ffffffff8115a2d9
>          #16 [ffff8810343bfc38] kmem_cache_alloc at ffffffff8115b09b
>          #17 [ffff8810343bfc78] sk_prot_alloc at ffffffff81411808
>          #18 [ffff8810343bfcb8] sk_alloc at ffffffff8141197c
>          #19 [ffff8810343bfce8] inet_create at ffffffff81483ba6
>          #20 [ffff8810343bfd38] __sock_create at ffffffff8140b4a7
>          #21 [ffff8810343bfd98] xs_create_sock at ffffffffa01f649b [sunrpc]
>          #22 [ffff8810343bfdd8] xs_tcp_setup_socket at ffffffffa01f6965 [sunrpc]
>          #23 [ffff8810343bfe38] worker_thread at ffffffff810887d0
>          #24 [ffff8810343bfee8] kthread at ffffffff8108dd96
>          #25 [ffff8810343bff48] kernel_thread at ffffffff8100c1ca
>
>      rpciod is trying to allocate memory for a new socket to talk to the
>      server. The VM ends up calling ->releasepage to get more memory, and it
>      tries to do a blocking commit. That commit can't succeed however without
>      a connected socket, so we deadlock.
>
>      Fix this by setting PF_FSTRANS on the workqueue task prior to doing the
>      socket allocation, and having nfs_release_page check for that flag when
>      deciding whether to do a commit call. Also, set PF_FSTRANS
>      unconditionally in rpc_async_schedule since that function can also do
>      allocations sometimes.
>
>      Signed-off-by: Jeff Layton <jlayton@redhat.com>
>      Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>      Cc: stable@vger.kernel.org
>
> Signed-off-by: Phillip Lougher <plougher@redhat.com>
> ---
>   fs/nfs/file.c                   | 7 +++++--
>   net/sunrpc/sched.c              | 2 ++
>   net/sunrpc/xprtrdma/transport.c | 3 ++-
>   net/sunrpc/xprtsock.c           | 7 +++++++
>   4 files changed, 16 insertions(+), 3 deletions(-)
>
> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> index 6b31b97..22644e0 100644
> --- a/fs/nfs/file.c
> +++ b/fs/nfs/file.c
> @@ -488,8 +488,11 @@ static int nfs_release_page(struct page *page, gfp_t gfp)
>   
>   	dfprintk(PAGECACHE, "NFS: release_page(%p)\n", page);
>   
> -	/* Only do I/O if gfp is a superset of GFP_KERNEL */
> -	if (mapping && (gfp & GFP_KERNEL) == GFP_KERNEL) {
> +	/* Only do I/O if gfp is a superset of GFP_KERNEL, and we're not
> +	 * doing this memory reclaim for a fs-related allocation.
> +	 */
> +	if (mapping && (gfp & GFP_KERNEL) == GFP_KERNEL &&
> +	    !(current->flags & PF_FSTRANS)) {
>   		int how = FLUSH_SYNC;
>   
>   		/* Don't let kswapd deadlock waiting for OOM RPC calls */
> diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
> index b981b4d..1328537 100644
> --- a/net/sunrpc/sched.c
> +++ b/net/sunrpc/sched.c
> @@ -713,7 +713,9 @@ void rpc_execute(struct rpc_task *task)
>   
>   static void rpc_async_schedule(struct work_struct *work)
>   {
> +	current->flags |= PF_FSTRANS;
>   	__rpc_execute(container_of(work, struct rpc_task, u.tk_work));
> +	current->flags &= ~PF_FSTRANS;
>   }
>   
>   /**
> diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
> index 538589a..e392d2f 100644
> --- a/net/sunrpc/xprtrdma/transport.c
> +++ b/net/sunrpc/xprtrdma/transport.c
> @@ -216,6 +216,7 @@ xprt_rdma_connect_worker(struct work_struct *work)
>   	int rc = 0;
>   
>   	if (!xprt->shutdown) {
> +		current->flags |= PF_FSTRANS;
>   		xprt_clear_connected(xprt);
>   
>   		dprintk("RPC:       %s: %sconnect\n", __func__,
> @@ -228,10 +229,10 @@ xprt_rdma_connect_worker(struct work_struct *work)
>   
>   out:
>   	xprt_wake_pending_tasks(xprt, rc);
> -
>   out_clear:
>   	dprintk("RPC:       %s: exit\n", __func__);
>   	xprt_clear_connecting(xprt);
> +	current->flags &= ~PF_FSTRANS;
>   }
>   
>   /*
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 45be736..7ca3070 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -1700,6 +1700,8 @@ static void xs_udp_setup_socket(struct work_struct *work)
>   	if (xprt->shutdown)
>   		goto out;
>   
> +	current->flags |= PF_FSTRANS;
> +
>   	/* Start by resetting any existing state */
>   	xs_reset_transport(transport);
>   	sock = xs_create_sock(xprt, transport,
> @@ -1718,6 +1720,7 @@ static void xs_udp_setup_socket(struct work_struct *work)
>   out:
>   	xprt_clear_connecting(xprt);
>   	xprt_wake_pending_tasks(xprt, status);
> +	current->flags &= ~PF_FSTRANS;
>   }
>   
>   /*
> @@ -1843,6 +1846,8 @@ static void xs_tcp_setup_socket(struct work_struct *work)
>   	if (xprt->shutdown)
>   		goto out;
>   
> +	current->flags |= PF_FSTRANS;
> +
>   	if (!sock) {
>   		clear_bit(XPRT_CONNECTION_ABORT, &xprt->state);
>   		sock = xs_create_sock(xprt, transport,
> @@ -1892,6 +1897,7 @@ static void xs_tcp_setup_socket(struct work_struct *work)
>   	case -EINPROGRESS:
>   	case -EALREADY:
>   		xprt_clear_connecting(xprt);
> +		current->flags &= ~PF_FSTRANS;
>   		return;
>   	case -EINVAL:
>   		/* Happens, for instance, if the user specified a link
> @@ -1904,6 +1910,7 @@ out_eagain:
>   out:
>   	xprt_clear_connecting(xprt);
>   	xprt_wake_pending_tasks(xprt, status);
> +	current->flags &= ~PF_FSTRANS;
>   }
>   
>   /**

