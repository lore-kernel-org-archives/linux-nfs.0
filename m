Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yi0-f46.google.com ([209.85.218.46]:61889 "EHLO
	mail-yi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756288Ab1GGOcR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Jul 2011 10:32:17 -0400
Received: by yia27 with SMTP id 27so394135yia.19
        for <linux-nfs@vger.kernel.org>; Thu, 07 Jul 2011 07:32:17 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] sunrpc: when call_bind fails with -EACCES, don't exit with -EIO
Date: Thu,  7 Jul 2011 10:32:13 -0400
Message-Id: <1310049133-10255-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Commit 0b760113a fixed the client not to loop indefinitely if the
rpcbind was continually failing. When this occurs though, the rpc_task
now exits with a status of -EIO. If the tk_status is -EACCES, it seems
like we should preserve that in this situation.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 net/sunrpc/clnt.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 8c91415..77f6c0c 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1175,8 +1175,10 @@ call_bind_status(struct rpc_task *task)
 			status = -EOPNOTSUPP;
 			break;
 		}
-		if (task->tk_rebind_retry == 0)
+		if (task->tk_rebind_retry == 0) {
+			status = task->tk_status;
 			break;
+		}
 		task->tk_rebind_retry--;
 		rpc_delay(task, 3*HZ);
 		goto retry_timeout;
-- 
1.7.6

