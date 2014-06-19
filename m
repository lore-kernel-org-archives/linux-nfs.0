Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f177.google.com ([209.85.216.177]:59208 "EHLO
	mail-qc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757959AbaFSOv2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:51:28 -0400
Received: by mail-qc0-f177.google.com with SMTP id r5so2242090qcx.22
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:51:27 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 021/104] NFSd: Add reference counting to the lock and open stateids
Date: Thu, 19 Jun 2014 10:49:27 -0400
Message-Id: <1403189450-18729-22-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d708e7c807d5..c01f1628c989 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -750,8 +750,10 @@ static void close_generic_stateid(struct nfs4_ol_stateid *stp)
 	release_all_access(stp);
 }
 
-static void free_generic_stateid(struct nfs4_ol_stateid *stp)
+static void put_generic_stateid(struct nfs4_ol_stateid *stp)
 {
+	if (!atomic_dec_and_test(&stp->st_stid.sc_count))
+		return;
 	remove_stid(&stp->st_stid);
 	if (stp->st_file)
 		put_nfs4_file(stp->st_file);
@@ -770,7 +772,7 @@ static void __release_lock_stateid(struct nfs4_lockowner *lo,
 	if (file)
 		filp_close(file, (fl_owner_t)lo);
 	close_generic_stateid(stp);
-	free_generic_stateid(stp);
+	put_generic_stateid(stp);
 }
 
 static void unhash_lockowner(struct nfs4_lockowner *lo)
@@ -833,7 +835,7 @@ static void unhash_open_stateid(struct nfs4_ol_stateid *stp)
 static void release_open_stateid(struct nfs4_ol_stateid *stp)
 {
 	unhash_open_stateid(stp);
-	free_generic_stateid(stp);
+	put_generic_stateid(stp);
 }
 
 static void unhash_openowner(struct nfs4_openowner *oo)
@@ -854,7 +856,7 @@ static void release_last_closed_stateid(struct nfs4_openowner *oo)
 	struct nfs4_ol_stateid *s = oo->oo_last_closed_stid;
 
 	if (s) {
-		free_generic_stateid(s);
+		put_generic_stateid(s);
 		oo->oo_last_closed_stid = NULL;
 	}
 }
@@ -3607,7 +3609,7 @@ void nfsd4_cleanup_open_state(struct nfsd4_open *open, __be32 status)
 	if (open->op_file)
 		nfsd4_free_file(open->op_file);
 	if (open->op_stp)
-		free_generic_stateid(open->op_stp);
+		put_generic_stateid(open->op_stp);
 }
 
 static __be32 lookup_clientid(clientid_t *clid, bool session, struct nfsd_net *nn, struct nfs4_client **clp)
@@ -4333,7 +4335,7 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	nfsd4_close_open_stateid(stp);
 
 	if (cstate->minorversion)
-		free_generic_stateid(stp);
+		put_generic_stateid(stp);
 	else {
 		if (stp->st_file) {
 			put_nfs4_file(stp->st_file);
-- 
1.9.3

