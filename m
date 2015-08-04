Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:36383 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933307AbbHDLzl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Aug 2015 07:55:41 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: linux-kernel@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-api@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-security-module@vger.kernel.org,
        Andreas Gruenbacher <agruenba@redhat.com>
Subject: [RFC v6 32/40] nfsd: Add support for the MAY_CREATE_{FILE,DIR} permissions
Date: Tue,  4 Aug 2015 13:53:30 +0200
Message-Id: <1438689218-6921-33-git-send-email-agruenba@redhat.com>
In-Reply-To: <1438689218-6921-1-git-send-email-agruenba@redhat.com>
References: <1438689218-6921-1-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For local file systems, the vfs performs the necessary permission checks
for operations like creating files and directories.  NFSd duplicates
several of those checks.  The vfs checks have been extended to check for
additional permissions like MAY_CREATE_FILE and MY_CREATE_DIR; the nfsd
checks currently lack those extensions.

Ideally, all duplicate checks should be removed; for now, just fix the
duplicate checks instead though.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/nfsd/nfs4proc.c |  5 +++--
 fs/nfsd/nfsfh.c    |  8 ++++----
 fs/nfsd/vfs.c      | 28 ++++++++++++++++++++--------
 fs/nfsd/vfs.h      | 17 +++++++++--------
 4 files changed, 36 insertions(+), 22 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index ef9e6cd..5213945 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -601,14 +601,15 @@ static __be32
 nfsd4_create(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	     struct nfsd4_create *create)
 {
+	int access = create->cr_type == NF4DIR ?
+		NFSD_MAY_CREATE_DIR : NFSD_MAY_CREATE_FILE;
 	struct svc_fh resfh;
 	__be32 status;
 	dev_t rdev;
 
 	fh_init(&resfh, NFS4_FHSIZE);
 
-	status = fh_verify(rqstp, &cstate->current_fh, S_IFDIR,
-			   NFSD_MAY_CREATE);
+	status = fh_verify(rqstp, &cstate->current_fh, S_IFDIR, access);
 	if (status)
 		return status;
 
diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index 350041a..7159316 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -319,10 +319,10 @@ fh_verify(struct svc_rqst *rqstp, struct svc_fh *fhp, umode_t type, int access)
 	/*
 	 * We still have to do all these permission checks, even when
 	 * fh_dentry is already set:
-	 * 	- fh_verify may be called multiple times with different
-	 * 	  "access" arguments (e.g. nfsd_proc_create calls
-	 * 	  fh_verify(...,NFSD_MAY_EXEC) first, then later (in
-	 * 	  nfsd_create) calls fh_verify(...,NFSD_MAY_CREATE).
+	 *	- fh_verify may be called multiple times with different
+	 *	  "access" arguments (e.g. nfsd_proc_create calls
+	 *	  fh_verify(...,NFSD_MAY_EXEC) first, then later (in
+	 *	  nfsd_create) calls fh_verify(...,NFSD_MAY_CREATE_FILE).
 	 *	- in the NFSv4 case, the filehandle may have been filled
 	 *	  in by fh_compose, and given a dentry, but further
 	 *	  compound operations performed with that filehandle
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index b5e077a..bd19096 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1128,6 +1128,8 @@ nfsd_create(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	__be32		err;
 	__be32		err2;
 	int		host_err;
+	int access = (type == S_IFDIR) ?
+		NFSD_MAY_CREATE_DIR : NFSD_MAY_CREATE_FILE;
 
 	err = nfserr_perm;
 	if (!flen)
@@ -1136,7 +1138,7 @@ nfsd_create(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	if (isdotent(fname, flen))
 		goto out;
 
-	err = fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_CREATE);
+	err = fh_verify(rqstp, fhp, S_IFDIR, access);
 	if (err)
 		goto out;
 
@@ -1307,7 +1309,7 @@ do_nfsd_create(struct svc_rqst *rqstp, struct svc_fh *fhp,
 
 	/* If file doesn't exist, check for permissions to create one */
 	if (d_really_is_negative(dchild)) {
-		err = fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_CREATE);
+		err = fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_CREATE_FILE);
 		if (err)
 			goto out;
 	}
@@ -1491,7 +1493,7 @@ nfsd_symlink(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	if (isdotent(fname, flen))
 		goto out;
 
-	err = fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_CREATE);
+	err = fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_CREATE_FILE);
 	if (err)
 		goto out;
 
