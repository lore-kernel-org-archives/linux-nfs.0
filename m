Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ey0-f174.google.com ([209.85.215.174]:37240 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752668Ab1LLXGk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Dec 2011 18:06:40 -0500
Message-ID: <4EE688FC.8090606@gmail.com>
Date: Tue, 13 Dec 2011 00:06:36 +0100
From: roel <roel.kluin@gmail.com>
MIME-Version: 1.0
To: Andrew Morton <akpm@linux-foundation.org>,
        LKML <linux-kernel@vger.kernel.org>, sage@newdream.net,
        Steve French <sfrench@samba.org>, linux-cifs@vger.kernel.org,
        Miklos Szeredi <miklos@szeredi.hu>, fuse-devel@lists.sourceforge.net,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: ceph, cifs, nfs, fuse: boolean and / or confusion
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The test not SEEK_CUR or not SEEK_SET always evaluates to true

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
 fs/ceph/file.c   |    2 +-
 fs/cifs/cifsfs.c |    2 +-
 fs/fuse/file.c   |    2 +-
 fs/nfs/file.c    |    2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/ceph/file.c b/fs/ceph/file.c
index ce549d3..4d61a66 100644
--- a/fs/ceph/file.c
+++ b/fs/ceph/file.c
@@ -797,7 +797,7 @@ static loff_t ceph_llseek(struct file *file, loff_t offset, int origin)
 
 	mutex_lock(&inode->i_mutex);
 	__ceph_do_pending_vmtruncate(inode);
-	if (origin != SEEK_CUR || origin != SEEK_SET) {
+	if (origin != SEEK_CUR && origin != SEEK_SET) {
 		ret = ceph_do_getattr(inode, CEPH_STAT_CAP_SIZE);
 		if (ret < 0) {
 			offset = ret;
diff --git a/fs/cifs/cifsfs.c b/fs/cifs/cifsfs.c
index 8f1fe32..f8351c2 100644
--- a/fs/cifs/cifsfs.c
+++ b/fs/cifs/cifsfs.c
@@ -703,7 +703,7 @@ static loff_t cifs_llseek(struct file *file, loff_t offset, int origin)
 	 * origin == SEEK_END || SEEK_DATA || SEEK_HOLE => we must revalidate
 	 * the cached file length
 	 */
-	if (origin != SEEK_SET || origin != SEEK_CUR) {
+	if (origin != SEEK_SET && origin != SEEK_CUR) {
 		int rc;
 		struct inode *inode = file->f_path.dentry->d_inode;
 
diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index 594f07a..19029e9 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -1556,7 +1556,7 @@ static loff_t fuse_file_llseek(struct file *file, loff_t offset, int origin)
 	struct inode *inode = file->f_path.dentry->d_inode;
 
 	mutex_lock(&inode->i_mutex);
-	if (origin != SEEK_CUR || origin != SEEK_SET) {
+	if (origin != SEEK_CUR && origin != SEEK_SET) {
 		retval = fuse_update_attributes(inode, NULL, file, NULL);
 		if (retval)
 			goto exit;
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index eca56d4..606ef0f 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -147,7 +147,7 @@ static loff_t nfs_file_llseek(struct file *filp, loff_t offset, int origin)
 	 * origin == SEEK_END || SEEK_DATA || SEEK_HOLE => we must revalidate
 	 * the cached file length
 	 */
-	if (origin != SEEK_SET || origin != SEEK_CUR) {
+	if (origin != SEEK_SET && origin != SEEK_CUR) {
 		struct inode *inode = filp->f_mapping->host;
 
 		int retval = nfs_revalidate_file_size(inode, filp);
