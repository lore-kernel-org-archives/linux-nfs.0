Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53093 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759428Ab2IEUzd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Sep 2012 16:55:33 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [RFC PATCH 06/13] locks: introduce new FL_DELEG lock flag
Date: Wed,  5 Sep 2012 16:55:16 -0400
Message-Id: <1346878524-10585-7-git-send-email-bfields@redhat.com>
In-Reply-To: <1346878524-10585-1-git-send-email-bfields@redhat.com>
References: <1346878524-10585-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

For now FL_DELEG is just a synonym for FL_LEASE.  So this patch doesn't
change behavior.

Next we'll modify break_lease to treat FL_DELEG leases differently, to
account for the fact that NFSv4 delegations should be broken in more
situations than Windows oplocks.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/locks.c          |    2 +-
 fs/nfsd/nfs4state.c |    2 +-
 include/linux/fs.h  |    1 +
 3 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 669911e..6ee1943 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -131,7 +131,7 @@
 
 #define IS_POSIX(fl)	(fl->fl_flags & FL_POSIX)
 #define IS_FLOCK(fl)	(fl->fl_flags & FL_FLOCK)
-#define IS_LEASE(fl)	(fl->fl_flags & FL_LEASE)
+#define IS_LEASE(fl)	(fl->fl_flags & (FL_LEASE|FL_DELEG))
 
 static bool lease_breaking(struct file_lock *fl)
 {
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 5f1a91a..015267a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2811,7 +2811,7 @@ static struct file_lock *nfs4_alloc_init_lease(struct nfs4_delegation *dp, int f
 		return NULL;
 	locks_init_lock(fl);
 	fl->fl_lmops = &nfsd_lease_mng_ops;
-	fl->fl_flags = FL_LEASE;
+	fl->fl_flags = FL_DELEG;
 	fl->fl_type = flag == NFS4_OPEN_DELEGATE_READ? F_RDLCK: F_WRLCK;
 	fl->fl_end = OFFSET_MAX;
 	fl->fl_owner = (fl_owner_t)(dp->dl_file);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 017070e..c43c893 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1139,6 +1139,7 @@ static inline int file_check_writeable(struct file *filp)
 
 #define FL_POSIX	1
 #define FL_FLOCK	2
+#define FL_DELEG	4	/* NFSv4 delegation */
 #define FL_ACCESS	8	/* not trying to lock, just looking */
 #define FL_EXISTS	16	/* when unlocking, test for existence */
 #define FL_LEASE	32	/* lease held on this file */
-- 
1.7.9.5

