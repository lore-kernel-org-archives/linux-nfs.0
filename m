From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/5] NFS: Make nfs_llseek methods consistent
Date: Fri, 21 Mar 2008 19:02:16 -0400
Message-ID: <20080321230216.23627.70101.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]:12345 "EHLO
	flpi185.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762499AbYCUXCd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Mar 2008 19:02:33 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Report the same debugging info in nfs_llseek_dir() and
nfs_llseek_file().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/dir.c  |   12 ++++++++++--
 fs/nfs/file.c |    7 +++++++
 2 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 534a811..63f8f1c 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -603,7 +603,15 @@ out:
 
 static loff_t nfs_llseek_dir(struct file *filp, loff_t offset, int origin)
 {
-	mutex_lock(&filp->f_path.dentry->d_inode->i_mutex);
+	struct dentry *dentry = filp->f_path.dentry;
+	struct inode *inode = filp->f_path.dentry->d_inode;
+
+	dfprintk(VFS, "NFS: llseek dir(%s/%s, %Ld, %d)\n",
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
index 38424eb..7776a89 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -166,6 +166,13 @@ force_reval:
 
 static loff_t nfs_file_llseek(struct file *filp, loff_t offset, int origin)
 {
+	struct dentry *dentry = filp->f_path.dentry;
+
+	dfprintk(VFS, "NFS: llseek file(%s/%s, %Ld, %d)\n",
+			dentry->d_parent->d_name.name,
+			dentry->d_name.name,
+			offset, origin);
+
 	/* origin == SEEK_END => we must revalidate the cached file length */
 	if (origin == SEEK_END) {
 		struct inode *inode = filp->f_mapping->host;