@@ -1538,7 +1540,7 @@ nfsd_link(struct svc_rqst *rqstp, struct svc_fh *ffhp,
 	__be32		err;
 	int		host_err;
 
-	err = fh_verify(rqstp, ffhp, S_IFDIR, NFSD_MAY_CREATE);
+	err = fh_verify(rqstp, ffhp, S_IFDIR, NFSD_MAY_CREATE_FILE);
 	if (err)
 		goto out;
 	err = fh_verify(rqstp, tfhp, 0, NFSD_MAY_NOP);
@@ -1610,11 +1612,12 @@ nfsd_rename(struct svc_rqst *rqstp, struct svc_fh *ffhp, char *fname, int flen,
 	struct inode	*fdir, *tdir;
 	__be32		err;
 	int		host_err;
+	int		access;
 
 	err = fh_verify(rqstp, ffhp, S_IFDIR, NFSD_MAY_REMOVE);
 	if (err)
 		goto out;
-	err = fh_verify(rqstp, tfhp, S_IFDIR, NFSD_MAY_CREATE);
+	err = fh_verify(rqstp, tfhp, S_IFDIR, NFSD_MAY_NOP);
 	if (err)
 		goto out;
 
@@ -1653,6 +1656,13 @@ nfsd_rename(struct svc_rqst *rqstp, struct svc_fh *ffhp, char *fname, int flen,
 	if (odentry == trap)
 		goto out_dput_old;
 
+	host_err = 0;
+	access = S_ISDIR(d_inode(odentry)->i_mode) ?
+		NFSD_MAY_CREATE_DIR : NFSD_MAY_CREATE_FILE;
+	err = fh_verify(rqstp, tfhp, S_IFDIR, access);
+	if (err)
+		goto out_dput_old;
+
 	ndentry = lookup_one_len(tname, tdentry, tlen);
 	host_err = PTR_ERR(ndentry);
 	if (IS_ERR(ndentry))
@@ -1678,7 +1688,8 @@ nfsd_rename(struct svc_rqst *rqstp, struct svc_fh *ffhp, char *fname, int flen,
  out_dput_old:
 	dput(odentry);
  out_nfserr:
-	err = nfserrno(host_err);
+	if (host_err)
+		err = nfserrno(host_err);
 	/*
 	 * We cannot rely on fh_unlock on the two filehandles,
 	 * as that would do the wrong thing if the two directories
@@ -2011,8 +2022,9 @@ nfsd_permission(struct svc_rqst *rqstp, struct svc_export *exp,
 	    uid_eq(inode->i_uid, current_fsuid()))
 		return 0;
 
-	/* This assumes  NFSD_MAY_{READ,WRITE,EXEC} == MAY_{READ,WRITE,EXEC} */
-	err = inode_permission(inode, acc & (MAY_READ|MAY_WRITE|MAY_EXEC));
+	/* This assumes NFSD_MAY_{READ,WRITE,EXEC} == MAY_{READ,WRITE,EXEC}. */
+	err = inode_permission(inode, acc & (MAY_READ|MAY_WRITE|MAY_EXEC|
+					     MAY_CREATE_DIR|MAY_CREATE_FILE));
 
 	/* Allow read access to binaries even when mode 111 */
 	if (err == -EACCES && S_ISREG(inode->i_mode) &&
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index 5be875e..384fda4 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -19,18 +19,19 @@
 #define NFSD_MAY_TRUNC			0x010
 #define NFSD_MAY_LOCK			0x020
 #define NFSD_MAY_MASK			0x03f
+#define NFSD_MAY_CREATE_FILE		0x103 /* == MAY_{EXEC|WRITE|CREATE_FILE} */
+#define NFSD_MAY_CREATE_DIR		0x203 /* == MAY_{EXEC|WRITE|CREATE_DIR} */
 
 /* extra hints to permission and open routines: */
-#define NFSD_MAY_OWNER_OVERRIDE		0x040
-#define NFSD_MAY_LOCAL_ACCESS		0x080 /* for device special files */
-#define NFSD_MAY_BYPASS_GSS_ON_ROOT	0x100
-#define NFSD_MAY_NOT_BREAK_LEASE	0x200
-#define NFSD_MAY_BYPASS_GSS		0x400
-#define NFSD_MAY_READ_IF_EXEC		0x800
+#define NFSD_MAY_OWNER_OVERRIDE		0x04000
+#define NFSD_MAY_LOCAL_ACCESS		0x08000 /* for device special files */
+#define NFSD_MAY_BYPASS_GSS_ON_ROOT	0x10000
+#define NFSD_MAY_NOT_BREAK_LEASE	0x20000
+#define NFSD_MAY_BYPASS_GSS		0x40000
+#define NFSD_MAY_READ_IF_EXEC		0x80000
 
-#define NFSD_MAY_64BIT_COOKIE		0x1000 /* 64 bit readdir cookies for >= NFSv3 */
+#define NFSD_MAY_64BIT_COOKIE		0x100000 /* 64 bit readdir cookies for >= NFSv3 */
 
-#define NFSD_MAY_CREATE		(NFSD_MAY_EXEC|NFSD_MAY_WRITE)
 #define NFSD_MAY_REMOVE		(NFSD_MAY_EXEC|NFSD_MAY_WRITE|NFSD_MAY_TRUNC)
 
 /*
-- 
2.5.0

