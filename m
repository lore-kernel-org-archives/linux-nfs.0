Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f173.google.com ([209.85.161.173]:49901 "EHLO
	mail-gg0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965059Ab3GLQdO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Jul 2013 12:33:14 -0400
Received: by mail-gg0-f173.google.com with SMTP id k3so3194802ggn.18
        for <linux-nfs@vger.kernel.org>; Fri, 12 Jul 2013 09:33:13 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe93:815b])
        by mx.google.com with ESMTPSA id s29sm69031135yhf.6.2013.07.12.09.33.12
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 12 Jul 2013 09:33:13 -0700 (PDT)
Subject: [PATCH v1 12/19] NFS: Add a super_block backpointer to the
 nfs_server struct
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 12 Jul 2013 12:33:12 -0400
Message-ID: <20130712163312.1444.95790.stgit@seurat.1015granger.net>
In-Reply-To: <20130712155303.1444.62697.stgit@seurat.1015granger.net>
References: <20130712155303.1444.62697.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFS_SB() gives the pointer to an nfs_server struct, given a pointer
to a super_block.  But we have no way to go back the other way.

Add a super_block backpointer pointer so that, given an nfs_server
struct, it is easy to get to the root dentry, or access the list of
inodes, associated with an nfs_server.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/super.c            |    1 +
 include/linux/nfs_fs_sb.h |    1 +
 2 files changed, 2 insertions(+)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 2d7525f..455d56a 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2463,6 +2463,7 @@ struct dentry *nfs_fs_mount_common(struct nfs_server *server,
 			mntroot = ERR_PTR(error);
 			goto error_splat_bdi;
 		}
+		server->super = s;
 	}
 
 	if (!s->s_root) {
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index ad47c90..84d8f0c 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -138,6 +138,7 @@ struct nfs_server {
 	__u64			maxfilesize;	/* maximum file size */
 	struct timespec		time_delta;	/* smallest time granularity */
 	unsigned long		mount_time;	/* when this fs was mounted */
+	struct super_block	*super;		/* VFS super block */
 	dev_t			s_dev;		/* superblock dev numbers */
 
 #ifdef CONFIG_NFS_FSCACHE

