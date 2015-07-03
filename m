Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:33943 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755362AbbGCNtn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Jul 2015 09:49:43 -0400
Received: by iebmu5 with SMTP id mu5so76900028ieb.1
        for <linux-nfs@vger.kernel.org>; Fri, 03 Jul 2015 06:49:42 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Neil Brown <neilb@suse.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] SUNRPC: Don't reencode message if transmission failed with ENOBUFS
Date: Fri,  3 Jul 2015 09:49:38 -0400
Message-Id: <1435931379-6654-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1435931379-6654-1-git-send-email-trond.myklebust@primarydata.com>
References: <20150629142623.5afc0e6d@noble>
 <1435931379-6654-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we're running out of buffer memory when transmitting data, then
we want to just delay for a moment, and then continue transmitting
the remainder of the message.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/clnt.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index cbc6af923dd1..23608eb0ded2 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1902,6 +1902,7 @@ call_transmit_status(struct rpc_task *task)
 
 	switch (task->tk_status) {
 	case -EAGAIN:
+	case -ENOBUFS:
 		break;
 	default:
 		dprint_status(task);
@@ -1928,7 +1929,6 @@ call_transmit_status(struct rpc_task *task)
 	case -ECONNABORTED:
 	case -EADDRINUSE:
 	case -ENOTCONN:
-	case -ENOBUFS:
 	case -EPIPE:
 		rpc_task_force_reencode(task);
 	}
@@ -2057,12 +2057,13 @@ call_status(struct rpc_task *task)
 	case -ECONNABORTED:
 		rpc_force_rebind(clnt);
 	case -EADDRINUSE:
-	case -ENOBUFS:
 		rpc_delay(task, 3*HZ);
 	case -EPIPE:
 	case -ENOTCONN:
 		task->tk_action = call_bind;
 		break;
+	case -ENOBUFS:
+		rpc_delay(task, HZ>>2);
 	case -EAGAIN:
 		task->tk_action = call_transmit;
 		break;
-- 
2.4.3

