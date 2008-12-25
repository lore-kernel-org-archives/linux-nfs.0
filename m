From: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
Subject: [Patch] fs/nfs/nfs4proc.c: make nfs4_map_errors() static
Date: Thu, 25 Dec 2008 21:55:23 +0000
Message-ID: <20081225215523.GH3130@hack.private>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, Andrew Morton <akpm@osdl.org>,
	bfields@fieldses.org
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752094AbYLYN47@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


nfs4_map_errors() can become static.

Signed-off-by: WANG Cong <wangcong@zeuux.org>
Cc: J. Bruce Fields <bfields@fieldses.org>

---
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index ea79064..b8fb6a6 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -174,7 +174,6 @@ extern ssize_t nfs4_listxattr(struct dentry *, char *, size_t);
 
 
 /* nfs4proc.c */
-extern int nfs4_map_errors(int err);
 extern int nfs4_proc_setclientid(struct nfs_client *, u32, unsigned short, struct rpc_cred *);
 extern int nfs4_proc_setclientid_confirm(struct nfs_client *, struct rpc_cred *);
 extern int nfs4_proc_async_renew(struct nfs_client *, struct rpc_cred *);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 83e700a..91e46ec 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -69,7 +69,7 @@ static int _nfs4_proc_lookup(struct inode *dir, const struct qstr *name, struct
 static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fattr *fattr);
 
 /* Prevent leaks of NFSv4 errors into userland */
-int nfs4_map_errors(int err)
+static int nfs4_map_errors(int err)
 {
 	if (err < -1000) {
 		dprintk("%s could not handle NFSv4 error %d\n",
