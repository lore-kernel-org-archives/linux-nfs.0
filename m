Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:39597 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965547AbbD1Nmf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Apr 2015 09:42:35 -0400
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 3/6] nfsd: refactor nfs4_preprocess_stateid_op
Date: Tue, 28 Apr 2015 15:41:17 +0200
Message-Id: <1430228480-7656-4-git-send-email-hch@lst.de>
In-Reply-To: <1430228480-7656-1-git-send-email-hch@lst.de>
References: <1430228480-7656-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Split out two self contained helpers to make the function more readable.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs4state.c | 97 ++++++++++++++++++++++++++++-------------------------
 1 file changed, 52 insertions(+), 45 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 39475c9..5070688 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4575,20 +4575,51 @@ nfsd4_lookup_stateid(struct nfsd4_compound_state *cstate,
 	return nfs_ok;
 }
 
+static struct file *
+nfs4_find_file(struct nfs4_stid *s, int flags)
+{
+	switch (s->sc_type) {
+	case NFS4_DELEG_STID:
+		if (WARN_ON_ONCE(!s->sc_file->fi_deleg_file))
+			return NULL;
+		return get_file(s->sc_file->fi_deleg_file);
+	case NFS4_OPEN_STID:
+	case NFS4_LOCK_STID:
+		if (flags & RD_STATE)
+			return find_readable_file(s->sc_file);
+		else
+			return find_writeable_file(s->sc_file);
+		break;
+	}
+
+	return NULL;
+}
+
+static __be32
+nfs4_check_olstateid(struct svc_fh *fhp, struct nfs4_ol_stateid *ols, int flags)
+{
+	__be32 status;
+
+	status = nfs4_check_fh(fhp, ols);
+	if (status)
+		return status;
+	status = nfsd4_check_openowner_confirmed(ols);
+	if (status)
+		return status;
+	return nfs4_check_openmode(ols, flags);
+}
+
 /*
-* Checks for stateid operations
-*/
+ * Checks for stateid operations
+ */
 __be32
 nfs4_preprocess_stateid_op(struct net *net, struct nfsd4_compound_state *cstate,
 			   stateid_t *stateid, int flags, struct file **filpp)
 {
-	struct nfs4_stid *s;
-	struct nfs4_ol_stateid *stp = NULL;
-	struct nfs4_delegation *dp = NULL;
-	struct svc_fh *current_fh = &cstate->current_fh;
-	struct inode *ino = d_inode(current_fh->fh_dentry);
+	struct svc_fh *fhp = &cstate->current_fh;
+	struct inode *ino = d_inode(fhp->fh_dentry);
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
-	struct file *file = NULL;
+	struct nfs4_stid *s;
 	__be32 status;
 
 	if (filpp)
@@ -4598,60 +4629,36 @@ nfs4_preprocess_stateid_op(struct net *net, struct nfsd4_compound_state *cstate,
 		return nfserr_grace;
 
 	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid))
-		return check_special_stateids(net, current_fh, stateid, flags);
+		return check_special_stateids(net, fhp, stateid, flags);
 
 	status = nfsd4_lookup_stateid(cstate, stateid,
 				NFS4_DELEG_STID|NFS4_OPEN_STID|NFS4_LOCK_STID,
 				&s, nn);
 	if (status)
 		return status;
-	status = check_stateid_generation(stateid, &s->sc_stateid, nfsd4_has_session(cstate));
+	status = check_stateid_generation(stateid, &s->sc_stateid,
+			nfsd4_has_session(cstate));
 	if (status)
 		goto out;
+
 	switch (s->sc_type) {
 	case NFS4_DELEG_STID:
-		dp = delegstateid(s);
-		status = nfs4_check_delegmode(dp, flags);
-		if (status)
-			goto out;
-		if (filpp) {
-			file = dp->dl_stid.sc_file->fi_deleg_file;
-			if (!file) {
-				WARN_ON_ONCE(1);
-				status = nfserr_serverfault;
-				goto out;
-			}
-			get_file(file);
-		}
+		status = nfs4_check_delegmode(delegstateid(s), flags);
 		break;
 	case NFS4_OPEN_STID:
 	case NFS4_LOCK_STID:
-		stp = openlockstateid(s);
-		status = nfs4_check_fh(current_fh, stp);
-		if (status)
-			goto out;
-		status = nfsd4_check_openowner_confirmed(stp);
-		if (status)
-			goto out;
-		status = nfs4_check_openmode(stp, flags);
-		if (status)
-			goto out;
-		if (filpp) {
-			struct nfs4_file *fp = stp->st_stid.sc_file;
-
-			if (flags & RD_STATE)
-				file = find_readable_file(fp);
-			else
-				file = find_writeable_file(fp);
-		}
+		status = nfs4_check_olstateid(fhp, openlockstateid(s), flags);
 		break;
 	default:
 		status = nfserr_bad_stateid;
-		goto out;
+		break;
+	}
+
+	if (!status && filpp) {
+		*filpp = nfs4_find_file(s, flags);
+		if (!*filpp)
+			status = nfserr_serverfault;
 	}
-	status = nfs_ok;
-	if (file)
-		*filpp = file;
 out:
 	nfs4_put_stid(s);
 	return status;
-- 
1.9.1

