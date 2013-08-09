Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f178.google.com ([209.85.160.178]:34158 "EHLO
	mail-gh0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968210Ab3HIQvK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Aug 2013 12:51:10 -0400
Received: by mail-gh0-f178.google.com with SMTP id g15so1280841ghb.37
        for <linux-nfs@vger.kernel.org>; Fri, 09 Aug 2013 09:51:10 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe44:ec31])
        by mx.google.com with ESMTPSA id f67sm20691811yhh.9.2013.08.09.09.51.08
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 09 Aug 2013 09:51:09 -0700 (PDT)
Subject: [PATCH v2 23/33] NFS: Add a super_block backpointer to the
 nfs_server struct
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 09 Aug 2013 12:51:07 -0400
Message-ID: <20130809165107.5362.68985.stgit@seurat.1015granger.net>
In-Reply-To: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
References: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFS_SB() returns the pointer to an nfs_server struct, given a
pointer to a super_block.  But we have no way to go back the other
way.

Add a super_block backpointer field so that, given an nfs_server
struct, it is easy to get to the filesystem's root dentry.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/super.c            |    1 +
 include/linux/nfs_fs_sb.h |    1 +
 2 files changed, 2 insertions(+)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 71fdc0d..f530ee5 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2494,6 +2494,7 @@ struct dentry *nfs_fs_mount_common(struct nfs_server *server,
 			mntroot = ERR_PTR(error);
 			goto error_splat_bdi;
 		}
+		server->super = s;
 	}
 
 	if (!s->s_root) {
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index fc83d3d..8064980 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -137,6 +137,7 @@ struct nfs_server {
 	__u64			maxfilesize;	/* maximum file size */
 	struct timespec		time_delta;	/* smallest time granularity */
 	unsigned long		mount_time;	/* when this fs was mounted */
+	struct super_block	*super;		/* VFS super block */
 	dev_t			s_dev;		/* superblock dev numbers */
 
 #ifdef CONFIG_NFS_FSCACHE

