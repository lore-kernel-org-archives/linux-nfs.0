Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58273 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756444Ab2ENOGT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 May 2012 10:06:19 -0400
Date: Mon, 14 May 2012 10:06:18 -0400
To: "Theodore Ts'o" <tytso@mit.edu>
Cc: linux-ext4@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: [PATCH] ext4: turn on i_version updates by default
Message-ID: <20120514140618.GA29902@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

knfsd needs i_version updates on, as will userspace nfs servers and
probably others.

The only effects are that inode->i_version is bumped (under the i_lock)
in more places, and that ->dirty_inode(I_DIRTY_DATASYNC) may be called
more frequently than once per jiffy on write (see file_update_time).
However the latter appears to be mostly a no-op in that case.

So, simplify our life and just keep this feature turned on all the time.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/ext4/super.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

If people are worried that the performance impact isn't obvious, I'll
find the time somehow to test this properly....

diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index e1fb1d5..a99f827 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -1483,7 +1483,7 @@ static int handle_mount_opt(struct super_block *sb, char *opt, int token,
 		sbi->s_mount_flags |= EXT4_MF_FS_ABORTED;
 		return 1;
 	case Opt_i_version:
-		sb->s_flags |= MS_I_VERSION;
+		/* no-op; this is on by default now */
 		return 1;
 	case Opt_journal_dev:
 		if (is_remount) {
@@ -2979,6 +2979,7 @@ static int ext4_fill_super(struct super_block *sb, void *data, int silent)
 		goto out_free_orig;
 	}
 	sb->s_fs_info = sbi;
+	sb->s_flags |= MS_I_VERSION;
 	sbi->s_mount_opt = 0;
 	sbi->s_resuid = EXT4_DEF_RESUID;
 	sbi->s_resgid = EXT4_DEF_RESGID;
-- 
1.7.9.5

