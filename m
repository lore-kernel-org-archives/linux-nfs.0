Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:37371 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755532Ab3GaOBo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 31 Jul 2013 10:01:44 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r6VE1iJB003672
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 31 Jul 2013 10:01:44 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: jlayton@redhat.com
Subject: [PATCH] NFSv4: Fix the sync mount option for nfs4 mounts
Date: Wed, 31 Jul 2013 10:01:41 -0400
Message-Id: <1375279301-48950-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The sync mount option stopped working for NFSv4 mounts after commit
c02d7adf8c5429727a98bad1d039bccad4c61c50 (NFSv4: Replace nfs4_path_walk() with
FS path lookup in a private namespace).  If MS_SYNCHRONOUS is set in the
super_block that we're cloning from, then it should be set in the new
super_block as well.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 fs/nfs/super.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 71fdc0d..f6db66d 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2478,6 +2478,10 @@ struct dentry *nfs_fs_mount_common(struct nfs_server *server,
 	if (server->flags & NFS_MOUNT_NOAC)
 		sb_mntdata.mntflags |= MS_SYNCHRONOUS;
 
+	if (mount_info->cloned != NULL && mount_info->cloned->sb != NULL)
+		if (mount_info->cloned->sb->s_flags & MS_SYNCHRONOUS)
+			sb_mntdata.mntflags |= MS_SYNCHRONOUS;
+
 	/* Get a superblock - note that we may end up sharing one that already exists */
 	s = sget(nfs_mod->nfs_fs, compare_super, nfs_set_super, flags, &sb_mntdata);
 	if (IS_ERR(s)) {
-- 
1.7.11.7

