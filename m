Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f174.google.com ([209.85.216.174]:48618 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759925Ab2EKNpn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 May 2012 09:45:43 -0400
Received: by mail-qc0-f174.google.com with SMTP id o28so1953866qcr.19
        for <linux-nfs@vger.kernel.org>; Fri, 11 May 2012 06:45:43 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 4/4] nfsd: wrap all accesses to st_deny_bmap
Date: Fri, 11 May 2012 09:45:14 -0400
Message-Id: <1336743914-944-5-git-send-email-jlayton@redhat.com>
In-Reply-To: <1336743914-944-1-git-send-email-jlayton@redhat.com>
References: <1336743914-944-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Handle the st_deny_bmap in a similar fashion to the st_access_bmap. Add
accessor functions and use those instead of bare bitops.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfs4state.c |   37 +++++++++++++++++++++++++++++--------
 1 files changed, 29 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 070204a..db87329 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -491,6 +491,27 @@ test_access(u32 access, struct nfs4_ol_stateid *stp)
 	return test_bit(access, &stp->st_access_bmap);
 }
 
+/* set share deny for a given stateid */
+static inline void
+set_deny(u32 access, struct nfs4_ol_stateid *stp)
+{
+	__set_bit(access, &stp->st_deny_bmap);
+}
+
+/* clear share deny for a given stateid */
+static inline void
+clear_deny(u32 access, struct nfs4_ol_stateid *stp)
+{
+	__clear_bit(access, &stp->st_deny_bmap);
+}
+
+/* test whether a given stateid is denying specific access */
+static inline bool
+test_deny(u32 access, struct nfs4_ol_stateid *stp)
+{
+	return test_bit(access, &stp->st_deny_bmap);
+}
+
 static int nfs4_access_to_omode(u32 access)
 {
 	switch (access & NFS4_SHARE_ACCESS_BOTH) {
@@ -2471,7 +2492,7 @@ static void init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp,
 	stp->st_access_bmap = 0;
 	stp->st_deny_bmap = 0;
 	set_access(open->op_share_access, stp);
-	__set_bit(open->op_share_deny, &stp->st_deny_bmap);
+	set_deny(open->op_share_deny, stp);
 	stp->st_openstp = NULL;
 }
 
@@ -2550,8 +2571,8 @@ nfs4_share_conflict(struct svc_fh *current_fh, unsigned int deny_type)
 	ret = nfserr_locked;
 	/* Search for conflicting share reservations */
 	list_for_each_entry(stp, &fp->fi_stateids, st_perfile) {
-		if (test_bit(deny_type, &stp->st_deny_bmap) ||
-		    test_bit(NFS4_SHARE_DENY_BOTH, &stp->st_deny_bmap))
+		if (test_deny(deny_type, stp) ||
+		    test_deny(NFS4_SHARE_DENY_BOTH, stp))
 			goto out;
 	}
 	ret = nfs_ok;
@@ -2823,7 +2844,7 @@ nfs4_upgrade_open(struct svc_rqst *rqstp, struct nfs4_file *fp, struct svc_fh *c
 	}
 	/* remember the open */
 	set_access(op_share_access, stp);
-	__set_bit(open->op_share_deny, &stp->st_deny_bmap);
+	set_deny(open->op_share_deny, stp);
 
 	return nfs_ok;
 }
@@ -3690,12 +3711,12 @@ static inline void nfs4_stateid_downgrade(struct nfs4_ol_stateid *stp, u32 to_ac
 }
 
 static void
-reset_union_bmap_deny(unsigned long deny, unsigned long *bmap)
+reset_union_bmap_deny(unsigned long deny, struct nfs4_ol_stateid *stp)
 {
 	int i;
 	for (i = 0; i < 4; i++) {
 		if ((i & deny) != i)
-			__clear_bit(i, bmap);
+			clear_deny(i, stp);
 	}
 }
 
@@ -3727,14 +3748,14 @@ nfsd4_open_downgrade(struct svc_rqst *rqstp,
 			stp->st_access_bmap, od->od_share_access);
 		goto out;
 	}
-	if (!test_bit(od->od_share_deny, &stp->st_deny_bmap)) {
+	if (!test_deny(od->od_share_deny, stp)) {
 		dprintk("NFSD:deny not a subset current bitmap: 0x%lx, input deny=%08x\n",
 			stp->st_deny_bmap, od->od_share_deny);
 		goto out;
 	}
 	nfs4_stateid_downgrade(stp, od->od_share_access);
 
-	reset_union_bmap_deny(od->od_share_deny, &stp->st_deny_bmap);
+	reset_union_bmap_deny(od->od_share_deny, stp);
 
 	update_stateid(&stp->st_stid.sc_stateid);
 	memcpy(&od->od_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
-- 
1.7.7.6

