Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f172.google.com ([209.85.216.172]:45370 "EHLO
	mail-qc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755184AbaGUPDD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jul 2014 11:03:03 -0400
Received: by mail-qc0-f172.google.com with SMTP id l6so5767513qcy.3
        for <linux-nfs@vger.kernel.org>; Mon, 21 Jul 2014 08:03:02 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH 02/40] nfsd: Add reference counting to the lock and open stateids
Date: Mon, 21 Jul 2014 11:02:14 -0400
Message-Id: <1405954972-28904-3-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1405954972-28904-1-git-send-email-jlayton@primarydata.com>
References: <1405954972-28904-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

When we remove the client_mutex, we'll need to be able to ensure that
these objects aren't destroyed while we're not holding locks.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 3e55df0d7504..76d28be3ef41 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -883,8 +883,10 @@ static void close_generic_stateid(struct nfs4_ol_stateid *stp)
 	release_all_access(stp);
 }
 
-static void free_generic_stateid(struct nfs4_ol_stateid *stp)
+static void put_generic_stateid(struct nfs4_ol_stateid *stp)
 {
+	if (!atomic_dec_and_test(&stp->st_stid.sc_count))
+		return;
 	if (stp->st_file)
 		put_nfs4_file(stp->st_file);
 	remove_stid(&stp->st_stid);
@@ -902,7 +904,7 @@ static void __release_lock_stateid(struct nfs4_ol_stateid *stp)
 	if (file)
 		filp_close(file, (fl_owner_t)lockowner(stp->st_stateowner));
 	close_generic_stateid(stp);
-	free_generic_stateid(stp);
+	put_generic_stateid(stp);
 }
 
 static void unhash_lockowner(struct nfs4_lockowner *lo)
@@ -965,7 +967,7 @@ static void unhash_open_stateid(struct nfs4_ol_stateid *stp)
 static void release_open_stateid(struct nfs4_ol_stateid *stp)
 {
 	unhash_open_stateid(stp);
-	free_generic_stateid(stp);
+	put_generic_stateid(stp);
 }
 
 static void unhash_openowner(struct nfs4_openowner *oo)
@@ -986,7 +988,7 @@ static void release_last_closed_stateid(struct nfs4_openowner *oo)
 	struct nfs4_ol_stateid *s = oo->oo_last_closed_stid;
 
 	if (s) {
-		free_generic_stateid(s);
+		put_generic_stateid(s);
 		oo->oo_last_closed_stid = NULL;
 	}
 }
@@ -3823,7 +3825,7 @@ void nfsd4_cleanup_open_state(struct nfsd4_open *open, __be32 status)
 	if (open->op_file)
 		nfsd4_free_file(open->op_file);
 	if (open->op_stp)
-		free_generic_stateid(open->op_stp);
+		put_generic_stateid(open->op_stp);
 }
 
 __be32
@@ -4482,9 +4484,9 @@ static void nfsd4_close_open_stateid(struct nfs4_ol_stateid *s)
 	unhash_open_stateid(s);
 
 	if (clp->cl_minorversion) {
-		free_generic_stateid(s);
 		if (list_empty(&oo->oo_owner.so_stateids))
 			release_openowner(oo);
+		put_generic_stateid(s);
 	} else {
 		if (s->st_file) {
 			put_nfs4_file(s->st_file);
-- 
1.9.3

