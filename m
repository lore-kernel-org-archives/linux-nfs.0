Return-Path: <SRS0=erep=QP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7DD65C169C4
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Feb 2019 20:11:25 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4EB912177B
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Feb 2019 20:11:25 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727598AbfBHUKt (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 8 Feb 2019 15:10:49 -0500
Received: from fieldses.org ([173.255.197.46]:57040 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727247AbfBHUKt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 8 Feb 2019 15:10:49 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id CDFB23F4; Fri,  8 Feb 2019 15:10:48 -0500 (EST)
From:   "J. Bruce Fields" <bfields@redhat.com>
To:     linux-nfs@vger.kernel.org
Cc:     linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        Trond Myklebust <trondmy@hammerspace.com>,
        Jeff Layton <jlayton@redhat.com>,
        David Howells <dhowells@redhat.com>, Tejun Heo <tj@kernel.org>,
        Peter Zijlstra <peterz@infradead.org>,
        Shaohua Li <shli@fb.com>, Oleg Nesterov <oleg@redhat.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/7] kthreads: Simplify tsk_fork_get_node
Date:   Fri,  8 Feb 2019 15:10:42 -0500
Message-Id: <1549656647-25115-3-git-send-email-bfields@redhat.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1549656647-25115-1-git-send-email-bfields@redhat.com>
References: <1549656647-25115-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: "J. Bruce Fields" <bfields@redhat.com>

This will also simplify a following patch that allows multiple
kthreadd's.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 init/init_task.c | 3 +++
 kernel/fork.c    | 4 ++++
 kernel/kthread.c | 3 +--
 3 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/init/init_task.c b/init/init_task.c
index 5aebe3be4d7c..47e4829ec53f 100644
--- a/init/init_task.c
+++ b/init/init_task.c
@@ -153,6 +153,9 @@ struct task_struct init_task
 	.vtime.starttime = 0,
 	.vtime.state	= VTIME_SYS,
 #endif
+#ifdef CONFIG_NUMA
+	.pref_node_fork = NUMA_NO_NODE,
+#endif
 #ifdef CONFIG_NUMA_BALANCING
 	.numa_preferred_nid = -1,
 	.numa_group	= NULL,
diff --git a/kernel/fork.c b/kernel/fork.c
index b69248e6f0e0..c5b5629de2a9 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -912,6 +912,10 @@ static struct task_struct *dup_task_struct(struct task_struct *orig, int node)
 	tsk->fail_nth = 0;
 #endif
 
+#ifdef CONFIG_NUMA
+	tsk->pref_node_fork = NUMA_NO_NODE;
+#endif
+
 #ifdef CONFIG_BLK_CGROUP
 	tsk->throttle_queue = NULL;
 	tsk->use_memdelay = 0;
diff --git a/kernel/kthread.c b/kernel/kthread.c
index 672f0bbf4d89..4428fd586cd8 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -252,8 +252,7 @@ static int kthread(void *_create)
 int tsk_fork_get_node(struct task_struct *tsk)
 {
 #ifdef CONFIG_NUMA
-	if (tsk == kthreadd_task)
-		return tsk->pref_node_fork;
+	return tsk->pref_node_fork;
 #endif
 	return NUMA_NO_NODE;
 }
-- 
2.20.1

