Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f49.google.com ([209.85.216.49]:62611 "EHLO
	mail-qa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759318Ab2EKNpm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 May 2012 09:45:42 -0400
Received: by qabj40 with SMTP id j40so2149034qab.1
        for <linux-nfs@vger.kernel.org>; Fri, 11 May 2012 06:45:42 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 3/4] nfsd: wrap accesses to st_access_bmap
Date: Fri, 11 May 2012 09:45:13 -0400
Message-Id: <1336743914-944-4-git-send-email-jlayton@redhat.com>
In-Reply-To: <1336743914-944-1-git-send-email-jlayton@redhat.com>
References: <1336743914-944-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, we do this for the most part with "bare" bitops, but
eventually we'll need to expand the share mode code to handle access
and deny modes on other nodes.

In order to facilitate that code in the future, move to some generic
accessor functions. For now, these are mostly static inlines, but
eventually we'll want to move these to "real" functions that are
able to handle multi-node configurations or have a way to "swap in"
new operations to be done in lieu of or in conjunction with these
atomic bitops.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfs4state.c |   82 +++++++++++++++++++++++++++++++++-----------------
 1 files changed, 54 insertions(+), 28 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index bb9e00e..070204a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -470,6 +470,27 @@ test_share(struct nfs4_ol_stateid *stp, struct nfsd4_open *open) {
 	return true;
 }
 
