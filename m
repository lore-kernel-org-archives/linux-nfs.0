From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/7] NFS: Make nfs_llseek methods consistent
Date: Wed, 11 Jun 2008 17:55:34 -0400
Message-ID: <20080611215534.7068.83144.stgit@ellison.1015granger.net>
References: <20080611215018.7068.71737.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:37008 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751927AbYFKWIE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Jun 2008 18:08:04 -0400
In-Reply-To: <20080611215018.7068.71737.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Report the same debugging info in nfs_llseek_dir() and
nfs_llseek_file().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/dir.c  |   12 ++++++++++--
 fs/nfs/file.c |    5 +++++
 2 files changed, 15 insertions(+), 2 deletions(-)


diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 1bc8bc6..9f31cc6 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -603,7 +603,15 @@ out:
 
 static loff_t nfs_llseek_dir(struct file *filp, loff_t offset, int origin)
 {
-	mutex_lock(&filp->f_path.dentry->d_inode->i_mutex);
+	struct dentry *dentry = filp->f_path.dentry;
+	struct inode *inode = dentry->d_inode;
+
+	dfprintk(VFS, "NFS: llseek dir(%s/%s, %lld, %d)\n",
+			dentry->d_parent->d_name.name,
+			dentry->d_name.name,
+			offset, origin);
+
+	mutex_lock(&inode->i_mutex);
 	switch (origin) {
 		case 1:
 			offset += filp->f_pos;
@@ -619,7 +627,7 @@ static loff_t nfs_llseek_dir(struct file *filp, loff_t offset, int origin)
 		nfs_file_open_context(filp)->dir_cookie = 0;
 	}
 out:
-	mutex_unlock(&filp->f_path.dentry->d_inode->i_mutex);
+	mutex_unlock(&inode->i_mutex);
 	return offset;
 }
 
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index e452903..bb09c48 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -170,6 +170,11 @@ force_reval:
 
 static loff_t nfs_file_llseek(struct file *filp, loff_t offset, int origin)
 {
+	dfprintk(VFS, "NFS: llseek file(%s/%s, %lld, %d)\n",
+			filp->f_path.dentry->d_parent->d_name.name,
+			filp->f_path.dentry->d_name.name,
+			offset, origin);
+
 	/* origin == SEEK_END => we must revalidate the cached file length */
 	if (origin == SEEK_END) {
 		struct inode *inode = filp->f_mapping->host;

