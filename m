Return-Path: <SRS0=erep=QP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 618BDC282CB
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Feb 2019 20:11:44 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2EE632177B
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Feb 2019 20:11:44 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727445AbfBHULY (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 8 Feb 2019 15:11:24 -0500
Received: from fieldses.org ([173.255.197.46]:57078 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727457AbfBHUKt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 8 Feb 2019 15:10:49 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id EF646BCC; Fri,  8 Feb 2019 15:10:48 -0500 (EST)
From:   "J. Bruce Fields" <bfields@redhat.com>
To:     linux-nfs@vger.kernel.org
Cc:     linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        Trond Myklebust <trondmy@hammerspace.com>,
        Jeff Layton <jlayton@redhat.com>,
        David Howells <dhowells@redhat.com>, Tejun Heo <tj@kernel.org>,
        Peter Zijlstra <peterz@infradead.org>,
        Shaohua Li <shli@fb.com>, Oleg Nesterov <oleg@redhat.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 6/7] rpc: move rpc server threads into their own thread group
Date:   Fri,  8 Feb 2019 15:10:46 -0500
Message-Id: <1549656647-25115-7-git-send-email-bfields@redhat.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1549656647-25115-1-git-send-email-bfields@redhat.com>
References: <1549656647-25115-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: "J. Bruce Fields" <bfields@redhat.com>

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 include/linux/sunrpc/svc.h |  1 +
 net/sunrpc/svc.c           | 23 ++++++++++++++++++-----
 2 files changed, 19 insertions(+), 5 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index e52385340b3b..07d428dd067f 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -101,6 +101,7 @@ struct svc_serv {
 
 	unsigned int		sv_nrpools;	/* number of thread pools */
 	struct svc_pool *	sv_pools;	/* array of thread pools */
+	struct kthread_group *	sv_kthread_grp;
 	const struct svc_serv_ops *sv_ops;	/* server operations */
 #if defined(CONFIG_SUNRPC_BACKCHANNEL)
 	struct list_head	sv_cb_list;	/* queue for callback requests
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 502e09a28f84..d8586a57da40 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -464,10 +464,16 @@ __svc_create(struct svc_program *prog, unsigned int bufsize, int npools,
 	serv->sv_pools =
 		kcalloc(serv->sv_nrpools, sizeof(struct svc_pool),
 			GFP_KERNEL);
-	if (!serv->sv_pools) {
-		kfree(serv);
-		return NULL;
-	}
+	if (!serv->sv_pools)
+		goto out_free_serv;
+
+	serv->sv_kthread_grp = kthread_start_group(CLONE_THREAD |
+					CLONE_SIGHAND | CLONE_VM | CLONE_FS |
+					CLONE_FILES | SIGCHLD,
+					serv->sv_name);
+
+	if (IS_ERR(serv->sv_kthread_grp))
+		goto out_free_pools;
 
 	for (i = 0; i < serv->sv_nrpools; i++) {
 		struct svc_pool *pool = &serv->sv_pools[i];
@@ -482,6 +488,11 @@ __svc_create(struct svc_program *prog, unsigned int bufsize, int npools,
 	}
 
 	return serv;
+out_free_pools:
+	kfree(serv->sv_pools);
+out_free_serv:
+	kfree(serv);
+	return NULL;
 }
 
 struct svc_serv *
@@ -551,6 +562,7 @@ svc_destroy(struct svc_serv *serv)
 	if (svc_serv_is_pooled(serv))
 		svc_pool_map_put();
 
+	kthread_stop_group(serv->sv_kthread_grp);
 	kfree(serv->sv_pools);
 	kfree(serv);
 }
@@ -719,7 +731,8 @@ svc_start_kthread(struct svc_serv *serv, struct svc_pool *pool,
 		return PTR_ERR(rqstp);
 
 	__module_get(serv->sv_ops->svo_module);
-	task = kthread_create_on_node(serv->sv_ops->svo_function, rqstp,
+	task = kthread_group_create_on_node(serv->sv_kthread_grp,
+				      serv->sv_ops->svo_function, rqstp,
 				      node, "%s", serv->sv_name);
 	if (IS_ERR(task)) {
 		module_put(serv->sv_ops->svo_module);
-- 
2.20.1

