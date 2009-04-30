From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 05/39] nfs41: client callback structures
Date: Fri,  1 May 2009 02:19:42 +0300
Message-ID: <1241133582-448-1-git-send-email-bhalevy@panasas.com>
References: <49FA3180.5030404@panasas.com>
Cc: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>, pnfs@linux-nfs.org,
	linux-nfs@vger.kernel.org,
	Ricardo Labiaga <ricardo.labiaga@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:27515 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754539AbZD3XUB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Apr 2009 19:20:01 -0400
In-Reply-To: <49FA3180.5030404@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>

Adds new list of rpc_xprt structures, and a readers/writers lock to
protect the list.  The list is used to preallocate resources for
the backchannel during backchannel requests.  Callbacks are not
expected to cause significant latency, so only one callback will
be allowed at this time.

It also adds a pointer to the NFS callback service so that
requests can be directed to it for processing.

New callback members added to svc_serv. The NFSv4.1 callback service will
sleep on the svc_serv->svc_cb_waitq until new callback requests arrive.
The request will be queued in svc_serv->svc_cb_list. This patch adds this
list, the sleep queue and spinlock to svc_serv.

[nfs41: NFSv4.1 callback support]
Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 include/linux/sunrpc/svc.h  |    8 ++++++++
 include/linux/sunrpc/xprt.h |   22 ++++++++++++++++++++++
 2 files changed, 30 insertions(+), 0 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 2a30775..4a8afbd 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -96,6 +96,14 @@ struct svc_serv {
 	svc_thread_fn		sv_function;	/* main function for threads */
 	unsigned int		sv_drc_max_pages; /* Total pages for DRC */
 	unsigned int		sv_drc_pages_used;/* DRC pages used */
+#if defined(CONFIG_NFS_V4_1)
+	struct list_head	sv_cb_list;	/* queue for callback requests
+						 * that arrive over the same
+						 * connection */
+	spinlock_t		sv_cb_lock;	/* protects the svc_cb_list */
+	wait_queue_head_t	sv_cb_waitq;	/* sleep here if there are no
+						 * entries in the svc_cb_list */
+#endif /* CONFIG_NFS_V4_1 */
 };
 
 /*
diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 1758d9f..b0867e4 100644
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
+	struct svc_serv		*bc_serv;       /* The RPC service which will */
+						/* process the callback */
+	spinlock_t		bc_pa_lock;	/* Protects the preallocated
+						 * items */
+	struct list_head	bc_pa_list;	/* List of preallocated
+						 * backchannel rpc_rqst's */
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
1.6.2.1

