Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:32472 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753688Ab0EMVIb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 May 2010 17:08:31 -0400
Received: from localhost.localdomain (heimdal.trondhjem.org [10.58.49.73] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o4DL8MCX021257
	for <linux-nfs@vger.kernel.org>; Thu, 13 May 2010 14:08:30 -0700 (PDT)
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 14/15] SUNRPC: Reorder the struct rpc_task fields
Date: Thu, 13 May 2010 17:08:20 -0400
Message-Id: <1273784901-25599-14-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1273784901-25599-13-git-send-email-Trond.Myklebust@netapp.com>
References: <1273784901-25599-1-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-2-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-3-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-4-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-5-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-6-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-7-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-8-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-9-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-10-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-11-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-12-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-13-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This improves the packing of the rpc_task, and ensures that on 64-bit
platforms the size reduces to 216 bytes.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 include/linux/sunrpc/sched.h |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 41b9f97..7be4f3a 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -45,14 +45,11 @@ struct rpc_task {
 	struct list_head	tk_task;	/* global list of tasks */
 	struct rpc_clnt *	tk_client;	/* RPC client */
 	struct rpc_rqst *	tk_rqstp;	/* RPC request */
-	int			tk_status;	/* result of last operation */
 
 	/*
 	 * RPC call state
 	 */
 	struct rpc_message	tk_msg;		/* RPC call info */
-	__u8			tk_garb_retry;
-	__u8			tk_cred_retry;
 
 	/*
 	 * callback	to be executed after waking up
@@ -65,7 +62,6 @@ struct rpc_task {
 	void *			tk_calldata;
 
 	unsigned long		tk_timeout;	/* timeout for rpc_sleep() */
-	unsigned short		tk_flags;	/* misc flags */
 	unsigned long		tk_runstate;	/* Task run status */
 	struct workqueue_struct	*tk_workqueue;	/* Normally rpciod, but could
 						 * be any workqueue
@@ -76,15 +72,19 @@ struct rpc_task {
 		struct rpc_wait		tk_wait;	/* RPC wait */
 	} u;
 
-	unsigned short		tk_timeouts;	/* maj timeouts */
 	ktime_t			tk_start;	/* RPC task init timestamp */
 
 	pid_t			tk_owner;	/* Process id for batching tasks */
-	unsigned char		tk_priority : 2;/* Task priority */
+	int			tk_status;	/* result of last operation */
+	unsigned short		tk_flags;	/* misc flags */
+	unsigned short		tk_timeouts;	/* maj timeouts */
 
 #ifdef RPC_DEBUG
 	unsigned short		tk_pid;		/* debugging aid */
 #endif
+	unsigned char		tk_priority : 2,/* Task priority */
+				tk_garb_retry : 2,
+				tk_cred_retry : 2;
 };
 #define tk_xprt			tk_client->cl_xprt
 
-- 
1.6.6.1

