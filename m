Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f53.google.com ([209.85.220.53]:57748 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751808AbaHSPTZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Aug 2014 11:19:25 -0400
Message-ID: <53F36AE2.7070507@gmail.com>
Date: Tue, 19 Aug 2014 23:18:58 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Jeff Layton <jeff.layton@primarydata.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-fsdevel@vger.kernel.org, kinglongmee@gmail.com
Subject: [PATCH 2/6 v4] locks: New ops in file_lock_operations for get/put
 owner
References: <53BAAAC5.9000106@gmail.com>	<53E22EA5.70708@gmail.com> <20140809065112.700e0ecc@tlielax.poochiereds.net> <53E791F1.40802@gmail.com> <53ED5093.6000308@gmail.com>
In-Reply-To: <53ED5093.6000308@gmail.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFSD or other lockmanager may increase the owner's reference,
so adds two new options for copying and releasing owner.

v4: rename lm_copy_owner/lm_release_owner to lm_get_owner/lm_put_owner

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/locks.c         | 12 ++++++++++--
 include/linux/fs.h |  2 ++
 2 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index cb66fb0..08342e0 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -230,8 +230,12 @@ void locks_release_private(struct file_lock *fl)
 			fl->fl_ops->fl_release_private(fl);
 		fl->fl_ops = NULL;
 	}
-	fl->fl_lmops = NULL;
 
+	if (fl->fl_lmops) {
+		if (fl->fl_lmops->lm_put_owner)
+			fl->fl_lmops->lm_put_owner(fl);
+		fl->fl_lmops = NULL;
+	}
 }
 EXPORT_SYMBOL_GPL(locks_release_private);
 
@@ -274,8 +278,12 @@ static void locks_copy_private(struct file_lock *new, struct file_lock *fl)
 			fl->fl_ops->fl_copy_lock(new, fl);
 		new->fl_ops = fl->fl_ops;
 	}
-	if (fl->fl_lmops)
+
+	if (fl->fl_lmops) {
+		if (fl->fl_lmops->lm_get_owner)
+			fl->fl_lmops->lm_get_owner(new, fl);
 		new->fl_lmops = fl->fl_lmops;
+	}
 }
 
 /*
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 908af4f..6829340 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -868,6 +868,8 @@ struct file_lock_operations {
 struct lock_manager_operations {
 	int (*lm_compare_owner)(struct file_lock *, struct file_lock *);
 	unsigned long (*lm_owner_key)(struct file_lock *);
+	void (*lm_get_owner)(struct file_lock *, struct file_lock *);
+	void (*lm_put_owner)(struct file_lock *);
 	void (*lm_notify)(struct file_lock *);	/* unblock callback */
 	int (*lm_grant)(struct file_lock *, int);
 	void (*lm_break)(struct file_lock *);
-- 
1.9.3

