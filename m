Return-Path: <bfields@fieldses.org>
Date: Thu, 23 Jul 2015 11:08:43 -0400
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>
Cc: linux-nfs@vger.kernel.org, Benjamin Coddington <bcodding@redhat.com>
Subject: [PATCH] NFSv4.2: handle NFS-specific llseek errors
Message-ID: <20150723150843.GA12894@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Handle NFS-specific llseek errors instead of letting them leak out to
userspace.

Reported-by: Benjamin Coddington <bcodding@redhat.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfs/nfs42proc.c | 19 ++++++++++++++++++-
 1 file changed, 18 insertions(+), 1 deletion(-)

I don't actually have a test case for this, but it looks right....

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index f486b80f927a..2fec410bc50f 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -135,7 +135,7 @@ int nfs42_proc_deallocate(struct file *filep, loff_t offset, loff_t len)
 	return err;
 }
 
-loff_t nfs42_proc_llseek(struct file *filep, loff_t offset, int whence)
+loff_t _nfs42_proc_llseek(struct file *filep, loff_t offset, int whence)
 {
 	struct inode *inode = file_inode(filep);
 	struct nfs42_seek_args args = {
@@ -171,6 +171,23 @@ loff_t nfs42_proc_llseek(struct file *filep, loff_t offset, int whence)
 	return vfs_setpos(filep, res.sr_offset, inode->i_sb->s_maxbytes);
 }
 
+loff_t nfs42_proc_llseek(struct file *filep, loff_t offset, int whence)
+{
+	struct nfs_server *server = NFS_SERVER(file_inode(filep));
+	struct nfs4_exception exception = { };
+	int err;
+
+	do {
+		err = _nfs42_proc_llseek(filep, offset, whence);
+		if (err == -ENOTSUPP)
+			return -EOPNOTSUPP;
+		err = nfs4_handle_exception(server, err, &exception);
+	} while (exception.retry);
+
+	return err;
+}
+
+
 static void
 nfs42_layoutstat_prepare(struct rpc_task *task, void *calldata)
 {
-- 
2.4.3
