Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6AED4C4338F
	for <linux-nfs@archiver.kernel.org>; Fri, 20 Aug 2021 21:02:15 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 49072610CC
	for <linux-nfs@archiver.kernel.org>; Fri, 20 Aug 2021 21:02:15 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S240374AbhHTVCs (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 20 Aug 2021 17:02:48 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:41682 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S239999AbhHTVCs (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Aug 2021 17:02:48 -0400
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id A4B35C061756
        for <linux-nfs@vger.kernel.org>; Fri, 20 Aug 2021 14:02:09 -0700 (PDT)
Received: by fieldses.org (Postfix, from userid 2815)
        id B80931297; Fri, 20 Aug 2021 17:02:08 -0400 (EDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org B80931297
From:   "J. Bruce Fields" <bfields@redhat.com>
To:     Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <trondmy@hammerspace.com>,
        Anna Schumaker <schumakeranna@gmail.com>
Cc:     daire@dneg.com, linux-nfs@vger.kernel.org,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/8] lockd: lockd server-side shouldn't set fl_ops
Date:   Fri, 20 Aug 2021 17:01:59 -0400
Message-Id: <1629493326-28336-2-git-send-email-bfields@redhat.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1629493326-28336-1-git-send-email-bfields@redhat.com>
References: <1629493326-28336-1-git-send-email-bfields@redhat.com>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: "J. Bruce Fields" <bfields@redhat.com>

Locks have two sets of op arrays, fl_lmops for the lock manager (lockd
or nfsd), fl_ops for the filesystem.  The server-side lockd code has
been setting its own fl_ops, which leads to confusion (and crashes) in
the reexport case, where the filesystem expects to be the only one
setting fl_ops.

And there's no reason for it that I can see-the lm_get/put_owner ops do
the same job.

Reported-by: Daire Byrne <daire@dneg.com>
Tested-by: Daire Byrne <daire@dneg.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/lockd/svclock.c | 30 ++++++++++++------------------
 1 file changed, 12 insertions(+), 18 deletions(-)

diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index 61d3cc2283dc..1781fc5e9091 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -395,28 +395,10 @@ nlmsvc_release_lockowner(struct nlm_lock *lock)
 		nlmsvc_put_lockowner(lock->fl.fl_owner);
 }
 
-static void nlmsvc_locks_copy_lock(struct file_lock *new, struct file_lock *fl)
-{
-	struct nlm_lockowner *nlm_lo = (struct nlm_lockowner *)fl->fl_owner;
-	new->fl_owner = nlmsvc_get_lockowner(nlm_lo);
-}
-
-static void nlmsvc_locks_release_private(struct file_lock *fl)
-{
-	nlmsvc_put_lockowner((struct nlm_lockowner *)fl->fl_owner);
-}
-
-static const struct file_lock_operations nlmsvc_lock_ops = {
-	.fl_copy_lock = nlmsvc_locks_copy_lock,
-	.fl_release_private = nlmsvc_locks_release_private,
-};
-
 void nlmsvc_locks_init_private(struct file_lock *fl, struct nlm_host *host,
 						pid_t pid)
 {
 	fl->fl_owner = nlmsvc_find_lockowner(host, pid);
-	if (fl->fl_owner != NULL)
-		fl->fl_ops = &nlmsvc_lock_ops;
 }
 
 /*
@@ -788,9 +770,21 @@ nlmsvc_notify_blocked(struct file_lock *fl)
 	printk(KERN_WARNING "lockd: notification for unknown block!\n");
 }
 
+static fl_owner_t nlmsvc_get_owner(fl_owner_t owner)
+{
+	return nlmsvc_get_lockowner(owner);
+}
+
+static void nlmsvc_put_owner(fl_owner_t owner)
+{
+	nlmsvc_put_lockowner(owner);
+}
+
 const struct lock_manager_operations nlmsvc_lock_operations = {
 	.lm_notify = nlmsvc_notify_blocked,
 	.lm_grant = nlmsvc_grant_deferred,
+	.lm_get_owner = nlmsvc_get_owner,
+	.lm_put_owner = nlmsvc_put_owner,
 };
 
 /*
-- 
2.31.1

