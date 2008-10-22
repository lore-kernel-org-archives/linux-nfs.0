From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 2/3] lockd: allow cancel requests during grace period
Date: Wed, 22 Oct 2008 17:03:21 -0400
Message-ID: <1224709402-6976-3-git-send-email-bfields@citi.umich.edu>
References: <1224709402-6976-1-git-send-email-bfields@citi.umich.edu>
 <1224709402-6976-2-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:42796 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753298AbYJVVDX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Oct 2008 17:03:23 -0400
In-Reply-To: <1224709402-6976-2-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There shouldn't actually be any requests to cancel, so the request will
fail anyway.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/lockd/svclock.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index 9539535..1436ac2 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -591,10 +591,6 @@ nlmsvc_cancel_blocked(struct nlm_file *file, struct nlm_lock *lock)
 				(long long)lock->fl.fl_start,
 				(long long)lock->fl.fl_end);
 
-	/* XXX: ? */
-	if (locks_in_grace())
-		return nlm_lck_denied_grace_period;
-
 	mutex_lock(&file->f_mutex);
 	block = nlmsvc_lookup_block(file, lock);
 	mutex_unlock(&file->f_mutex);
-- 
1.5.5.rc1

