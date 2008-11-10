From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 56/85] nfs41: client callback structures
Date: Mon, 10 Nov 2008 22:28:14 +0200
Message-ID: <1226348894-9099-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:59992 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752126AbYKJU2W (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:28:22 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ricardo Labiaga <ricardo.labiaga@netapp.com>

Adds new list of rpc_xprt structures, and a readers/writers lock to
protect the list.  The list is used to preallocate resources for
the backchannel during backchannel requests.  Callbacks are not
expected to cause significant latency, so only one callback will
be allowed at this time.

It also adds a pointer to the NFS callback service so that
requests can be directed to it for processing.

Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>

nfs41: NFSv4.1 callback support

New callback members added to svc_serv. The NFSv4.1 callback service will
sleep on the svc_serv->svc_cb_waitq until new callback requests arrive.
The request will be queued in svc_serv->svc_cb_list. This patch adds this
list, the sleep queue and spinlock to svc_serv.

Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 include/linux/sunrpc/svc.h  |   10 ++++++++++
 include/linux/sunrpc/xprt.h |   22 ++++++++++++++++++++++
 2 files changed, 32 insertions(+), 0 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 3afe7fb..1d3b971 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -81,6 +81,16 @@ struct svc_serv {
 	struct module *		sv_module;	/* optional module to count when
 						 * adding threads */
 	svc_thread_fn		sv_function;	/* main function for threads */
+#if defined(CONFIG_NFS_V4_1)
+	struct list_head 	sv_cb_list;	/* queue for callback requests
+						 * that arrive over the same
+						 * connection
+						 */
+	spinlock_t		sv_cb_lock;	/* protects the svc_cb_list */
+	wait_queue_head_t	sv_cb_waitq;	/* sleep here if there are no
+						 * entries in the svc_cb_list
+						 */
+#endif /* CONFIG_NFS_V4_1 */
 };
 
 /*
diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 11fc71d..c5d3c7c 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -97,6 +97,12 @@ struct rpc_rqst {
 
 	unsigned long		rq_xtime;	/* when transmitted */
 	int			rq_ntrans;
+
+#if defined(CONFIG_NFS_V4_1)
+	struct list_head	rq_bc_list;	/* Callback service list */
+	unsigned long		rq_bc_pa_state;	/* Backchannel prealloc state */
+	struct list_head	rq_bc_pa_list;	/* Backchannel prealloc list */
+#endif /* CONFIG_NFS_V4_1 */
 };
 #define rq_svec			rq_snd_buf.head
 #define rq_slen			rq_snd_buf.len
@@ -174,6 +180,14 @@ struct rpc_xprt {
 	spinlock_t		reserve_lock;	/* lock slot table */
 	u32			xid;		/* Next XID value to use */
 	struct rpc_task *	snd_task;	/* Task blocked in send */
+#if defined(CONFIG_NFS_V4_1)
+	struct svc_serv		*bc_serv;	/* The RPC service which will */
+						/* process the callback */
+	spinlock_t		bc_pa_lock;	/* Protects the preallocated */
+						/* items */
+	struct list_head	bc_pa_list;	/* List of preallocated */
+						/* backchannel rpc_rqst's */
+#endif /* CONFIG_NFS_V4_1 */
 	struct list_head	recv;
 
 	struct {
@@ -192,6 +206,14 @@ struct rpc_xprt {
 	const char		*address_strings[RPC_DISPLAY_MAX];
 };
 
+#if defined(CONFIG_NFS_V4_1)
+/*
+ * Backchannel flags
+ */
+#define	RPC_BC_PA_IN_USE	0x0001		/* Preallocated backchannel */
+						/* buffer in use */
+#endif /* CONFIG_NFS_V4_1 */
+
 struct xprt_create {
 	int			ident;		/* XPRT_TRANSPORT identifier */
 	struct sockaddr *	srcaddr;	/* optional local address */
-- 
1.6.0.2

