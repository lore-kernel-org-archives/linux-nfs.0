Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e34.co.us.ibm.com ([32.97.110.152]:45027 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932332Ab2CEU2Q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Mar 2012 15:28:16 -0500
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <treinish@linux.vnet.ibm.com>;
	Mon, 5 Mar 2012 13:28:12 -0700
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 1F1DFC9005E
	for <linux-nfs@vger.kernel.org>; Mon,  5 Mar 2012 15:27:36 -0500 (EST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q25KR0rL249672
	for <linux-nfs@vger.kernel.org>; Mon, 5 Mar 2012 15:27:04 -0500
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q25KRBXL027708
	for <linux-nfs@vger.kernel.org>; Mon, 5 Mar 2012 13:27:11 -0700
From: Matthew Treinish <treinish@linux.vnet.ibm.com>
To: linux-nfs@vger.kernel.org
Cc: treinish@linux.vnet.ibm.com
Subject: [PATCH/RFC v3 06/10] Add VFH FHEXPIRED recovery functions.
Date: Mon,  5 Mar 2012 15:26:47 -0500
Message-Id: <1330979211-894-7-git-send-email-treinish@linux.vnet.ibm.com>
In-Reply-To: <1330979211-894-1-git-send-email-treinish@linux.vnet.ibm.com>
References: <1330979211-894-1-git-send-email-treinish@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The VFH recovery functions perform a recursive walk back on FHEXPIRED
errors. If an FHEXPIRED error is received during a recovery lookup
This means that the directory's filehandle is also expired and
needs to be recovered.

The end case for the recursion is if the file handle is the rootfh.
This means that we recursed back to the root of the export, and we
can just perform a rootfh lookup.

Also added a modified lookup for volatile file handle recovery. This
function will not use the exception handling on FHEXPIRED errors
and just return FHEXPIRED instead.

v3:
- Add support for getattr recovery by calling nfs4_vfh_getdentry() when a
file handle is passed in from nfs4_exception.

v2:
- Added credentials to the lookup request on an ACCESS error and
if a credential is passed into recovery.

Signed-off-by: Matthew Treinish <treinish@linux.vnet.ibm.com>
---
 fs/nfs/nfs4proc.c |  143 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 143 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ee62c1e..9edf9ae 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -80,6 +80,7 @@ static int _nfs4_recover_proc_open(struct nfs4_opendata *data);
 static int nfs4_do_fsinfo(struct nfs_server *, struct nfs_fh *, struct nfs_fsinfo *);
 static int nfs4_async_handle_error(struct rpc_task *, const struct nfs_server *, struct nfs4_state *);
 static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fattr *fattr);
+static int nfs4_fhexpired_recovery(struct nfs_server *server, struct nfs4_exception *exception);
 static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 			    struct nfs_fattr *fattr, struct iattr *sattr,
 			    struct nfs4_state *state);
@@ -2649,6 +2650,148 @@ static int _nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry
 	return status;
 }
 
+static int _nfs4_proc_vfh_lookup(struct rpc_clnt *clnt, struct inode *dir,
+		const struct qstr *name, struct nfs_fh *fhandle,
+		struct nfs_fattr *fattr, struct rpc_cred *cred)
+{
+	struct nfs_server *server = NFS_SERVER(dir);
+	int                    status;
+	struct nfs4_lookup_arg args = {
+		.bitmask = server->attr_bitmask,
+		.dir_fh = NFS_FH(dir),
+		.name = name,
+	};
+	struct nfs4_lookup_res res = {
+		.server = server,
+		.fattr = fattr,
+		.fh = fhandle,
+	};
+	struct rpc_message msg = {
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_LOOKUP],
+		.rpc_argp = &args,
+		.rpc_resp = &res,
+		.rpc_cred = cred,
+	};
+
+	nfs_fattr_init(fattr);
+
+	dprintk("NFS call  lookup %s\n", name->name);
+	status = nfs4_call_sync(clnt, server, &msg, &args.seq_args, &res.seq_res, 0);
+	dprintk("NFS reply lookup: %d\n", status);
+	return status;
+}
+
+static int nfs4_proc_vfh_lookup(struct rpc_clnt *clnt, struct inode *dir,
+	struct qstr *name, struct nfs_fh *fhandle, struct nfs_fattr *fattr,
+	struct rpc_cred *cred)
+{
+	struct nfs4_exception exception = { };
+	int err;
+	do {
+		int status;
+		if (cred)
+			status = _nfs4_proc_vfh_lookup(clnt, dir, name,
+					fhandle, fattr, cred);
+		else
+			status = _nfs4_proc_lookup(clnt, dir, name, fhandle,
+						fattr);
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
+static int _nfs4_fhexpired_recovery(struct nfs_server *server, struct dentry *d_parent, struct qstr *name, struct inode *inode, struct rpc_cred *cred)
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
+				fhandle, fattr, cred);
+	if (!fattr->fileid && !err && fattr->fileid != NFS_FILEID(inode))
+		set_nfs_fileid(inode, fattr->fileid);
+	if (err == -NFS4ERR_FHEXPIRED) {
+		err = _nfs4_fhexpired_recovery(server, d_parent->d_parent,
+				&d_parent->d_name, d_parent->d_inode, cred);
+		if (!err) {
+			err = nfs4_proc_vfh_lookup(server->client,
+					d_parent->d_inode, name,
+					fhandle, fattr, cred);
+			if (!fattr->fileid && !err &&
+					fattr->fileid != NFS_FILEID(inode))
+					set_nfs_fileid(inode, fattr->fileid);
+		}
+	}
+	nfs_free_fattr(fattr);
+	return err;
+}
+
+static int nfs4_fhexpired_recovery(struct nfs_server *server, struct nfs4_exception *exception)
+{
+	int err = 0;
+	struct dentry *dentry = NULL;
+	struct rpc_cred *cred = NULL;
+	if (exception->cred)
+		cred = exception->cred;
+	if (exception->dentry) {
+		dentry = exception->dentry;
+		err = _nfs4_fhexpired_recovery(server, dentry->d_parent,
+				&dentry->d_name, dentry->d_inode, cred);
+	} else if (exception->inode) {
+		dentry = d_obtain_alias(exception->inode);
+		err = _nfs4_fhexpired_recovery(server, dentry->d_parent,
+				&dentry->d_name, exception->inode, cred);
+		dput(dentry);
+	} else if (exception->fhandle) {
+		dentry = nfs4_vfh_getdentry(server, exception->fhandle);
+		if (IS_ERR(dentry) || dentry == NULL)
+			return -ESTALE;
+		err = _nfs4_fhexpired_recovery(server, dentry->d_parent,
+			&dentry->d_name, dentry->d_inode, cred);
+		dput(dentry);
+	} else {
+		BUG_ON(!exception->inode && !exception->dentry
+				&& !exception->fhandle);/*Recovery without
+							* VFS objects, missed
+							* a proc function
+							*/
+	}
+	if (!err)
+		return -EAGAIN; /* Return EAGAIN so that the operation will
+				be performed again on successful recovery */
+	return err;
+}
+
 static int nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry)
 {
 	struct nfs4_exception exception = {
-- 
1.7.4.4

