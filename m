From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 4/4] lockd: minor svclock.c style fixes
Date: Tue, 15 Jul 2008 14:48:13 -0400
Message-ID: <1216147693-23881-4-git-send-email-bfields@citi.umich.edu>
References: <20080715184554.GD21590@fieldses.org>
 <1216147693-23881-1-git-send-email-bfields@citi.umich.edu>
 <1216147693-23881-2-git-send-email-bfields@citi.umich.edu>
 <1216147693-23881-3-git-send-email-bfields@citi.umich.edu>
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:39563 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754696AbYGOSs3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jul 2008 14:48:29 -0400
In-Reply-To: <1216147693-23881-3-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/lockd/svclock.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index a6d3ed0..926055c 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -129,9 +129,9 @@ nlmsvc_lookup_block(struct nlm_file *file, struct nlm_lock *lock)
 
 static inline int nlm_cookie_match(struct nlm_cookie *a, struct nlm_cookie *b)
 {
-	if(a->len != b->len)
+	if (a->len != b->len)
 		return 0;
-	if(memcmp(a->data,b->data,a->len))
+	if (memcmp(a->data, b->data,a->len))
 		return 0;
 	return 1;
 }
@@ -381,7 +381,7 @@ nlmsvc_lock(struct svc_rqst *rqstp, struct nlm_file *file,
 	block = nlmsvc_lookup_block(file, lock);
 	if (block == NULL) {
 		block = nlmsvc_create_block(rqstp, nlm_get_host(host), file,
-				lock, cookie);
+					    lock, cookie);
 		ret = nlm_lck_denied_nolocks;
 		if (block == NULL)
 			goto out;
@@ -412,7 +412,7 @@ nlmsvc_lock(struct svc_rqst *rqstp, struct nlm_file *file,
 	lock->fl.fl_flags &= ~FL_SLEEP;
 
 	dprintk("lockd: vfs_lock_file returned %d\n", error);
-	switch(error) {
+	switch (error) {
 		case 0:
 			ret = nlm_granted;
 			goto out;
@@ -880,7 +880,7 @@ nlmsvc_retry_blocked(void)
 
 		if (block->b_when == NLM_NEVER)
 			break;
-	        if (time_after(block->b_when,jiffies)) {
+		if (time_after(block->b_when, jiffies)) {
 			timeout = block->b_when - jiffies;
 			break;
 		}
-- 
1.5.5.rc1

