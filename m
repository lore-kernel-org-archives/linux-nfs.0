From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 3/3] lockd: reject reclaims outside the grace period
Date: Mon, 29 Sep 2008 22:44:03 -0400
Message-ID: <1222742643-31541-4-git-send-email-bfields@citi.umich.edu>
References: <1222742643-31541-1-git-send-email-bfields@citi.umich.edu>
 <1222742643-31541-2-git-send-email-bfields@citi.umich.edu>
 <1222742643-31541-3-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47562 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751337AbYI3CoS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Sep 2008 22:44:18 -0400
In-Reply-To: <1222742643-31541-3-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The current lockd does not reject reclaims that arrive outside of the
grace period.

Accepting a reclaim means promising to the client that no conflicting
locks were granted since last it held the lock.  We can meet that
promise if we assume the only lockers are nfs clients, and that they are
sufficiently well-behaved to reclaim only locks that they held before,
and that only reclaim locks have been permitted so far.  Once we leave
the grace period (and start permitting non-reclaims), we can no longer
keep that promise.  So we must start rejecting reclaims at that point.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/lockd/svclock.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index 808d246..6063a8e 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -410,6 +410,10 @@ nlmsvc_lock(struct svc_rqst *rqstp, struct nlm_file *file,
 		ret = nlm_lck_denied_grace_period;
 		goto out;
 	}
+	if (reclaim && !locks_in_grace()) {
+		ret = nlm_lck_denied_grace_period;
+		goto out;
+	}
 
 	if (!wait)
 		lock->fl.fl_flags &= ~FL_SLEEP;
-- 
1.5.5.rc1

