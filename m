From: andros@netapp.com
Subject: [PATCH] NFS: use correct fs type for v4 submounts and referrals
Date: Fri, 17 Oct 2008 10:44:37 -0400
Message-ID: <1224254677-6999-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:4990 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755314AbYJQOol (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Oct 2008 10:44:41 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson<andros@netapp.com>
---
 fs/nfs/super.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index ffb6974..903058e 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2433,7 +2433,7 @@ static int nfs4_xdev_get_sb(struct file_system_type *fs_type, int flags,
 		compare_super = NULL;
 
 	/* Get a superblock - note that we may end up sharing one that already exists */
-	s = sget(&nfs_fs_type, compare_super, nfs_set_super, &sb_mntdata);
+	s = sget(&nfs4_fs_type, compare_super, nfs_set_super, &sb_mntdata);
 	if (IS_ERR(s)) {
 		error = PTR_ERR(s);
 		goto out_err_nosb;
@@ -2518,7 +2518,7 @@ static int nfs4_referral_get_sb(struct file_system_type *fs_type, int flags,
 		compare_super = NULL;
 
 	/* Get a superblock - note that we may end up sharing one that already exists */
-	s = sget(&nfs_fs_type, compare_super, nfs_set_super, &sb_mntdata);
+	s = sget(&nfs4_fs_type, compare_super, nfs_set_super, &sb_mntdata);
 	if (IS_ERR(s)) {
 		error = PTR_ERR(s);
 		goto out_err_nosb;
-- 
1.5.4.3

