Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from shutemov.name ([188.40.19.243]:38474 "EHLO shutemov.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757366Ab0LTLyn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Dec 2010 06:54:43 -0500
From: "Kirill A. Shutsemov" <kirill@shutemov.name>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>
Cc: Pavel Emelyanov <xemul@parallels.com>, linux-nfs@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: [PATCH 10/12] sunrpc: introduce get_rpc_pipefs()
Date: Mon, 20 Dec 2010 13:54:36 +0200
Message-Id: <1292846078-31793-11-git-send-email-kirill@shutemov.name>
In-Reply-To: <1292846078-31793-1-git-send-email-kirill@shutemov.name>
References: <1292846078-31793-1-git-send-email-kirill@shutemov.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Kirill A. Shutemov <kirill@shutemov.name>

Get rpc_pipefs mount point by path.

Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
---
 include/linux/sunrpc/rpc_pipe_fs.h |    2 ++
 net/sunrpc/rpc_pipe.c              |   24 ++++++++++++++++++++++++
 2 files changed, 26 insertions(+), 0 deletions(-)

diff --git a/include/linux/sunrpc/rpc_pipe_fs.h b/include/linux/sunrpc/rpc_pipe_fs.h
index b09bfa5..922057c 100644
--- a/include/linux/sunrpc/rpc_pipe_fs.h
+++ b/include/linux/sunrpc/rpc_pipe_fs.h
@@ -46,6 +46,8 @@ RPC_I(struct inode *inode)
 
 extern struct vfsmount *init_rpc_pipefs;
 
+struct vfsmount *get_rpc_pipefs(const char *path);
+
 extern int rpc_queue_upcall(struct inode *, struct rpc_pipe_msg *);
 
 struct rpc_clnt;
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index b1e299b..c48f7a5 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -931,6 +931,30 @@ static const struct super_operations s_ops = {
 
 #define RPCAUTH_GSSMAGIC 0x67596969
 
+struct vfsmount *get_rpc_pipefs(const char *p)
+{
+	int error;
+	struct vfsmount *rpcmount;
+	struct path path;
+
+	if (!p)
+		return mntget(init_rpc_pipefs);
+
+	error = kern_path(p, LOOKUP_FOLLOW | LOOKUP_DIRECTORY, &path);
+	if (error)
+		return ERR_PTR(error);
+
+	if (path.mnt->mnt_sb->s_magic != RPCAUTH_GSSMAGIC) {
+		path_put(&path);
+		return ERR_PTR(-EINVAL);
+	}
+
+	rpcmount = mntget(path.mnt);
+	path_put(&path);
+
+	return rpcmount;
+}
+
 /*
  * We have a single directory with 1 node in it.
  */
-- 
1.7.3.4

