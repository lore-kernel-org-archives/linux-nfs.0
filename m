Return-Path: <SRS0=erep=QP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C689EC169C4
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Feb 2019 20:11:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A289F2177B
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Feb 2019 20:11:23 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727605AbfBHUKt (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 8 Feb 2019 15:10:49 -0500
Received: from fieldses.org ([173.255.197.46]:57048 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727305AbfBHUKt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 8 Feb 2019 15:10:49 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id DC9C91E3B; Fri,  8 Feb 2019 15:10:48 -0500 (EST)
From:   "J. Bruce Fields" <bfields@redhat.com>
To:     linux-nfs@vger.kernel.org
Cc:     linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        Trond Myklebust <trondmy@hammerspace.com>,
        Jeff Layton <jlayton@redhat.com>,
        David Howells <dhowells@redhat.com>, Tejun Heo <tj@kernel.org>,
        Peter Zijlstra <peterz@infradead.org>,
        Shaohua Li <shli@fb.com>, Oleg Nesterov <oleg@redhat.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 4/7] kthreads: allow cloning threads with different flags
Date:   Fri,  8 Feb 2019 15:10:44 -0500
Message-Id: <1549656647-25115-5-git-send-email-bfields@redhat.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1549656647-25115-1-git-send-email-bfields@redhat.com>
References: <1549656647-25115-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: "J. Bruce Fields" <bfields@redhat.com>

This is so knfsd can add CLONE_THREAD.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 include/linux/kthread.h |  3 ++-
 kernel/kthread.c        | 11 +++++++----
 2 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/include/linux/kthread.h b/include/linux/kthread.h
index 10b5836dfb2a..988aa77f9811 100644
--- a/include/linux/kthread.h
+++ b/include/linux/kthread.h
@@ -11,11 +11,12 @@ struct kthread_group {
 	spinlock_t create_lock;
 	struct list_head create_list;
 	struct task_struct *task;
+	unsigned long flags;
 };
 
 extern struct kthread_group kthreadd_default;
 
-struct kthread_group *kthread_start_group(char *);
+struct kthread_group *kthread_start_group(unsigned long, char *);
 void kthread_stop_group(struct kthread_group *);
 
 struct task_struct *kthread_group_create_on_node(struct kthread_group *,
diff --git a/kernel/kthread.c b/kernel/kthread.c
index b515557b98c9..e24ef5afa651 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -26,6 +26,7 @@ struct kthread_group kthreadd_default = {
 	.name = "kthreadd",
 	.create_lock = __SPIN_LOCK_UNLOCKED(kthreadd_default.create_lock),
 	.create_list = LIST_HEAD_INIT(kthreadd_default.create_list),
+	.flags = CLONE_FS | CLONE_FILES | SIGCHLD,
 };
 
 void wake_kthreadd(struct kthread_group *kg)
@@ -33,7 +34,7 @@ void wake_kthreadd(struct kthread_group *kg)
 	wake_up_process(kg->task);
 }
 
-struct kthread_group *kthread_start_group(char *name)
+struct kthread_group *kthread_start_group(unsigned long flags, char *name)
 {
 	struct kthread_group *new;
 	struct task_struct *task;
@@ -44,6 +45,7 @@ struct kthread_group *kthread_start_group(char *name)
 	spin_lock_init(&new->create_lock);
 	INIT_LIST_HEAD(&new->create_list);
 	new->name = name;
+	new->flags = flags;
 	task = kthread_run(kthreadd, new, name);
 	if (IS_ERR(task)) {
 		kfree(new);
@@ -292,7 +294,8 @@ int tsk_fork_get_node(struct task_struct *tsk)
 	return NUMA_NO_NODE;
 }
 
-static void create_kthread(struct kthread_create_info *create)
+static void create_kthread(struct kthread_create_info *create,
+			   unsigned long flags)
 {
 	int pid;
 
@@ -300,7 +303,7 @@ static void create_kthread(struct kthread_create_info *create)
 	current->pref_node_fork = create->node;
 #endif
 	/* We want our own signal handler (we take no signals by default). */
-	pid = kernel_thread(kthread, create, CLONE_FS | CLONE_FILES | SIGCHLD);
+	pid = kernel_thread(kthread, create, flags);
 	if (pid < 0) {
 		/* If user was SIGKILLed, I release the structure. */
 		struct completion *done = xchg(&create->done, NULL);
@@ -623,7 +626,7 @@ void kthread_do_work(struct kthread_group *kg)
 		list_del_init(&create->list);
 		spin_unlock(&kg->create_lock);
 
-		create_kthread(create);
+		create_kthread(create, kg->flags);
 
 		spin_lock(&kg->create_lock);
 	}
-- 
2.20.1

