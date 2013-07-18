Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:41089 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759317Ab3GRTfn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Jul 2013 15:35:43 -0400
From: <andros@netapp.com>
To: <trond.myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 4 1/5] SUNRPC: don't map EKEYEXPIRED to EACCES in call_refreshresult
Date: Thu, 18 Jul 2013 15:35:26 -0400
Message-ID: <1374176130-11657-2-git-send-email-andros@netapp.com>
In-Reply-To: <1374176130-11657-1-git-send-email-andros@netapp.com>
References: <1374176130-11657-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

The NFS layer needs to know when a key has expired.
This change also returns -EKEYEXPIRED to the application, and the informative
"Key has expired" error message is displayed. The user then knows that
credential renewal is required.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 net/sunrpc/clnt.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index aa40156..68e8595 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1426,9 +1426,9 @@ call_refreshresult(struct rpc_task *task)
 		return;
 	case -ETIMEDOUT:
 		rpc_delay(task, 3*HZ);
-	case -EKEYEXPIRED:
 	case -EAGAIN:
 		status = -EACCES;
+	case -EKEYEXPIRED:
 		if (!task->tk_cred_retry)
 			break;
 		task->tk_cred_retry--;
-- 
1.8.3.1

