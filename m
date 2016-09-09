Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:12508 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753017AbcIINYR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 9 Sep 2016 09:24:17 -0400
From: <andros@netapp.com>
To: <anna.schumaker@netapp.com>
CC: <trond.myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 10 05/12] SUNRPC remove rpc_task_release_client from rpc_task_set_client
Date: Fri, 9 Sep 2016 09:22:22 -0400
Message-ID: <1473427349-13265-6-git-send-email-andros@netapp.com>
In-Reply-To: <1473427349-13265-1-git-send-email-andros@netapp.com>
References: <1473427349-13265-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

rpc_task_set_client is only called from rpc_run_task after
rpc_new_task and rpc_task_release_client is not needed as the
task is new.

When called from rpc_new_task, rpc_task_set_client also removed the
assigned rpc_xprt which is not desired.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 net/sunrpc/clnt.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 6747265..4abc631 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -987,7 +987,6 @@ void rpc_task_set_client(struct rpc_task *task, struct rpc_clnt *clnt)
 {
 
 	if (clnt != NULL) {
-		rpc_task_release_client(task);
 		if (task->tk_xprt == NULL)
 			task->tk_xprt = xprt_iter_get_next(&clnt->cl_xpi);
 		task->tk_client = clnt;
-- 
1.8.3.1

