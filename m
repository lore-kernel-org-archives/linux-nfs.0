Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f45.google.com ([209.85.216.45]:62027 "EHLO
	mail-qa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751511AbaFZTOl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2014 15:14:41 -0400
Received: by mail-qa0-f45.google.com with SMTP id v10so3161863qac.18
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jun 2014 12:14:40 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v2 040/117] nfsd: Add reference counting to the lock and open stateids
Date: Thu, 26 Jun 2014 15:12:20 -0400
Message-Id: <1403810017-16062-41-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
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
index 78b90880d291..cad93b38f20b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -872,8 +872,10 @@ static void close_generic_stateid(struct nfs4_ol_stateid *stp)
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
@@ -891,7 +893,7 @@ static void __release_lock_stateid(struct nfs4_ol_stateid *stp)
 	if (file)
 		filp_close(file, (fl_owner_t)lockowner(stp->st_stateowner));
 	close_generic_stateid(stp);
-	free_generic_stateid(stp);
+	put_generic_stateid(stp);
 }
 
 static void unhash_lockowner(struct nfs4_lockowner *lo)
@@ -954,7 +956,7 @@ static void unhash_open_stateid(struct nfs4_ol_stateid *stp)
 static void release_open_stateid(struct nfs4_ol_stateid *stp)
 {
 	unhash_open_stateid(stp);
-	free_generic_stateid(stp);
+	put_generic_stateid(stp);
 }
 
 static void unhash_openowner(struct nfs4_openowner *oo)
@@ -975,7 +977,7 @@ static void release_last_closed_stateid(struct nfs4_openowner *oo)
 	struct nfs4_ol_stateid *s = oo->oo_last_closed_stid;
 
 	if (s) {
-		free_generic_stateid(s);
+		put_generic_stateid(s);
 		oo->oo_last_closed_stid = NULL;
 	}
 }
@@ -3742,7 +3744,7 @@ void nfsd4_cleanup_open_state(struct nfsd4_open *open, __be32 status)
 	if (open->op_file)
 		nfsd4_free_file(open->op_file);
 	if (open->op_stp)
-		free_generic_stateid(open->op_stp);
+		put_generic_stateid(open->op_stp);
 }
 
 static __be32 lookup_clientid(clientid_t *clid,
@@ -4435,9 +4437,9 @@ static void nfsd4_close_open_stateid(struct nfs4_ol_stateid *s)
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

