From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] lockd: fix race in nlm_release()
Date: Wed, 20 Feb 2008 14:11:53 -0500
Message-ID: <20080220191153.GG30160@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:55434 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753079AbYBTTLy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Feb 2008 14:11:54 -0500
Received: from bfields by fieldses.org with local (Exim 4.69)
	(envelope-from <bfields@fieldses.org>)
	id 1JRuMD-0002yE-EE
	for linux-nfs@vger.kernel.org; Wed, 20 Feb 2008 14:11:53 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

The sm_count is decremented to zero but left on the nsm_handles list.
So in the space between decrementing sm_count and acquiring nsm_mutex,
it is possible for another task to find this nsm_handle, increment the
use count and then enter nsm_release itself.

Thus there's nothing to prevent the nsm being freed before we acquire
nsm_mutex here.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/lockd/host.c |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)

Am I missing something here?--b.

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index c3f1194..960911c 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -529,12 +529,10 @@ nsm_release(struct nsm_handle *nsm)
 {
 	if (!nsm)
 		return;
+	mutex_lock(&nsm_mutex);
 	if (atomic_dec_and_test(&nsm->sm_count)) {
-		mutex_lock(&nsm_mutex);
-		if (atomic_read(&nsm->sm_count) == 0) {
-			list_del(&nsm->sm_link);
-			kfree(nsm);
-		}
-		mutex_unlock(&nsm_mutex);
+		list_del(&nsm->sm_link);
+		kfree(nsm);
 	}
+	mutex_unlock(&nsm_mutex);
 }
-- 
1.5.4.rc2.60.gb2e62

