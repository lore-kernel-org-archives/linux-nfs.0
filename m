Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:35363 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752487AbcBARV7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Feb 2016 12:21:59 -0500
Received: by mail-ig0-f182.google.com with SMTP id t15so40364076igr.0
        for <linux-nfs@vger.kernel.org>; Mon, 01 Feb 2016 09:21:59 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [RFC PATCH v3 02/13] SUNRPC: Reorder rpc_task to put waitqueue related info in same cachelines
Date: Mon,  1 Feb 2016 12:21:06 -0500
Message-Id: <1454347277-10997-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1454347277-10997-2-git-send-email-trond.myklebust@primarydata.com>
References: <1454347277-10997-1-git-send-email-trond.myklebust@primarydata.com>
 <1454347277-10997-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Try to group all the data required by the waitqueues, their timers and timer
callbacks into the same cachelines for performance. With this reordering,
"pahole" reports the following structure on x86_64:

struct rpc_task {
        atomic_t                   tk_count;             /*     0     4 */
        int                        tk_status;            /*     4     4 */
        struct list_head           tk_task;              /*     8    16 */
        void                       (*tk_callback)(struct rpc_task *); /*    24
        void                       (*tk_action)(struct rpc_task *); /*    32
        long unsigned int          tk_timeout;           /*    40     8 */
        long unsigned int          tk_runstate;          /*    48     8 */
        struct rpc_wait_queue *    tk_waitqueue;         /*    56     8 */
        /* --- cacheline 1 boundary (64 bytes) --- */
        union {
                struct work_struct tk_work;              /*          64 */
                struct rpc_wait    tk_wait;              /*          56 */
        } u;                                             /*    64    64 */
        /* --- cacheline 2 boundary (128 bytes) --- */
        struct rpc_message         tk_msg;               /*   128    32 */
        void *                     tk_calldata;          /*   160     8 */
        const struct rpc_call_ops  * tk_ops;             /*   168     8 */
        struct rpc_clnt *          tk_client;            /*   176     8 */
        struct rpc_rqst *          tk_rqstp;             /*   184     8 */
        /* --- cacheline 3 boundary (192 bytes) --- */
        struct workqueue_struct *  tk_workqueue;         /*   192     8 */
        ktime_t                    tk_start;             /*   200     8 */
        pid_t                      tk_owner;             /*   208     4 */
        short unsigned int         tk_flags;             /*   212     2 */
        short unsigned int         tk_timeouts;          /*   214     2 */
        short unsigned int         tk_pid;               /*   216     2 */
        unsigned char              tk_priority:2;        /*   218: 6  1 */
        unsigned char              tk_garb_retry:2;      /*   218: 4  1 */
        unsigned char              tk_cred_retry:2;      /*   218: 2  1 */
        unsigned char              tk_rebind_retry:2;    /*   218: 0  1 */

        /* size: 224, cachelines: 4, members: 24 */
        /* padding: 5 */
        /* last cacheline: 32 bytes */
};

whereas on i386, it reports everything fitting into the 1st cacheline.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 include/linux/sunrpc/sched.h | 29 +++++++++++++++--------------
 1 file changed, 15 insertions(+), 14 deletions(-)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index d703f0ef37d8..ee0fbcf9b02e 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -42,40 +42,41 @@ struct rpc_wait {
  */
 struct rpc_task {
 	atomic_t		tk_count;	/* Reference count */
+	int			tk_status;	/* result of last operation */
 	struct list_head	tk_task;	/* global list of tasks */
-	struct rpc_clnt *	tk_client;	/* RPC client */
-	struct rpc_rqst *	tk_rqstp;	/* RPC request */
-
-	/*
-	 * RPC call state
-	 */
-	struct rpc_message	tk_msg;		/* RPC call info */
 
 	/*
 	 * callback	to be executed after waking up
 	 * action	next procedure for async tasks
-	 * tk_ops	caller callbacks
 	 */
 	void			(*tk_callback)(struct rpc_task *);
 	void			(*tk_action)(struct rpc_task *);
-	const struct rpc_call_ops *tk_ops;
-	void *			tk_calldata;
 
 	unsigned long		tk_timeout;	/* timeout for rpc_sleep() */
 	unsigned long		tk_runstate;	/* Task run status */
-	struct workqueue_struct	*tk_workqueue;	/* Normally rpciod, but could
-						 * be any workqueue
-						 */
+
 	struct rpc_wait_queue 	*tk_waitqueue;	/* RPC wait queue we're on */
 	union {
 		struct work_struct	tk_work;	/* Async task work queue */
 		struct rpc_wait		tk_wait;	/* RPC wait */
 	} u;
 
+	/*
+	 * RPC call state
+	 */
+	struct rpc_message	tk_msg;		/* RPC call info */
+	void *			tk_calldata;	/* Caller private data */
+	const struct rpc_call_ops *tk_ops;	/* Caller callbacks */
+
+	struct rpc_clnt *	tk_client;	/* RPC client */
+	struct rpc_rqst *	tk_rqstp;	/* RPC request */
+
+	struct workqueue_struct	*tk_workqueue;	/* Normally rpciod, but could
+						 * be any workqueue
+						 */
 	ktime_t			tk_start;	/* RPC task init timestamp */
 
 	pid_t			tk_owner;	/* Process id for batching tasks */
-	int			tk_status;	/* result of last operation */
 	unsigned short		tk_flags;	/* misc flags */
 	unsigned short		tk_timeouts;	/* maj timeouts */
 
-- 
2.5.0

