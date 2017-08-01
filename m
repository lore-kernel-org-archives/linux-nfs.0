Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:38677 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751872AbdHAQAm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Aug 2017 12:00:42 -0400
Received: by mail-io0-f194.google.com with SMTP id o9so1833806iod.5
        for <linux-nfs@vger.kernel.org>; Tue, 01 Aug 2017 09:00:42 -0700 (PDT)
Subject: [PATCH] sunrpc: Const-ify all instances of struct rpc_xprt_ops
From: Chuck Lever <chuck.lever@oracle.com>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 01 Aug 2017 12:00:39 -0400
Message-ID: <20170801160039.23560.54809.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

After transport instance creation, these function pointers never
change. Mark them as constant to prevent their use as an attack
vector for code injections.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/xprt.h                |    2 +-
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |    2 +-
 net/sunrpc/xprtrdma/transport.c            |    4 ++--
 net/sunrpc/xprtsock.c                      |    8 ++++----
 4 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index eab1c74..f60c55c 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -174,7 +174,7 @@ enum xprt_transports {
 
 struct rpc_xprt {
 	struct kref		kref;		/* Reference count */
-	struct rpc_xprt_ops *	ops;		/* transport methods */
+	const struct rpc_xprt_ops *ops;		/* transport methods */
 
 	const struct rpc_timeout *timeout;	/* timeout parms */
 	struct sockaddr_storage	addr;		/* server address */
diff --git a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
index c676ed0..ca41e28 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
@@ -266,7 +266,7 @@ static int svc_rdma_bc_sendto(struct svcxprt_rdma *rdma,
 	module_put(THIS_MODULE);
 }
 
-static struct rpc_xprt_ops xprt_rdma_bc_procs = {
+static const struct rpc_xprt_ops xprt_rdma_bc_procs = {
 	.reserve_xprt		= xprt_reserve_xprt_cong,
 	.release_xprt		= xprt_release_xprt_cong,
 	.alloc_slot		= xprt_alloc_slot,
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index d1c458e..42752e4 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -149,7 +149,7 @@
 
 #endif
 
-static struct rpc_xprt_ops xprt_rdma_procs;	/*forward reference */
+static const struct rpc_xprt_ops xprt_rdma_procs;
 
 static void
 xprt_rdma_format_addresses4(struct rpc_xprt *xprt, struct sockaddr *sap)
@@ -811,7 +811,7 @@ void xprt_rdma_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
  * Plumbing for rpc transport switch and kernel module
  */
 
-static struct rpc_xprt_ops xprt_rdma_procs = {
+static const struct rpc_xprt_ops xprt_rdma_procs = {
 	.reserve_xprt		= xprt_reserve_xprt_cong,
 	.release_xprt		= xprt_release_xprt_cong, /* sunrpc/xprt.c */
 	.alloc_slot		= xprt_alloc_slot,
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 4f154d3..5cf1700 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2724,7 +2724,7 @@ static void bc_destroy(struct rpc_xprt *xprt)
 	module_put(THIS_MODULE);
 }
 
-static struct rpc_xprt_ops xs_local_ops = {
+static const struct rpc_xprt_ops xs_local_ops = {
 	.reserve_xprt		= xprt_reserve_xprt,
 	.release_xprt		= xs_tcp_release_xprt,
 	.alloc_slot		= xprt_alloc_slot,
@@ -2742,7 +2742,7 @@ static void bc_destroy(struct rpc_xprt *xprt)
 	.disable_swap		= xs_disable_swap,
 };
 
-static struct rpc_xprt_ops xs_udp_ops = {
+static const struct rpc_xprt_ops xs_udp_ops = {
 	.set_buffer_size	= xs_udp_set_buffer_size,
 	.reserve_xprt		= xprt_reserve_xprt_cong,
 	.release_xprt		= xprt_release_xprt_cong,
@@ -2764,7 +2764,7 @@ static void bc_destroy(struct rpc_xprt *xprt)
 	.inject_disconnect	= xs_inject_disconnect,
 };
 
-static struct rpc_xprt_ops xs_tcp_ops = {
+static const struct rpc_xprt_ops xs_tcp_ops = {
 	.reserve_xprt		= xprt_reserve_xprt,
 	.release_xprt		= xs_tcp_release_xprt,
 	.alloc_slot		= xprt_lock_and_alloc_slot,
@@ -2795,7 +2795,7 @@ static void bc_destroy(struct rpc_xprt *xprt)
  * The rpc_xprt_ops for the server backchannel
  */
 
-static struct rpc_xprt_ops bc_tcp_ops = {
+static const struct rpc_xprt_ops bc_tcp_ops = {
 	.reserve_xprt		= xprt_reserve_xprt,
 	.release_xprt		= xprt_release_xprt,
 	.alloc_slot		= xprt_alloc_slot,

