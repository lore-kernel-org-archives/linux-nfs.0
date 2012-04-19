Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:44620 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755506Ab2DSOHz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Apr 2012 10:07:55 -0400
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 6/6] xstat: eCryptFS: Return extended attributes
To: linux-fsdevel@vger.kernel.org
Cc: dhowells@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-ext4@vger.kernel.org,
        wine-devel@winehq.org, kfm-devel@kde.org, nautilus-list@gnome.org,
        linux-api@vger.kernel.org, libc-alpha@sourceware.org
Date: Thu, 19 Apr 2012 15:07:19 +0100
Message-ID: <20120419140719.17272.39008.stgit@warthog.procyon.org.uk>
In-Reply-To: <20120419140558.17272.74360.stgit@warthog.procyon.org.uk>
References: <20120419140558.17272.74360.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Return extended attributes from the eCryptFS filesystem, dredged up from the
lower filesystem.  XSTAT_INFO_ENCRYPTED is set on the files whose cryptography
is handled by eCryptFS.

Possibly eCryptFS should also set FS_COMPR_FL on its compressed files.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/ecryptfs/inode.c |   14 ++++++++++++--
 1 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/fs/ecryptfs/inode.c b/fs/ecryptfs/inode.c
index ab35b11..62865e9 100644
--- a/fs/ecryptfs/inode.c
+++ b/fs/ecryptfs/inode.c
@@ -1060,13 +1060,23 @@ int ecryptfs_getattr(struct vfsmount *mnt, struct dentry *dentry,
 	struct kstat lower_stat;
 	int rc;
 
-	rc = vfs_getattr(ecryptfs_dentry_to_lower_mnt(dentry),
-			 ecryptfs_dentry_to_lower(dentry), &lower_stat);
+	lower_stat.query_flags = stat->query_flags;
+	lower_stat.request_mask = stat->request_mask | XSTAT_BLOCKS;
+	rc = vfs_xgetattr(ecryptfs_dentry_to_lower_mnt(dentry),
+			  ecryptfs_dentry_to_lower(dentry), &lower_stat);
 	if (!rc) {
 		fsstack_copy_attr_all(dentry->d_inode,
 				      ecryptfs_inode_to_lower(dentry->d_inode));
 		generic_fillattr(dentry->d_inode, stat);
 		stat->blocks = lower_stat.blocks;
+		stat->result_mask = lower_stat.result_mask;
+		stat->information = lower_stat.information;
+		stat->information |= XSTAT_INFO_ENCRYPTED;
+		stat->gen = lower_stat.gen;
+		stat->version = lower_stat.version;
+		stat->ioc_flags = lower_stat.ioc_flags;
+		memcpy(&stat->volume_id, lower_stat.volume_id,
+		       sizeof(stat->volume_id));
 	}
 	return rc;
 }

