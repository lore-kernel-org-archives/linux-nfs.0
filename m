From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 029/112] SUNRPC: Cleanup to remove the last users of the
	RPC_WAITQ declaration
Date: Fri, 25 Jan 2008 11:37:31 -0500
Message-ID: <20080125163731.31887.32569.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:50284 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757112AbYAYRCR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:02:17 -0500
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PH1HAC020978
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:02:04 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/sched.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 96f4fdd..fb6d30f 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -45,7 +45,7 @@ static void			 rpc_release_task(struct rpc_task *task);
 /*
  * RPC tasks sit here while waiting for conditions to improve.
  */
-static RPC_WAITQ(delay_queue, "delayq");
+static struct rpc_wait_queue delay_queue;
 
 /*
  * rpciod-related stuff
@@ -1060,6 +1060,11 @@ rpc_init_mempool(void)
 		goto err_nomem;
 	if (!rpciod_start())
 		goto err_nomem;
+	/*
+	 * The following is not strictly a mempool initialisation,
+	 * but there is no harm in doing it here
+	 */
+	rpc_init_wait_queue(&delay_queue, "delayq");
 	return 0;
 err_nomem:
 	rpc_destroy_mempool();
