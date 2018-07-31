Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:35820 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725886AbeGaWxQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 31 Jul 2018 18:53:16 -0400
From: Mark Fasheh <mfasheh@suse.de>
To: Al Viro <viro@ZenIV.linux.org.uk>, linux-fsdevel@vger.kernel.org
Cc: linux-btrfs@vger.kernel.org,
        Andrew Morton <akpm@linux-foundation.org>,
        Amir Goldstein <amir73il@gmail.com>,
        linux-unionfs@vger.kernel.org, Jeff Mahoney <jeffm@suse.com>,
        linux-nfs@vger.kernel.org, Mark Fasheh <mfasheh@suse.de>
Subject: [PATCH 2/4] nfs: check for NULL vfsmount in nfs_getattr
Date: Tue, 31 Jul 2018 14:10:43 -0700
Message-Id: <20180731211045.5671-3-mfasheh@suse.de>
In-Reply-To: <20180731211045.5671-1-mfasheh@suse.de>
References: <20180731211045.5671-1-mfasheh@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

->getattr from inside the kernel won't always have a vfsmount, check for
this.

Signed-off-by: Mark Fasheh <mfasheh@suse.de>
---
 fs/nfs/inode.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index b65aee481d13..7a3d90a7cc92 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -795,7 +795,9 @@ int nfs_getattr(const struct path *path, struct kstat *stat,
 	}
 
 	/*
-	 * We may force a getattr if the user cares about atime.
+	 * We may force a getattr if the user cares about atime. A
+	 * NULL vfsmount means we are called from inside the kernel,
+	 * where no atime is required.
 	 *
 	 * Note that we only have to check the vfsmount flags here:
 	 *  - NFS always sets S_NOATIME by so checking it would give a
@@ -803,7 +805,7 @@ int nfs_getattr(const struct path *path, struct kstat *stat,
 	 *  - NFS never sets SB_NOATIME or SB_NODIRATIME so there is
 	 *    no point in checking those.
 	 */
-	if ((path->mnt->mnt_flags & MNT_NOATIME) ||
+	if (!path->mnt || (path->mnt->mnt_flags & MNT_NOATIME) ||
 	    ((path->mnt->mnt_flags & MNT_NODIRATIME) && S_ISDIR(inode->i_mode)))
 		request_mask &= ~STATX_ATIME;
 
-- 
2.15.1

