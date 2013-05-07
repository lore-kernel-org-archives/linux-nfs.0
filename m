From: Jiri Slaby <jslaby@suse.cz>
Subject: [PATCH 09/15] Make selection of 'readdir-plus' adapt to usage patterns.
Date: Tue,  7 May 2013 16:18:17 +0200
Message-ID: <1367936303-13386-9-git-send-email-jslaby@suse.cz>
References: <1367936303-13386-1-git-send-email-jslaby@suse.cz>
Cc: linux-kernel@vger.kernel.org, NeilBrown <neilb@suse.de>,
	Jiri Slaby <jslaby@suse.cz>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-nfs@vger.kernel.org
To: jirislaby@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1367936303-13386-1-git-send-email-jslaby@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: NeilBrown <neilb@suse.de>

While the use of READDIRPLUS is significantly more efficient than
READDIR followed by many GETATTR calls, it is still less efficient
than just READDIR if the attributes are not required.

We can get a hint as to whether the application requires attr information
by looking at whether any ->getattr calls are made between
->readdir calls.
If there are any, then getting the attributes seems to be worth while.

This patch tracks whether there have been recent getattr calls on
children of a directory and uses that information to selectively
disable READDIRPLUS on that directory.

The first 'readdir' call is always served using READDIRPLUS.
Subsequent calls only use READDIRPLUS if there was a getattr on a child
in the mean time.

The locking of ->d_parent access needs to be reviewed.
As the bit is simply a hint, it isn't critical that it is set
on the "correct" parent if a rename is happening, but it is
critical that the 'set' doesn't set a bit in something that
isn't even an inode any more.

Acked-by: NeilBrown <neilb@suse.de>
Signed-off-by: Neil Brown <neilb@suse.de>
Signed-off-by: Jiri Slaby <jslaby@suse.cz>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
---
 fs/nfs/dir.c           | 3 +++
 fs/nfs/inode.c         | 9 +++++++++
 include/linux/nfs_fs.h | 4 ++++
 3 files changed, 16 insertions(+)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index e093e73..f5b367c 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -826,6 +826,9 @@ static int nfs_readdir(struct file *filp, void *dirent, filldir_t filldir)
 	desc->dir_cookie = &dir_ctx->dir_cookie;
 	desc->decode = NFS_PROTO(inode)->decode_dirent;
 	desc->plus = nfs_use_readdirplus(inode, filp) ? 1 : 0;
+	if (filp->f_pos > 0 && !test_bit(NFS_INO_SEEN_GETATTR, &NFS_I(inode)->flags))
+		desc->plus = 0;
+	clear_bit(NFS_INO_SEEN_GETATTR, &NFS_I(inode)->flags);
 
 	nfs_block_sillyrename(dentry);
 	res = nfs_revalidate_mapping(inode, filp->f_mapping);
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index c1c7a9d..c15071d 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -520,6 +520,15 @@ int nfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
 	struct inode *inode = dentry->d_inode;
 	int need_atime = NFS_I(inode)->cache_validity & NFS_INO_INVALID_ATIME;
 	int err;
+	struct dentry *p;
+	struct inode *pi;
+
+	rcu_read_lock();
+	p = dentry->d_parent;
+	pi = rcu_dereference(p)->d_inode;
+	if (pi && !test_bit(NFS_INO_SEEN_GETATTR, &NFS_I(pi)->flags))
+		set_bit(NFS_INO_SEEN_GETATTR, &NFS_I(pi)->flags);
+	rcu_read_unlock();
 
 	/* Flush out writes to the server in order to update c/mtime.  */
 	if (S_ISREG(inode->i_mode)) {
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index fc01d5c..633e2a9 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -220,6 +220,10 @@ struct nfs_inode {
 #define NFS_INO_COMMIT		(7)		/* inode is committing unstable writes */
 #define NFS_INO_LAYOUTCOMMIT	(9)		/* layoutcommit required */
 #define NFS_INO_LAYOUTCOMMITTING (10)		/* layoutcommit inflight */
+#define NFS_INO_SEEN_GETATTR	(11)		/* flag to track if app is calling
+						 * getattr in a directory during
+						 * readdir
+						 */
 
 static inline struct nfs_inode *NFS_I(const struct inode *inode)
 {
-- 
1.8.2.1
