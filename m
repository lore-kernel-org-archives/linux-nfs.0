Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44192 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754926Ab1JKQlJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Oct 2011 12:41:09 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 4/4] nfsd4: more robust ignoring of WANT bits in OPEN
Date: Tue, 11 Oct 2011 12:41:03 -0400
Message-Id: <1318351263-14918-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1318351263-14918-1-git-send-email-bfields@redhat.com>
References: <1318351263-14918-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Mask out the WANT bits right at the start instead of on each use.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c  |    3 +++
 fs/nfsd/nfs4state.c |    5 ++---
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 4e41f65..5b192a2 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -315,6 +315,9 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (open->op_create && open->op_claim_type != NFS4_OPEN_CLAIM_NULL)
 		return nfserr_inval;
 
+	/* We don't yet support WANT bits: */
+	open->op_share_access &= NFS4_SHARE_ACCESS_MASK;
+
 	/*
 	 * RFC5661 18.51.3
 	 * Before RECLAIM_COMPLETE done, server should deny new lock
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 5f35f35..2042805 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2345,8 +2345,7 @@ static inline __be32 init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_
 	stp->st_file = fp;
 	stp->st_access_bmap = 0;
 	stp->st_deny_bmap = 0;
-	__set_bit(open->op_share_access & ~NFS4_SHARE_WANT_MASK,
-		  &stp->st_access_bmap);
+	__set_bit(open->op_share_access, &stp->st_access_bmap);
 	__set_bit(open->op_share_deny, &stp->st_deny_bmap);
 	stp->st_openstp = NULL;
 	return nfs_ok;
@@ -2690,7 +2689,7 @@ nfsd4_truncate(struct svc_rqst *rqstp, struct svc_fh *fh,
 static __be32
 nfs4_upgrade_open(struct svc_rqst *rqstp, struct nfs4_file *fp, struct svc_fh *cur_fh, struct nfs4_ol_stateid *stp, struct nfsd4_open *open)
 {
-	u32 op_share_access = open->op_share_access & ~NFS4_SHARE_WANT_MASK;
+	u32 op_share_access = open->op_share_access;
 	bool new_access;
 	__be32 status;
 
-- 
1.7.4.1

