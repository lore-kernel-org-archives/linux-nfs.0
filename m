From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 1/2] nfsd4: fix use of op_share_access
Date: Fri, 21 May 2010 19:33:06 -0400
Message-ID: <1274484787-15176-1-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:35361 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758780Ab0EUXdI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 May 2010 19:33:08 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFSv4.1 adds additional flags to the share_access argument of the open
call.  These flags need to be masked out in some of the existing code,
but current code does that inconsistently.

Tested-by: Michael Groshans <groshans@citi.umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4state.c |   16 ++++++++++++----
 1 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 12f7109..1176708 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2255,6 +2255,13 @@ find_delegation_file(struct nfs4_file *fp, stateid_t *stid)
 	return NULL;
 }
 
+int share_access_to_flags(u32 share_access)
+{
+	share_access &= ~NFS4_SHARE_WANT_MASK;
+
+	return share_access == NFS4_SHARE_ACCESS_READ ? RD_STATE : WR_STATE;
+}
+
 static __be32
 nfs4_check_deleg(struct nfs4_file *fp, struct nfsd4_open *open,
 		struct nfs4_delegation **dp)
@@ -2265,8 +2272,7 @@ nfs4_check_deleg(struct nfs4_file *fp, struct nfsd4_open *open,
 	*dp = find_delegation_file(fp, &open->op_delegate_stateid);
 	if (*dp == NULL)
 		goto out;
-	flags = open->op_share_access == NFS4_SHARE_ACCESS_READ ?
-						RD_STATE : WR_STATE;
+	flags = share_access_to_flags(open->op_share_access);
 	status = nfs4_check_delegmode(*dp, flags);
 	if (status)
 		*dp = NULL;
@@ -2358,6 +2364,7 @@ nfs4_upgrade_open(struct svc_rqst *rqstp, struct svc_fh *cur_fh, struct nfs4_sta
 	struct file *filp = stp->st_vfs_file;
 	struct inode *inode = filp->f_path.dentry->d_inode;
 	unsigned int share_access, new_writer;
+	u32 op_share_access;
 	__be32 status;
 
 	set_access(&share_access, stp->st_access_bmap);
@@ -2380,8 +2387,9 @@ nfs4_upgrade_open(struct svc_rqst *rqstp, struct svc_fh *cur_fh, struct nfs4_sta
 		return status;
 	}
 	/* remember the open */
-	filp->f_mode |= open->op_share_access;
-	__set_bit(open->op_share_access, &stp->st_access_bmap);
+	op_share_access = open->op_share_access & ~NFS4_SHARE_WANT_MASK;
+	filp->f_mode |= op_share_access;
+	__set_bit(op_share_access, &stp->st_access_bmap);
 	__set_bit(open->op_share_deny, &stp->st_deny_bmap);
 
 	return nfs_ok;
-- 
1.7.0.4

