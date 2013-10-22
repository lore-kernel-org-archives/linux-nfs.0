Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:60003 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753393Ab3JVOV0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Oct 2013 10:21:26 -0400
From: <andros@netapp.com>
To: <trond.myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 5/5] SUNRPC add EKEYEXPIRED case to call_bind_status
Date: Tue, 22 Oct 2013 10:21:16 -0400
Message-ID: <1382451676-2963-6-git-send-email-andros@netapp.com>
In-Reply-To: <1382451676-2963-1-git-send-email-andros@netapp.com>
References: <1382451676-2963-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 net/sunrpc/clnt.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 7352aef..8a5c5b6 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1622,6 +1622,11 @@ call_bind_status(struct rpc_task *task)
 		dprintk("RPC: %5u unrecognized remote rpcbind service\n",
 				task->tk_pid);
 		break;
+	case -EKEYEXPIRED:
+		/* credential key has expired */
+		dprintk("RPC: %5u Credential key has expired\n",
+				task->tk_pid);
+		break;
 	case -EPROTONOSUPPORT:
 		dprintk("RPC: %5u remote rpcbind version unavailable, retrying\n",
 				task->tk_pid);
-- 
1.8.3.1

