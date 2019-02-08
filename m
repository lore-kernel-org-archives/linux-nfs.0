Return-Path: <SRS0=erep=QP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A1CEC169C4
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Feb 2019 20:11:43 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 000A32177B
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Feb 2019 20:11:42 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727767AbfBHULY (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 8 Feb 2019 15:11:24 -0500
Received: from fieldses.org ([173.255.197.46]:57080 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727561AbfBHUKt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 8 Feb 2019 15:10:49 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id E98D82012; Fri,  8 Feb 2019 15:10:48 -0500 (EST)
From:   "J. Bruce Fields" <bfields@redhat.com>
To:     linux-nfs@vger.kernel.org
Cc:     linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        Trond Myklebust <trondmy@hammerspace.com>,
        Jeff Layton <jlayton@redhat.com>,
        David Howells <dhowells@redhat.com>, Tejun Heo <tj@kernel.org>,
        Peter Zijlstra <peterz@infradead.org>,
        Shaohua Li <shli@fb.com>, Oleg Nesterov <oleg@redhat.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 5/7] rpc: separate out body of svc_start_kthreads
Date:   Fri,  8 Feb 2019 15:10:45 -0500
Message-Id: <1549656647-25115-6-git-send-email-bfields@redhat.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1549656647-25115-1-git-send-email-bfields@redhat.com>
References: <1549656647-25115-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: "J. Bruce Fields" <bfields@redhat.com>

No change in behavior, just trivial refactoring.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/svc.c | 62 +++++++++++++++++++++++++++++-------------------
 1 file changed, 37 insertions(+), 25 deletions(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index e87ddb9f7feb..502e09a28f84 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -702,40 +702,52 @@ choose_victim(struct svc_serv *serv, struct svc_pool *pool, unsigned int *state)
 	return task;
 }
 
-/* create new threads */
 static int
-svc_start_kthreads(struct svc_serv *serv, struct svc_pool *pool, int nrservs)
+svc_start_kthread(struct svc_serv *serv, struct svc_pool *pool,
+			unsigned int *state)
 {
 	struct svc_rqst	*rqstp;
 	struct task_struct *task;
 	struct svc_pool *chosen_pool;
-	unsigned int state = serv->sv_nrthreads-1;
 	int node;
 
-	do {
-		nrservs--;
-		chosen_pool = choose_pool(serv, pool, &state);
-
-		node = svc_pool_map_get_node(chosen_pool->sp_id);
-		rqstp = svc_prepare_thread(serv, chosen_pool, node);
-		if (IS_ERR(rqstp))
-			return PTR_ERR(rqstp);
-
-		__module_get(serv->sv_ops->svo_module);
-		task = kthread_create_on_node(serv->sv_ops->svo_function, rqstp,
-					      node, "%s", serv->sv_name);
-		if (IS_ERR(task)) {
-			module_put(serv->sv_ops->svo_module);
-			svc_exit_thread(rqstp);
-			return PTR_ERR(task);
-		}
+	chosen_pool = choose_pool(serv, pool, state);
 
-		rqstp->rq_task = task;
-		if (serv->sv_nrpools > 1)
-			svc_pool_map_set_cpumask(task, chosen_pool->sp_id);
+	node = svc_pool_map_get_node(chosen_pool->sp_id);
+	rqstp = svc_prepare_thread(serv, chosen_pool, node);
+	if (IS_ERR(rqstp))
+		return PTR_ERR(rqstp);
 
-		svc_sock_update_bufs(serv);
-		wake_up_process(task);
+	__module_get(serv->sv_ops->svo_module);
+	task = kthread_create_on_node(serv->sv_ops->svo_function, rqstp,
+				      node, "%s", serv->sv_name);
+	if (IS_ERR(task)) {
+		module_put(serv->sv_ops->svo_module);
+		svc_exit_thread(rqstp);
+		return PTR_ERR(task);
+	}
+
+	rqstp->rq_task = task;
+	if (serv->sv_nrpools > 1)
+		svc_pool_map_set_cpumask(task, chosen_pool->sp_id);
+
+	svc_sock_update_bufs(serv);
+	wake_up_process(task);
+	return 0;
+}
+
+/* create new threads */
+static int
+svc_start_kthreads(struct svc_serv *serv, struct svc_pool *pool, int nrservs)
+{
+	unsigned int state = serv->sv_nrthreads-1;
+	int ret;
+
+	do {
+		nrservs--;
+		ret = svc_start_kthread(serv, pool, &state);
+		if (ret)
+			return ret;
 	} while (nrservs > 0);
 
 	return 0;
-- 
2.20.1

