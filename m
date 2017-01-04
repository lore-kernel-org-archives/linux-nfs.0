Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:53836 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1761125AbdADQ4i (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 4 Jan 2017 11:56:38 -0500
Date: Wed, 4 Jan 2017 11:56:36 -0500
To: linux-nfs@vger.kernel.org
Cc: tibbs@math.uh.edu
Subject: RFC: make labeled NFS opt-in
Message-ID: <20170104165636.GA17649@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is something I should have noticed before merging labeled NFS:
labeled NFS shouldn't be on by default, among other reasons because it
assumes everybody's using consistent security policies.  As 4.2 is
getting turned on by default, this is starting to generate bug reports.

The patch below turns it off by default, and provides a new option to
turn it on per export.  The drawback is a regression on kernel upgrade
for anyone depending on labeled NFS, until they find the new option.  My
impression is that's a specialized use case that still has a small
number of users at this point, so I think we can get away with that.

The below is untested.  I have a (small) nfs-utils patch as well.

--b.

commit ea84969006fa
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Tue Jan 3 12:30:11 2017 -0500

    nfsd: opt in to labeled nfs per export
    
    Currently turning on NFSv4.2 results in 4.2 clients suddenly seeing the
    individual file labels as they're set on the server.  This is not what
    they've previously seen, and not appropriate in may cases.  (In
    particular, if clients have heterogenous security policies then one
    client's labels may not even make sense to another.)  Labeled NFS should
    be opted in only in those cases when the administrator knows it makes
    sense.
    
    It's helpful to be able to turn 4.2 on by default, and otherwise the
    protocol upgrade seems free of regressions.  So, default labeled NFS to
    off and provide an export flag to reenable it.
    
    Users wanting labeled NFS support on an export will henceforth need to:
    
            - make sure 4.2 support is enabled on client and server (as
              before), and
            - upgrade the server nfs-utils to a version supporting the new
              "security_label" export flag.
            - set that "security_label" flag on the export.
    
    This is commit may be seen as a regression to anyone currently depending
    on security labels.  We believe those cases are currently rare.
    
    Reported-by: tibbs@math.uh.edu
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 43e109cc0ccc..03600b2ea345 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -1102,6 +1102,7 @@ static struct flags {
 	{ NFSEXP_NOAUTHNLM, {"insecure_locks", ""}},
 	{ NFSEXP_V4ROOT, {"v4root", ""}},
 	{ NFSEXP_PNFS, {"pnfs", ""}},
+	{ NFSEXP_SECURITY_LABEL, {"security_label"}},
 	{ 0, {"", ""}}
 };
 
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 74a6e573e061..6f0b89d1c09b 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -95,11 +95,15 @@ check_attr_support(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		   u32 *bmval, u32 *writable)
 {
 	struct dentry *dentry = cstate->current_fh.fh_dentry;
+	struct svc_export *exp = cstate->current_fh.fh_export;
 
 	if (!nfsd_attrs_supported(cstate->minorversion, bmval))
 		return nfserr_attrnotsupp;
 	if ((bmval[0] & FATTR4_WORD0_ACL) && !IS_POSIXACL(d_inode(dentry)))
 		return nfserr_attrnotsupp;
+	if ((bmval[2] & FATTR4_WORD2_SECURITY_LABEL) &&
+			!(exp->ex_flags & NFSEXP_SECURITY_LABEL))
+		return nfserr_attrnotsupp;
 	if (writable && !bmval_is_subset(bmval, writable))
 		return nfserr_inval;
 	if (writable && (bmval[2] & FATTR4_WORD2_MODE_UMASK) &&
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 64c262aef633..8475c4df9aa2 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2416,8 +2416,11 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp,
 #ifdef CONFIG_NFSD_V4_SECURITY_LABEL
 	if ((bmval2 & FATTR4_WORD2_SECURITY_LABEL) ||
 	     bmval0 & FATTR4_WORD0_SUPPORTED_ATTRS) {
-		err = security_inode_getsecctx(d_inode(dentry),
+		if (exp->ex_flags & NFSEXP_SECURITY_LABEL)
+			err = security_inode_getsecctx(d_inode(dentry),
 						&context, &contextlen);
+		else
+			err = -EOPNOTSUPP;
 		contextsupport = (err == 0);
 		if (bmval2 & FATTR4_WORD2_SECURITY_LABEL) {
 			if (err == -EOPNOTSUPP)
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 26c6fdb4bf67..9e11ee1ec3a9 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -486,12 +486,14 @@ __be32 nfsd4_set_nfs4_label(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	__be32 error;
 	int host_error;
 	struct dentry *dentry;
+	struct svc_export *exp;
 
 	error = fh_verify(rqstp, fhp, 0 /* S_IFREG */, NFSD_MAY_SATTR);
 	if (error)
 		return error;
 
 	dentry = fhp->fh_dentry;
+	exp = fhp->fh_export;
 
 	inode_lock(d_inode(dentry));
 	host_error = security_inode_setsecctx(dentry, label->data, label->len);
diff --git a/include/uapi/linux/nfsd/export.h b/include/uapi/linux/nfsd/export.h
index 0df7bd5d2fb1..c3be256107c6 100644
--- a/include/uapi/linux/nfsd/export.h
+++ b/include/uapi/linux/nfsd/export.h
@@ -32,7 +32,8 @@
 #define NFSEXP_ASYNC		0x0010
 #define NFSEXP_GATHERED_WRITES	0x0020
 #define NFSEXP_NOREADDIRPLUS    0x0040
-/* 80 100 currently unused */
+#define NFSEXP_SECURITY_LABEL	0x0080
+/* 0x100 currently unused */
 #define NFSEXP_NOHIDE		0x0200
 #define NFSEXP_NOSUBTREECHECK	0x0400
 #define	NFSEXP_NOAUTHNLM	0x0800		/* Don't authenticate NLM requests - just trust */
@@ -53,7 +54,7 @@
 #define NFSEXP_PNFS		0x20000
 
 /* All flags that we claim to support.  (Note we don't support NOACL.) */
-#define NFSEXP_ALLFLAGS		0x3FE7F
+#define NFSEXP_ALLFLAGS		0x3FEFF
 
 /* The flags that may vary depending on security flavor: */
 #define NFSEXP_SECINFO_FLAGS	(NFSEXP_READONLY | NFSEXP_ROOTSQUASH \
