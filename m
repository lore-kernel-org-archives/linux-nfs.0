Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f182.google.com ([209.85.223.182]:52662 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756427Ab3LaTkD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Dec 2013 14:40:03 -0500
Received: by mail-ie0-f182.google.com with SMTP id as1so13490324iec.13
        for <linux-nfs@vger.kernel.org>; Tue, 31 Dec 2013 11:40:02 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Kinglong Mee <kinglongmee@gmail.com>, Chuck Lever <chuck.lever@oracle.com>,
        Bruce Fields <bfields@fieldses.com>,
        Gareth Williams <gareth@garethwilliams.me.uk>
Subject: [PATCH 2/4] SUNRPC: Handle connect errors ECONNABORTED and EHOSTUNREACH
Date: Tue, 31 Dec 2013 14:39:39 -0500
Message-Id: <1388518781-33571-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1388518781-33571-1-git-send-email-trond.myklebust@primarydata.com>
References: <CAB6yy379-A8fgLpQo+ppx5V93P9pXcabvmBJNTZ5hXxeJMuxBg@mail.gmail.com>
 <1388518781-33571-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that call_bind_status, call_connect_status, call_transmit_status and
call_status all are capable of handling ECONNABORTED and EHOSTUNREACH.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/clnt.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index f09b7db2c492..b9276a63eaf1 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1729,6 +1729,7 @@ call_bind_status(struct rpc_task *task)
 		return;
 	case -ECONNREFUSED:		/* connection problems */
 	case -ECONNRESET:
+	case -ECONNABORTED:
 	case -ENOTCONN:
 	case -EHOSTDOWN:
 	case -EHOSTUNREACH:
@@ -1799,7 +1800,9 @@ call_connect_status(struct rpc_task *task)
 		return;
 	case -ECONNREFUSED:
 	case -ECONNRESET:
+	case -ECONNABORTED:
 	case -ENETUNREACH:
+	case -EHOSTUNREACH:
 		/* retry with existing socket, after a delay */
 		rpc_delay(task, 3*HZ);
 		if (RPC_IS_SOFTCONN(task))
@@ -1902,6 +1905,7 @@ call_transmit_status(struct rpc_task *task)
 			break;
 		}
 	case -ECONNRESET:
+	case -ECONNABORTED:
 	case -ENOTCONN:
 	case -EPIPE:
 		rpc_task_force_reencode(task);
@@ -2011,8 +2015,9 @@ call_status(struct rpc_task *task)
 			xprt_conditional_disconnect(req->rq_xprt,
 					req->rq_connect_cookie);
 		break;
-	case -ECONNRESET:
 	case -ECONNREFUSED:
+	case -ECONNRESET:
+	case -ECONNABORTED:
 		rpc_force_rebind(clnt);
 		rpc_delay(task, 3*HZ);
 	case -EPIPE:
-- 
1.8.4.2