+/* set share access for a given stateid */
+static inline void
+set_access(u32 access, struct nfs4_ol_stateid *stp)
+{
+	__set_bit(access, &stp->st_access_bmap);
+}
+
+/* clear share access for a given stateid */
+static inline void
+clear_access(u32 access, struct nfs4_ol_stateid *stp)
+{
+	__clear_bit(access, &stp->st_access_bmap);
+}
+
+/* test whether a given stateid has access */
+static inline bool
+test_access(u32 access, struct nfs4_ol_stateid *stp)
+{
+	return test_bit(access, &stp->st_access_bmap);
+}
+
 static int nfs4_access_to_omode(u32 access)
 {
 	switch (access & NFS4_SHARE_ACCESS_BOTH) {
@@ -483,6 +504,20 @@ static int nfs4_access_to_omode(u32 access)
 	BUG();
 }
 
+/* release all access and file references for a given stateid */
+static void
+release_all_access(struct nfs4_ol_stateid *stp)
+{
+	int i;
+
+	for (i = 1; i < 4; i++) {
+		if (test_access(i, stp))
+			nfs4_file_put_access(stp->st_file,
+					     nfs4_access_to_omode(i));
+		clear_access(i, stp);
+	}
+}
+
 static void unhash_generic_stateid(struct nfs4_ol_stateid *stp)
 {
 	list_del(&stp->st_perfile);
@@ -491,16 +526,7 @@ static void unhash_generic_stateid(struct nfs4_ol_stateid *stp)
 
 static void close_generic_stateid(struct nfs4_ol_stateid *stp)
 {
-	int i;
-
-	if (stp->st_access_bmap) {
-		for (i = 1; i < 4; i++) {
-			if (test_bit(i, &stp->st_access_bmap))
-				nfs4_file_put_access(stp->st_file,
-						nfs4_access_to_omode(i));
-			__clear_bit(i, &stp->st_access_bmap);
-		}
-	}
+	release_all_access(stp);
 	put_nfs4_file(stp->st_file);
 	stp->st_file = NULL;
 }
@@ -2444,7 +2470,7 @@ static void init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp,
 	stp->st_file = fp;
 	stp->st_access_bmap = 0;
 	stp->st_deny_bmap = 0;
-	__set_bit(open->op_share_access, &stp->st_access_bmap);
+	set_access(open->op_share_access, stp);
 	__set_bit(open->op_share_deny, &stp->st_deny_bmap);
 	stp->st_openstp = NULL;
 }
@@ -2781,7 +2807,7 @@ nfs4_upgrade_open(struct svc_rqst *rqstp, struct nfs4_file *fp, struct svc_fh *c
 	bool new_access;
 	__be32 status;
 
-	new_access = !test_bit(op_share_access, &stp->st_access_bmap);
+	new_access = !test_access(op_share_access, stp);
 	if (new_access) {
 		status = nfs4_get_vfs_file(rqstp, fp, cur_fh, open);
 		if (status)
@@ -2796,7 +2822,7 @@ nfs4_upgrade_open(struct svc_rqst *rqstp, struct nfs4_file *fp, struct svc_fh *c
 		return status;
 	}
 	/* remember the open */
-	__set_bit(op_share_access, &stp->st_access_bmap);
+	set_access(op_share_access, stp);
 	__set_bit(open->op_share_deny, &stp->st_deny_bmap);
 
 	return nfs_ok;
@@ -3266,18 +3292,18 @@ STALE_STATEID(stateid_t *stateid)
 }
 
 static inline int
-access_permit_read(unsigned long access_bmap)
+access_permit_read(struct nfs4_ol_stateid *stp)
 {
-	return test_bit(NFS4_SHARE_ACCESS_READ, &access_bmap) ||
-		test_bit(NFS4_SHARE_ACCESS_BOTH, &access_bmap) ||
-		test_bit(NFS4_SHARE_ACCESS_WRITE, &access_bmap);
+	return test_access(NFS4_SHARE_ACCESS_READ, stp) ||
+		test_access(NFS4_SHARE_ACCESS_BOTH, stp) ||
+		test_access(NFS4_SHARE_ACCESS_WRITE, stp);
 }
 
 static inline int
-access_permit_write(unsigned long access_bmap)
+access_permit_write(struct nfs4_ol_stateid *stp)
 {
-	return test_bit(NFS4_SHARE_ACCESS_WRITE, &access_bmap) ||
-		test_bit(NFS4_SHARE_ACCESS_BOTH, &access_bmap);
+	return test_access(NFS4_SHARE_ACCESS_WRITE, stp) ||
+		test_access(NFS4_SHARE_ACCESS_BOTH, stp);
 }
 
 static
@@ -3288,9 +3314,9 @@ __be32 nfs4_check_openmode(struct nfs4_ol_stateid *stp, int flags)
 	/* For lock stateid's, we test the parent open, not the lock: */
 	if (stp->st_openstp)
 		stp = stp->st_openstp;
-	if ((flags & WR_STATE) && (!access_permit_write(stp->st_access_bmap)))
+	if ((flags & WR_STATE) && !access_permit_write(stp))
                 goto out;
-	if ((flags & RD_STATE) && (!access_permit_read(stp->st_access_bmap)))
+	if ((flags & RD_STATE) && !access_permit_read(stp))
                 goto out;
 	status = nfs_ok;
 out:
@@ -3639,10 +3665,10 @@ out:
 
 static inline void nfs4_stateid_downgrade_bit(struct nfs4_ol_stateid *stp, u32 access)
 {
-	if (!test_bit(access, &stp->st_access_bmap))
+	if (!test_access(access, stp))
 		return;
 	nfs4_file_put_access(stp->st_file, nfs4_access_to_omode(access));
-	__clear_bit(access, &stp->st_access_bmap);
+	clear_access(access, stp);
 }
 
 static inline void nfs4_stateid_downgrade(struct nfs4_ol_stateid *stp, u32 to_access)
@@ -3696,8 +3722,8 @@ nfsd4_open_downgrade(struct svc_rqst *rqstp,
 	if (status)
 		goto out; 
 	status = nfserr_inval;
-	if (!test_bit(od->od_share_access, &stp->st_access_bmap)) {
-		dprintk("NFSD:access not a subset current bitmap: 0x%lx, input access=%08x\n",
+	if (!test_access(od->od_share_access, stp)) {
+		dprintk("NFSD: access not a subset current bitmap: 0x%lx, input access=%08x\n",
 			stp->st_access_bmap, od->od_share_access);
 		goto out;
 	}
@@ -3998,10 +4024,10 @@ static void get_lock_access(struct nfs4_ol_stateid *lock_stp, u32 access)
 	struct nfs4_file *fp = lock_stp->st_file;
 	int oflag = nfs4_access_to_omode(access);
 
-	if (test_bit(access, &lock_stp->st_access_bmap))
+	if (test_access(access, lock_stp))
 		return;
 	nfs4_file_get_access(fp, oflag);
-	__set_bit(access, &lock_stp->st_access_bmap);
+	set_access(access, lock_stp);
 }
 
 __be32 lookup_or_create_lock_state(struct nfsd4_compound_state *cstate, struct nfs4_ol_stateid *ost, struct nfsd4_lock *lock, struct nfs4_ol_stateid **lst, bool *new)
-- 
1.7.7.6

