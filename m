Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:48199 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756149AbdKCMAX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Nov 2017 08:00:23 -0400
Received: by mail-io0-f194.google.com with SMTP id d66so5710433ioe.5
        for <linux-nfs@vger.kernel.org>; Fri, 03 Nov 2017 05:00:22 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/7] nfsd: Fix another OPEN stateid race
Date: Fri,  3 Nov 2017 08:00:11 -0400
Message-Id: <20171103120016.6200-3-trond.myklebust@primarydata.com>
In-Reply-To: <20171103120016.6200-2-trond.myklebust@primarydata.com>
References: <20171103120016.6200-1-trond.myklebust@primarydata.com>
 <20171103120016.6200-2-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If nfsd4_process_open2() is initialising a new stateid, and yet the
call to nfs4_get_vfs_file() fails for some reason, then we must
declare the stateid closed, and unhash it before dropping the mutex.

Right now, we unhash the stateid after dropping the mutex, and without
changing the stateid type, meaning that another OPEN could theoretically
look it up and attempt to use it.

Reported-by: Andrew W Elble <aweits@rit.edu>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: stable@vger.kernel.org
---
 fs/nfsd/nfs4state.c | 28 +++++++++++++---------------
 1 file changed, 13 insertions(+), 15 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index b246aaa20863..c7dcedbd9c41 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4445,6 +4445,7 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 	struct nfs4_ol_stateid *stp = NULL;
 	struct nfs4_delegation *dp = NULL;
 	__be32 status;
+	bool new_stp = false;
 
 	/*
 	 * Lookup file; if found, lookup stateid and check open request,
@@ -4464,11 +4465,19 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 			goto out;
 	}
 
+	if (!stp) {
+		stp = init_open_stateid(fp, open);
+		if (!open->op_stp)
+			new_stp = true;
+	}
+
 	/*
 	 * OPEN the file, or upgrade an existing OPEN.
 	 * If truncate fails, the OPEN fails.
+	 *
+	 * stp is already locked.
 	 */
-	if (stp) {
+	if (!new_stp) {
 		/* Stateid was found, this is an OPEN upgrade */
 		status = nfs4_upgrade_open(rqstp, fp, current_fh, stp, open);
 		if (status) {
@@ -4476,22 +4485,11 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 			goto out;
 		}
 	} else {
-		/* stp is returned locked. */
-		stp = init_open_stateid(fp, open);
-		/* See if we lost the race to some other thread */
-		if (stp->st_access_bmap != 0) {
-			status = nfs4_upgrade_open(rqstp, fp, current_fh,
-						stp, open);
-			if (status) {
-				mutex_unlock(&stp->st_mutex);
-				goto out;
-			}
-			goto upgrade_out;
-		}
 		status = nfs4_get_vfs_file(rqstp, fp, current_fh, stp, open);
 		if (status) {
-			mutex_unlock(&stp->st_mutex);
+			stp->st_stid.sc_type = NFS4_CLOSED_STID;
 			release_open_stateid(stp);
+			mutex_unlock(&stp->st_mutex);
 			goto out;
 		}
 
@@ -4500,7 +4498,7 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 		if (stp->st_clnt_odstate == open->op_odstate)
 			open->op_odstate = NULL;
 	}
-upgrade_out:
+
 	nfs4_inc_and_copy_stateid(&open->op_stateid, &stp->st_stid);
 	mutex_unlock(&stp->st_mutex);
 
-- 
2.13.6

