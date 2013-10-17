Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:22908 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758797Ab3JQSM5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Oct 2013 14:12:57 -0400
Received: from ucsinet22.oracle.com (ucsinet22.oracle.com [156.151.31.94])
	by userp1040.oracle.com (Sentrion-MTA-4.3.1/Sentrion-MTA-4.3.1) with ESMTP id r9HICuKx012962
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 17 Oct 2013 18:12:57 GMT
Received: from nfsvm18.us.oracle.com (nfsvm18.us.oracle.com [10.135.198.118])
	by ucsinet22.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id r9HICup5026423
	for <linux-nfs@vger.kernel.org>; Thu, 17 Oct 2013 18:12:56 GMT
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 08/21] NFS: Add a super_block backpointer to the nfs_server struct
Date: Thu, 17 Oct 2013 14:12:56 -0400
Message-Id: <20131017181256.1073.81562.stgit@nfsvm18.us.oracle.com>
In-Reply-To: <20131017180630.1073.18400.stgit@nfsvm18.us.oracle.com>
References: <20131017180630.1073.18400.stgit@nfsvm18.us.oracle.com>
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
index a03b9c6..5edc613 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2530,6 +2530,7 @@ struct dentry *nfs_fs_mount_common(struct nfs_server *server,
 			mntroot = ERR_PTR(error);
 			goto error_splat_bdi;
 		}
+		server->super = s;
 	}
 
 	if (!s->s_root) {
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index b8cedce..a1c80a2 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -147,6 +147,7 @@ struct nfs_server {
 	__u64			maxfilesize;	/* maximum file size */
 	struct timespec		time_delta;	/* smallest time granularity */
 	unsigned long		mount_time;	/* when this fs was mounted */
+	struct super_block	*super;		/* VFS super block */
 	dev_t			s_dev;		/* superblock dev numbers */
 
 #ifdef CONFIG_NFS_FSCACHE

