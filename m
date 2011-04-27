Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15446 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759306Ab1D0PtK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Apr 2011 11:49:10 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: don't lose MS_SYNCHRONOUS on remount of noac mount
Date: Wed, 27 Apr 2011 11:49:09 -0400
Message-Id: <1303919349-30207-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

On a remount, the VFS layer will clear the MS_SYNCHRONOUS bit on the
assumption that the flags on the mount syscall will have it set if the
remounted fs is supposed to keep it.

In the case of "noac" though, MS_SYNCHRONOUS is implied. A remount of
such a mount will lose the MS_SYNCHRONOUS flag since "sync" isn't part
of the mount options.

Reported-by: Max Matveev <makc@redhat.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/super.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 2b8e9a5..2f30297 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1976,6 +1976,15 @@ nfs_remount(struct super_block *sb, int *flags, char *raw_data)
 	if (error < 0)
 		goto out;
 
+	/*
+	 * noac is a special case. It implies -o sync, but that's not
+	 * necessarily reflected in the mtab options. do_remount_sb
+	 * will clear MS_SYNCHRONOUS if -o sync wasn't specified in the
+	 * remount options, so we have to explicitly reset it.
+	 */
+	if (data->flags & NFS_MOUNT_NOAC)
+		*flags |= MS_SYNCHRONOUS;
+
 	/* compare new mount options with old ones */
 	error = nfs_compare_remount_data(nfss, data);
 out:
-- 
1.7.1

