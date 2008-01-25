From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 039/100] lockd: fix a leak in nlmsvc_testlock asynchronous request handling
Date: Fri, 25 Jan 2008 18:16:19 -0500
Message-ID: <1201303040-7779-39-git-send-email-bfields@citi.umich.edu>
References: <20080125231521.GG25141@fieldses.org>
 <1201303040-7779-1-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-2-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-3-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-4-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-5-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-6-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-7-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-8-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-9-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-10-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-11-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-12-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-13-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-14-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-15-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-16-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-17-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-18-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-19-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-20-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-21-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-22-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-23-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-24-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-25-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-26-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-27-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-28-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-29-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-30-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-31-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-32-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-33-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-34-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-35-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-36-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-37-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-38-git-send-email-bfields@citi.umich.edu>
Cc: Oleg Drokin <Oleg.Drokin-UdXhSnd/wVw@public.gmane.org>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47406 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932072AbYAYXRl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 18:17:41 -0500
In-Reply-To: <1201303040-7779-38-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Oleg Drokin <Oleg.Drokin-UdXhSnd/wVw@public.gmane.org>

Without the patch, there is a leakage of nlmblock structure refcount
that holds a reference nlmfile structure, that holds a reference to
struct file, when async GETFL is used (-EINPROGRESS return from
file_ops->lock()), and also in some error cases.

Fix up a style nit while we're here.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/lockd/svclock.c |   18 +++++++++++-------
 1 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index d120ec3..84c4d5e 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -501,25 +501,29 @@ nlmsvc_testlock(struct svc_rqst *rqstp, struct nlm_file *file,
 			block, block->b_flags, block->b_fl);
 		if (block->b_flags & B_TIMED_OUT) {
 			nlmsvc_unlink_block(block);
-			return nlm_lck_denied;
+			ret = nlm_lck_denied;
+			goto out;
 		}
 		if (block->b_flags & B_GOT_CALLBACK) {
 			if (block->b_fl != NULL
 					&& block->b_fl->fl_type != F_UNLCK) {
 				lock->fl = *block->b_fl;
 				goto conf_lock;
-			}
-			else {
+			} else {
 				nlmsvc_unlink_block(block);
-				return nlm_granted;
+				ret = nlm_granted;
+				goto out;
 			}
 		}
-		return nlm_drop_reply;
+		ret = nlm_drop_reply;
+		goto out;
 	}
 
 	error = vfs_test_lock(file->f_file, &lock->fl);
-	if (error == -EINPROGRESS)
-		return nlmsvc_defer_lock_rqst(rqstp, block);
+	if (error == -EINPROGRESS) {
+		ret = nlmsvc_defer_lock_rqst(rqstp, block);
+		goto out;
+	}
 	if (error) {
 		ret = nlm_lck_denied_nolocks;
 		goto out;
-- 
1.5.4.rc2.60.gb2e62

