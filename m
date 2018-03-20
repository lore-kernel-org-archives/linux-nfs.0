Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:35304 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751514AbeCTUnw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Mar 2018 16:43:52 -0400
Received: by mail-it0-f68.google.com with SMTP id v194-v6so4116641itb.0
        for <linux-nfs@vger.kernel.org>; Tue, 20 Mar 2018 13:43:52 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 8/8] NFSv4: Don't return the delegation when not needed by NFSv4.x (x>0)
Date: Tue, 20 Mar 2018 16:43:20 -0400
Message-Id: <20180320204320.93656-9-trond.myklebust@primarydata.com>
In-Reply-To: <20180320204320.93656-8-trond.myklebust@primarydata.com>
References: <20180320204320.93656-1-trond.myklebust@primarydata.com>
 <20180320204320.93656-2-trond.myklebust@primarydata.com>
 <20180320204320.93656-3-trond.myklebust@primarydata.com>
 <20180320204320.93656-4-trond.myklebust@primarydata.com>
 <20180320204320.93656-5-trond.myklebust@primarydata.com>
 <20180320204320.93656-6-trond.myklebust@primarydata.com>
 <20180320204320.93656-7-trond.myklebust@primarydata.com>
 <20180320204320.93656-8-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Starting with NFSv4.1, the server is able to deduce the client id from
the SEQUENCE op which means it can always figure out whether or not
the client is holding a delegation on a file that is being changed.
For that reason, RFC5661 does not require a delegation to be unconditionally
recalled on operations such as SETATTR, RENAME, or REMOVE.

Note that for now, we continue to return READ delegations since that is
still expected by the Linux knfsd server.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/delegation.c | 17 +++++++++++++++++
 fs/nfs/delegation.h |  1 +
 fs/nfs/nfs4proc.c   | 16 ++++++++++------
 3 files changed, 28 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index d8b47624fee2..a5cb44375100 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -19,6 +19,7 @@
 #include <linux/nfs_xdr.h>
 
 #include "nfs4_fs.h"
+#include "nfs4session.h"
 #include "delegation.h"
 #include "internal.h"
 #include "nfs4trace.h"
@@ -547,6 +548,22 @@ int nfs4_inode_return_delegation(struct inode *inode)
 	return err;
 }
 
+/**
+ * nfs4_inode_make_writeable
+ * @inode: pointer to inode
+ *
+ * Make the inode writeable by returning the delegation if necessary
+ *
+ * Returns zero on success, or a negative errno value.
+ */
+int nfs4_inode_make_writeable(struct inode *inode)
+{
+	if (!nfs4_has_session(NFS_SERVER(inode)->nfs_client) ||
+	    !nfs4_check_delegation(inode, FMODE_WRITE))
+		return nfs4_inode_return_delegation(inode);
+	return 0;
+}
+
 static void nfs_mark_return_if_closed_delegation(struct nfs_server *server,
 		struct nfs_delegation *delegation)
 {
diff --git a/fs/nfs/delegation.h b/fs/nfs/delegation.h
index 185a09f37a89..dcc8a783a6e1 100644
--- a/fs/nfs/delegation.h
+++ b/fs/nfs/delegation.h
@@ -70,6 +70,7 @@ int nfs4_check_delegation(struct inode *inode, fmode_t flags);
 bool nfs4_delegation_flush_on_close(const struct inode *inode);
 void nfs_inode_find_delegation_state_and_recover(struct inode *inode,
 		const nfs4_stateid *stateid);
+int nfs4_inode_make_writeable(struct inode *inode);
 
 #endif
 
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ef57a0eb5647..b4ebee12fe28 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3877,7 +3877,7 @@ nfs4_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 
 	/* Return any delegations if we're going to change ACLs */
 	if ((sattr->ia_valid & (ATTR_MODE|ATTR_UID|ATTR_GID)) != 0)
-		nfs4_inode_return_delegation(inode);
+		nfs4_inode_make_writeable(inode);
 
 	status = nfs4_do_setattr(inode, cred, fattr, sattr, ctx, NULL, label);
 	if (status == 0) {
@@ -4210,8 +4210,12 @@ static int nfs4_proc_remove(struct inode *dir, struct dentry *dentry)
 	struct inode *inode = d_inode(dentry);
 	int err;
 
-	if (inode)
-		nfs4_inode_return_delegation(inode);
+	if (inode) {
+		if (inode->i_nlink == 1)
+			nfs4_inode_return_delegation(inode);
+		else
+			nfs4_inode_make_writeable(inode);
+	}
 	do {
 		err = _nfs4_proc_remove(dir, &dentry->d_name);
 		trace_nfs4_remove(dir, &dentry->d_name, err);
@@ -4284,7 +4288,7 @@ static void nfs4_proc_rename_setup(struct rpc_message *msg,
 	struct inode *new_inode = d_inode(new_dentry);
 
 	if (old_inode)
-		nfs4_inode_return_delegation(old_inode);
+		nfs4_inode_make_writeable(old_inode);
 	if (new_inode)
 		nfs4_inode_return_delegation(new_inode);
 	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_RENAME];
@@ -4350,7 +4354,7 @@ static int _nfs4_proc_link(struct inode *inode, struct inode *dir, const struct
 	}
 	arg.bitmask = nfs4_bitmask(server, res.label);
 
-	nfs4_inode_return_delegation(inode);
+	nfs4_inode_make_writeable(inode);
 
 	status = nfs4_call_sync(server->client, server, &msg, &arg.seq_args, &res.seq_res, 1);
 	if (!status) {
@@ -5345,7 +5349,7 @@ static int __nfs4_proc_set_acl(struct inode *inode, const void *buf, size_t bufl
 	i = buf_to_pages_noslab(buf, buflen, arg.acl_pages);
 	if (i < 0)
 		return i;
-	nfs4_inode_return_delegation(inode);
+	nfs4_inode_make_writeable(inode);
 	ret = nfs4_call_sync(server->client, server, &msg, &arg.seq_args, &res.seq_res, 1);
 
 	/*
-- 
2.14.3

