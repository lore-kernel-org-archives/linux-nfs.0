Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e34.co.us.ibm.com ([32.97.110.152]:54640 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754049Ab1KKXGS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Nov 2011 18:06:18 -0500
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <treinish@linux.vnet.ibm.com>;
	Fri, 11 Nov 2011 16:06:17 -0700
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pABN5pG7039162
	for <linux-nfs@vger.kernel.org>; Fri, 11 Nov 2011 16:05:54 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pABN5pkk012933
	for <linux-nfs@vger.kernel.org>; Fri, 11 Nov 2011 16:05:51 -0700
From: Matthew Treinish <treinish@linux.vnet.ibm.com>
To: linux-nfs@vger.kernel.org
Cc: treinish@linux.vnet.ibm.com
Subject: [PATCH/RFC 5/7] Added VFH FHEXPIRED recovery functions.
Date: Fri, 11 Nov 2011 18:04:30 -0500
Message-Id: <1321052673-22171-6-git-send-email-treinish@linux.vnet.ibm.com>
In-Reply-To: <1321052673-22171-1-git-send-email-treinish@linux.vnet.ibm.com>
References: <1321052673-22171-1-git-send-email-treinish@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The VFH recovery functions perform a recursive walk back on FHEXPIRED
errors. If an FHEXPIRED error is received during a recovery lookup
This means that the directory's filehandle is also expired and
needs to be recovered.

The end case for the recursion is if the filehandle is the rootfh.
This means that we recursed back to the root of the export, and we
can just perform a rootfh lookup.

Also added a modified lookup for volatile file handle recovery. This
function will not use the exception handling on FHEXPIRED errors
and just return FHEXPIRED instead.

Signed-off-by: Matthew Treinish <treinish@linux.vnet.ibm.com>
---
 fs/nfs/nfs4proc.c |   94 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 94 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 20b96cb..50bb823 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -74,6 +74,7 @@ static int _nfs4_recover_proc_open(struct nfs4_opendata *data);
 static int nfs4_do_fsinfo(struct nfs_server *, struct nfs_fh *, struct nfs_fsinfo *);
 static int nfs4_async_handle_error(struct rpc_task *, const struct nfs_server *, struct nfs4_state *);
 static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fattr *fattr);
+static int nfs4_fhexpired_recovery(struct nfs_server *server, struct nfs4_exception *exception);
 static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 			    struct nfs_fattr *fattr, struct iattr *sattr,
 			    struct nfs4_state *state);
@@ -2494,6 +2495,99 @@ static int nfs4_proc_lookup(struct rpc_clnt *clnt, struct inode *dir, struct qst
 	return err;
 }
 
+static int nfs4_proc_vfh_lookup(struct rpc_clnt *clnt, struct inode *dir,
+	struct qstr *name, struct nfs_fh *fhandle, struct nfs_fattr *fattr)
+{
+	struct nfs4_exception exception = { };
+	int err;
+	do {
+		int status;
+
+		status = _nfs4_proc_lookup(clnt, dir, name, fhandle, fattr);
+		switch (status) {
+		case -NFS4ERR_BADNAME:
+			return -ENOENT;
+		case -NFS4ERR_MOVED:
+			err = nfs4_get_referral(dir, name, fattr, fhandle);
+			break;
+		case -NFS4ERR_FHEXPIRED:
+			return -NFS4ERR_FHEXPIRED;
+		case -NFS4ERR_WRONGSEC:
+			nfs_fixup_secinfo_attributes(fattr, fhandle);
+		}
+		err = nfs4_handle_exception(NFS_SERVER(dir),
+					status, &exception);
+	} while (exception.retry);
+	return err;
+}
+
+static int _nfs4_fhexpired_recovery(struct nfs_server *server, struct dentry *d_parent, struct qstr *name, struct inode *inode)
+{
+	int err;
+	struct nfs_fh *fhandle = NFS_FH(inode);
+	struct nfs_fattr *fattr = nfs_alloc_fattr();
+	if (fattr == NULL)
+		return -ENOMEM;
+	fattr->fileid = 0;
+	if (!nfs_compare_fh(fhandle, server->rootfh)) {
+		struct nfs_fsinfo info = {
+			.fattr = fattr,
+		};
+		err = nfs4_proc_get_root(server, fhandle, &info);
+		if (!err) {
+			if (NFS_FILEID(inode) != info.fattr->fileid)
+				set_nfs_fileid(inode, info.fattr->fileid);
+			nfs_copy_fh(server->rootfh, fhandle);
+			/* Only needed if fsid changes on server */
+			memcpy(&server->fsid, &info.fattr->fsid,
+				sizeof(server->fsid));
+		}
+		nfs_free_fattr(fattr);
+		return err;
+	}
+	err = nfs4_proc_vfh_lookup(server->client, d_parent->d_inode, name,
+			fhandle, fattr);
+	if (!fattr->fileid && !err && fattr->fileid != NFS_FILEID(inode))
+		set_nfs_fileid(inode, fattr->fileid);
+	if (err == -NFS4ERR_FHEXPIRED) {
+		err = _nfs4_fhexpired_recovery(server, d_parent->d_parent,
+				&d_parent->d_name, d_parent->d_inode);
+		if (!err) {
+			err = nfs4_proc_vfh_lookup(server->client,
+					d_parent->d_inode, name,
+					fhandle, fattr);
+			if (!fattr->fileid && !err &&
+					fattr->fileid != NFS_FILEID(inode))
+				set_nfs_fileid(inode, fattr->fileid);
+		}
+	}
+	nfs_free_fattr(fattr);
+	return err;
+}
+
+static int nfs4_fhexpired_recovery(struct nfs_server *server, struct nfs4_exception *exception)
+{
+	int err;
+	struct dentry *dentry;
+	if (exception->dentry) {
+		dentry = exception->dentry;
+		err = _nfs4_fhexpired_recovery(server, dentry->d_parent,
+				&dentry->d_name, dentry->d_inode);
+	} else if (exception->inode) {
+		dentry = d_obtain_alias(exception->inode);
+		err = _nfs4_fhexpired_recovery(server, dentry->d_parent,
+				&dentry->d_name, exception->inode);
+		dput(dentry);
+	}
+	BUG_ON(!exception->inode && !exception->dentry); /*Recovery without
+							  VFS objects, missed
+							  a proc function*/
+	if (!err)
+		return -EAGAIN; /* Return EAGAIN so that the operation will
+				   be performed again on successful recovery */
+	return err;
+}
+
 static int _nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
-- 
1.7.4.4

