Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f53.google.com ([209.85.216.53]:40009 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751334Ab2F1O4u (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Jun 2012 10:56:50 -0400
Received: by qaas11 with SMTP id s11so79416qaa.19
        for <linux-nfs@vger.kernel.org>; Thu, 28 Jun 2012 07:56:49 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: Trond.Myklebust@netapp.com
Cc: harshula@redhat.com, linux-nfs@vger.kernel.org, mgorman@suse.de
Subject: [RFC PATCH] nfs: do non-blocking commit in releasepage if we're attempting to reconnect the socket
Date: Thu, 28 Jun 2012 10:51:06 -0400
Message-Id: <1340895066-17626-1-git-send-email-jlayton@redhat.com>
In-Reply-To: <1340890837.5293.11.camel@lade.trondhjem.org>
References: <1340890837.5293.11.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We've had some reports of a deadlock where rpciod ends up with a stack
trace like this:

    PID: 2507   TASK: ffff88103691ab40  CPU: 14  COMMAND: "rpciod/14"
     #0 [ffff8810343bf2f0] schedule at ffffffff814dabd9
     #1 [ffff8810343bf3b8] nfs_wait_bit_killable at ffffffffa038fc04 [nfs]
     #2 [ffff8810343bf3c8] __wait_on_bit at ffffffff814dbc2f
     #3 [ffff8810343bf418] out_of_line_wait_on_bit at ffffffff814dbcd8
     #4 [ffff8810343bf488] nfs_commit_inode at ffffffffa039e0c1 [nfs]
     #5 [ffff8810343bf4f8] nfs_release_page at ffffffffa038bef6 [nfs]
     #6 [ffff8810343bf528] try_to_release_page at ffffffff8110c670
     #7 [ffff8810343bf538] shrink_page_list.clone.0 at ffffffff81126271
     #8 [ffff8810343bf668] shrink_inactive_list at ffffffff81126638
     #9 [ffff8810343bf818] shrink_zone at ffffffff8112788f
    #10 [ffff8810343bf8c8] do_try_to_free_pages at ffffffff81127b1e
    #11 [ffff8810343bf958] try_to_free_pages at ffffffff8112812f
    #12 [ffff8810343bfa08] __alloc_pages_nodemask at ffffffff8111fdad
    #13 [ffff8810343bfb28] kmem_getpages at ffffffff81159942
    #14 [ffff8810343bfb58] fallback_alloc at ffffffff8115a55a
    #15 [ffff8810343bfbd8] ____cache_alloc_node at ffffffff8115a2d9
    #16 [ffff8810343bfc38] kmem_cache_alloc at ffffffff8115b09b
    #17 [ffff8810343bfc78] sk_prot_alloc at ffffffff81411808
    #18 [ffff8810343bfcb8] sk_alloc at ffffffff8141197c
    #19 [ffff8810343bfce8] inet_create at ffffffff81483ba6
    #20 [ffff8810343bfd38] __sock_create at ffffffff8140b4a7
    #21 [ffff8810343bfd98] xs_create_sock at ffffffffa01f649b [sunrpc]
    #22 [ffff8810343bfdd8] xs_tcp_setup_socket at ffffffffa01f6965 [sunrpc]
    #23 [ffff8810343bfe38] worker_thread at ffffffff810887d0
    #24 [ffff8810343bfee8] kthread at ffffffff8108dd96
    #25 [ffff8810343bff48] kernel_thread at ffffffff8100c1ca

The problem is pretty clear. rpciod is trying to allocate memory for a new
socket to talk to the server. The VM ends up calling ->releasepage to get
more memory, and it tries to do a blocking commit. That commit can't
succeed however without a connected socket, so we deadlock.

Fix this by setting PF_FSTRANS on the workqueue task prior to doing the
socket allocation, and having nfs_release_page check for that flag when
deciding whether to do a blocking commit call. Also, set PF_FSTRANS
unconditionally in rpc_async_schedule since that function can also do
allocations sometimes.

Also, cc'ing Mel since I borrowed his tsk_restore_flags helper here, and
this patch may cause merge conflicts with some of his Swap-over-NFS
patches.

Cc: Mel Gorman <mgorman@suse.de>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/file.c                   |    8 ++++++--
 include/linux/sched.h           |    7 +++++++
 net/sunrpc/sched.c              |    4 ++++
 net/sunrpc/xprtrdma/transport.c |    4 +++-
 net/sunrpc/xprtsock.c           |   13 +++++++++++++
 5 files changed, 33 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index a6708e6b..80cc621 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -463,8 +463,12 @@ static int nfs_release_page(struct page *page, gfp_t gfp)
 	if (mapping && (gfp & GFP_KERNEL) == GFP_KERNEL) {
 		int how = FLUSH_SYNC;
 
-		/* Don't let kswapd deadlock waiting for OOM RPC calls */
-		if (current_is_kswapd())
+		/*
+		 * Don't let kswapd deadlock waiting for OOM RPC calls, and
+		 * don't recurse back into the fs if we know that we're trying
+		 * to reclaim memory for an fs-related allocation.
+		 */
+		if (current_is_kswapd() || current->flags & PF_FSTRANS)
 			how = 0;
 		nfs_commit_inode(mapping->host, how);
 	}
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 4059c0f..d71b523 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1889,6 +1889,13 @@ static inline void rcu_switch_from(struct task_struct *prev)
 
 #endif
 
+static inline void tsk_restore_flags(struct task_struct *p,
+			unsigned long pflags, unsigned long mask)
+{
+	p->flags &= ~mask;
+	p->flags |= pflags & mask;
+}
+
 #ifdef CONFIG_SMP
 extern void do_set_cpus_allowed(struct task_struct *p,
 			       const struct cpumask *new_mask);
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 994cfea..5c10ae6 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -790,7 +790,11 @@ void rpc_execute(struct rpc_task *task)
 
 static void rpc_async_schedule(struct work_struct *work)
 {
+	unsigned int pflags = current->flags;
+
+	current->flags |= PF_FSTRANS;
 	__rpc_execute(container_of(work, struct rpc_task, u.tk_work));
+	tsk_restore_flags(current, pflags, PF_FSTRANS);
 }
 
 /**
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index b446e10..7b0f74b 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -197,9 +197,11 @@ xprt_rdma_connect_worker(struct work_struct *work)
 	struct rpcrdma_xprt *r_xprt =
 		container_of(work, struct rpcrdma_xprt, rdma_connect.work);
 	struct rpc_xprt *xprt = &r_xprt->xprt;
+	unsigned long pflags = current->flags;
 	int rc = 0;
 
 	if (!xprt->shutdown) {
+		current->flags |= PF_FSTRANS;
 		xprt_clear_connected(xprt);
 
 		dprintk("RPC:       %s: %sconnect\n", __func__,
@@ -212,10 +214,10 @@ xprt_rdma_connect_worker(struct work_struct *work)
 
 out:
 	xprt_wake_pending_tasks(xprt, rc);
-
 out_clear:
 	dprintk("RPC:       %s: exit\n", __func__);
 	xprt_clear_connecting(xprt);
+	tsk_restore_flags(current, pflags, PF_FSTRANS);
 }
 
 /*
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 890b03f..6c7d8d5 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1890,11 +1890,14 @@ static void xs_local_setup_socket(struct work_struct *work)
 		container_of(work, struct sock_xprt, connect_worker.work);
 	struct rpc_xprt *xprt = &transport->xprt;
 	struct socket *sock;
+	unsigned long pflags = current->flags;
 	int status = -EIO;
 
 	if (xprt->shutdown)
 		goto out;
 
+	current->flags |= PF_FSTRANS;
+
 	clear_bit(XPRT_CONNECTION_ABORT, &xprt->state);
 	status = __sock_create(xprt->xprt_net, AF_LOCAL,
 					SOCK_STREAM, 0, &sock, 1);
@@ -1928,6 +1931,7 @@ static void xs_local_setup_socket(struct work_struct *work)
 out:
 	xprt_clear_connecting(xprt);
 	xprt_wake_pending_tasks(xprt, status);
+	tsk_restore_flags(current, pflags, PF_FSTRANS);
 }
 
 static void xs_udp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
@@ -1965,11 +1969,14 @@ static void xs_udp_setup_socket(struct work_struct *work)
 		container_of(work, struct sock_xprt, connect_worker.work);
 	struct rpc_xprt *xprt = &transport->xprt;
 	struct socket *sock = transport->sock;
+	unsigned long pflags = current->flags;
 	int status = -EIO;
 
 	if (xprt->shutdown)
 		goto out;
 
+	current->flags |= PF_FSTRANS;
+
 	/* Start by resetting any existing state */
 	xs_reset_transport(transport);
 	sock = xs_create_sock(xprt, transport,
@@ -1988,6 +1995,7 @@ static void xs_udp_setup_socket(struct work_struct *work)
 out:
 	xprt_clear_connecting(xprt);
 	xprt_wake_pending_tasks(xprt, status);
+	tsk_restore_flags(current, pflags, PF_FSTRANS);
 }
 
 /*
@@ -2108,11 +2116,14 @@ static void xs_tcp_setup_socket(struct work_struct *work)
 		container_of(work, struct sock_xprt, connect_worker.work);
 	struct socket *sock = transport->sock;
 	struct rpc_xprt *xprt = &transport->xprt;
+	unsigned long pflags = current->flags;
 	int status = -EIO;
 
 	if (xprt->shutdown)
 		goto out;
 
+	current->flags |= PF_FSTRANS;
+
 	if (!sock) {
 		clear_bit(XPRT_CONNECTION_ABORT, &xprt->state);
 		sock = xs_create_sock(xprt, transport,
@@ -2162,6 +2173,7 @@ static void xs_tcp_setup_socket(struct work_struct *work)
 	case -EINPROGRESS:
 	case -EALREADY:
 		xprt_clear_connecting(xprt);
+		tsk_restore_flags(current, pflags, PF_FSTRANS);
 		return;
 	case -EINVAL:
 		/* Happens, for instance, if the user specified a link
@@ -2174,6 +2186,7 @@ out_eagain:
 out:
 	xprt_clear_connecting(xprt);
 	xprt_wake_pending_tasks(xprt, status);
+	tsk_restore_flags(current, pflags, PF_FSTRANS);
 }
 
 /**
-- 
1.7.7.6

