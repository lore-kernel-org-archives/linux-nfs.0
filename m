Return-Path: <SRS0=erep=QP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 57CD9C169C4
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Feb 2019 20:11:48 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2A39B2177B
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Feb 2019 20:11:48 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727413AbfBHUKt (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 8 Feb 2019 15:10:49 -0500
Received: from fieldses.org ([173.255.197.46]:57028 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727171AbfBHUKt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 8 Feb 2019 15:10:49 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id C9D1C1DCB; Fri,  8 Feb 2019 15:10:48 -0500 (EST)
From:   "J. Bruce Fields" <bfields@redhat.com>
To:     linux-nfs@vger.kernel.org
Cc:     linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        Trond Myklebust <trondmy@hammerspace.com>,
        Jeff Layton <jlayton@redhat.com>,
        David Howells <dhowells@redhat.com>, Tejun Heo <tj@kernel.org>,
        Peter Zijlstra <peterz@infradead.org>,
        Shaohua Li <shli@fb.com>, Oleg Nesterov <oleg@redhat.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/7] kthreads: minor kthreadd refactoring
Date:   Fri,  8 Feb 2019 15:10:41 -0500
Message-Id: <1549656647-25115-2-git-send-email-bfields@redhat.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1549656647-25115-1-git-send-email-bfields@redhat.com>
References: <1549656647-25115-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: "J. Bruce Fields" <bfields@redhat.com>

Trivial refactoring, no change in behavior.

Not really necessary, a separate function for the inner loop just seems
a little nicer to me.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 kernel/kthread.c | 33 +++++++++++++++++++--------------
 1 file changed, 19 insertions(+), 14 deletions(-)

diff --git a/kernel/kthread.c b/kernel/kthread.c
index 087d18d771b5..672f0bbf4d89 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -556,6 +556,24 @@ int kthread_stop(struct task_struct *k)
 }
 EXPORT_SYMBOL(kthread_stop);
 
+void kthread_do_work(void)
+{
+	spin_lock(&kthread_create_lock);
+	while (!list_empty(&kthread_create_list)) {
+		struct kthread_create_info *create;
+
+		create = list_entry(kthread_create_list.next,
+				    struct kthread_create_info, list);
+		list_del_init(&create->list);
+		spin_unlock(&kthread_create_lock);
+
+		create_kthread(create);
+
+		spin_lock(&kthread_create_lock);
+	}
+	spin_unlock(&kthread_create_lock);
+}
+
 int kthreadd(void *unused)
 {
 	struct task_struct *tsk = current;
@@ -575,20 +593,7 @@ int kthreadd(void *unused)
 			schedule();
 		__set_current_state(TASK_RUNNING);
 
-		spin_lock(&kthread_create_lock);
-		while (!list_empty(&kthread_create_list)) {
-			struct kthread_create_info *create;
-
-			create = list_entry(kthread_create_list.next,
-					    struct kthread_create_info, list);
-			list_del_init(&create->list);
-			spin_unlock(&kthread_create_lock);
-
-			create_kthread(create);
-
-			spin_lock(&kthread_create_lock);
-		}
-		spin_unlock(&kthread_create_lock);
+		kthread_do_work();
 	}
 
 	return 0;
-- 
2.20.1

