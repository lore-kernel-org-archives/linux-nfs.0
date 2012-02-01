Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:52026 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755977Ab2BAHqj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Feb 2012 02:46:39 -0500
Date: Wed, 1 Feb 2012 10:46:20 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
Subject: [patch] SUNRPC: remove an unneeded NULL check in xprt_connect()
Message-ID: <20120201074620.GD22179@elgon.mountain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We check "task->tk_rqstp" and then we dereference it without checking on
the next line.  The only caller is call_connect() and that has a check
which prevents it from calling xprt_connect() with a NULL.

                if (task->tk_status < 0)
                        return;

If "task->tk_rqstp" were NULL then "tk_status" would be -EAGAIN.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 839f6ef..efe5495 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -715,9 +715,7 @@ void xprt_connect(struct rpc_task *task)
 	if (xprt_connected(xprt))
 		xprt_release_write(xprt, task);
 	else {
-		if (task->tk_rqstp)
-			task->tk_rqstp->rq_bytes_sent = 0;
-
+		task->tk_rqstp->rq_bytes_sent = 0;
 		task->tk_timeout = task->tk_rqstp->rq_timeout;
 		rpc_sleep_on(&xprt->pending, task, xprt_connect_status);
 
