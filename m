Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:36668 "EHLO
	mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751257AbbL2AlV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Dec 2015 19:41:21 -0500
Received: by mail-io0-f182.google.com with SMTP id o67so316704092iof.3
        for <linux-nfs@vger.kernel.org>; Mon, 28 Dec 2015 16:41:21 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Donald Buczek <buczek@molgen.mpg.de>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Ensure we revalidate attributes before using execute_ok()
Date: Mon, 28 Dec 2015 19:40:29 -0500
Message-Id: <1451349629-47744-1-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <CAHQdGtTOSw9gDFWo6nwfr=bSo9aXAHVHeRX0XMdeDGkfvzqQjw@mail.gmail.com>
References: <CAHQdGtTOSw9gDFWo6nwfr=bSo9aXAHVHeRX0XMdeDGkfvzqQjw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Donald Buczek reports that NFS clients can also report incorrect
results for access() due to lack of revalidation of attributes
before calling execute_ok().
Looking closely, it seems chdir() is afflicted with the same problem.

Fix is to ensure we call nfs_revalidate_inode_rcu() or
nfs_revalidate_inode() as appropriate before deciding to trust
execute_ok().

Reported-by: Donald Buczek <buczek@molgen.mpg.de>
Link: http://lkml.kernel.org/r/1451331530-3748-1-git-send-email-buczek@molgen.mpg.de
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/dir.c | 18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 44e519c21e18..5bd2f5bfaf57 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2432,6 +2432,20 @@ int nfs_may_open(struct inode *inode, struct rpc_cred *cred, int openflags)
 }
 EXPORT_SYMBOL_GPL(nfs_may_open);
 
+static int nfs_execute_ok(struct inode *inode, int mask)
+{
+	struct nfs_server *server = NFS_SERVER(inode);
+	int ret;
+
+	if (mask & MAY_NOT_BLOCK)
+		ret = nfs_revalidate_inode_rcu(server, inode);
+	else
+		ret = nfs_revalidate_inode(server, inode);
+	if (ret == 0 && !execute_ok(inode))
+		ret = -EACCES;
+	return ret;
+}
+
 int nfs_permission(struct inode *inode, int mask)
 {
 	struct rpc_cred *cred;
@@ -2484,8 +2498,8 @@ force_lookup:
 			res = PTR_ERR(cred);
 	}
 out:
-	if (!res && (mask & MAY_EXEC) && !execute_ok(inode))
-		res = -EACCES;
+	if (!res && (mask & MAY_EXEC))
+		res = nfs_execute_ok(inode, mask);
 
 	dfprintk(VFS, "NFS: permission(%s/%lu), mask=0x%x, res=%d\n",
 		inode->i_sb->s_id, inode->i_ino, mask, res);
-- 
2.5.0

