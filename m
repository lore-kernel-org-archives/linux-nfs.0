Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:51802 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754134Ab1HaTxa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 31 Aug 2011 15:53:30 -0400
Date: Wed, 31 Aug 2011 15:53:29 -0400
To: linux-nfs@vger.kernel.org
Cc: Casey Bodley <cbodley@citi.umich.edu>
Subject: [PATCH] nfsd4: in-stateid seqid should start with 1
Message-ID: <20110831195329.GD19223@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: J. Bruce Fields <bfields@redhat.com>

Thanks to Casey for reminding me that 5661 gives a special meaning to a
value of 0 in the stateid's seqid field, so we should instead be
starting out stateid's with si_generation 1.

Reported-by: Casey Bodley <cbodley@citi.umich.edu>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 49c3dd1..7caa812 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -251,7 +251,7 @@ alloc_init_deleg(struct nfs4_client *clp, struct nfs4_stateid *stp, struct svc_f
 	dp->dl_stateid.si_boot = boot_time;
 	dp->dl_stateid.si_stateownerid = current_delegid++;
 	dp->dl_stateid.si_fileid = 0;
-	dp->dl_stateid.si_generation = 0;
+	dp->dl_stateid.si_generation = 1;
 	fh_copy_shallow(&dp->dl_fh, &current_fh->fh_handle);
 	dp->dl_time = 0;
 	atomic_set(&dp->dl_count, 1);
@@ -2303,7 +2303,7 @@ init_stateid(struct nfs4_stateid *stp, struct nfs4_file *fp, struct nfsd4_open *
 	stp->st_stateid.si_boot = boot_time;
 	stp->st_stateid.si_stateownerid = oo->oo_owner.so_id;
 	stp->st_stateid.si_fileid = fp->fi_id;
-	stp->st_stateid.si_generation = 0;
+	stp->st_stateid.si_generation = 1;
 	stp->st_access_bmap = 0;
 	stp->st_deny_bmap = 0;
 	__set_bit(open->op_share_access & ~NFS4_SHARE_WANT_MASK,
@@ -3898,7 +3898,7 @@ alloc_init_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp, struct
 	stp->st_stateid.si_boot = boot_time;
 	stp->st_stateid.si_stateownerid = lo->lo_owner.so_id;
 	stp->st_stateid.si_fileid = fp->fi_id;
-	stp->st_stateid.si_generation = 0;
+	stp->st_stateid.si_generation = 1;
 	stp->st_access_bmap = 0;
 	stp->st_deny_bmap = open_stp->st_deny_bmap;
 	stp->st_openstp = open_stp;
-- 
1.7.4.1

