Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f43.google.com ([209.85.216.43]:33526 "EHLO
	mail-qa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754352AbaG2Uec (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jul 2014 16:34:32 -0400
Received: by mail-qa0-f43.google.com with SMTP id w8so249669qac.30
        for <linux-nfs@vger.kernel.org>; Tue, 29 Jul 2014 13:34:31 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v2 01/38] nfsd: Add reference counting to the lock and open stateids
Date: Tue, 29 Jul 2014 16:33:44 -0400
Message-Id: <1406666061-14175-2-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406666061-14175-1-git-send-email-jlayton@primarydata.com>
References: <1406666061-14175-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

When we remove the client_mutex, we'll need to be able to ensure that
these objects aren't destroyed while we're not holding locks.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs4state.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index b0f83beeca75..3b0836db8553 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -890,8 +890,10 @@ static void close_generic_stateid(struct nfs4_ol_stateid *stp)
 	release_all_access(stp);
 }
 
-static void free_generic_stateid(struct nfs4_ol_stateid *stp)
+static void put_ol_stateid(struct nfs4_ol_stateid *stp)
 {
+	if (!atomic_dec_and_test(&stp->st_stid.sc_count))
+		return;
 	if (stp->st_file)
 		put_nfs4_file(stp->st_file);
 	remove_stid(&stp->st_stid);
@@ -909,7 +911,7 @@ static void __release_lock_stateid(struct nfs4_ol_stateid *stp)
 	if (file)
 		filp_close(file, (fl_owner_t)lockowner(stp->st_stateowner));
 	close_generic_stateid(stp);
-	free_generic_stateid(stp);
+	put_ol_stateid(stp);
 }
 
 static void unhash_lockowner(struct nfs4_lockowner *lo)
@@ -972,7 +974,7 @@ static void unhash_open_stateid(struct nfs4_ol_stateid *stp)
 static void release_open_stateid(struct nfs4_ol_stateid *stp)
 {
 	unhash_open_stateid(stp);
-	free_generic_stateid(stp);
+	put_ol_stateid(stp);
 }
 
 static void unhash_openowner(struct nfs4_openowner *oo)
@@ -993,7 +995,7 @@ static void release_last_closed_stateid(struct nfs4_openowner *oo)
 	struct nfs4_ol_stateid *s = oo->oo_last_closed_stid;
 
 	if (s) {
-		free_generic_stateid(s);
+		put_ol_stateid(s);
 		oo->oo_last_closed_stid = NULL;
 	}
 }
@@ -3818,7 +3820,7 @@ void nfsd4_cleanup_open_state(struct nfsd4_open *open, __be32 status)
 	if (open->op_file)
 		nfsd4_free_file(open->op_file);
 	if (open->op_stp)
-		free_generic_stateid(open->op_stp);
+		put_ol_stateid(open->op_stp);
 }
 
 __be32
@@ -4477,9 +4479,9 @@ static void nfsd4_close_open_stateid(struct nfs4_ol_stateid *s)
 	unhash_open_stateid(s);
 
 	if (clp->cl_minorversion) {
-		free_generic_stateid(s);
 		if (list_empty(&oo->oo_owner.so_stateids))
 			release_openowner(oo);
+		put_ol_stateid(s);
 	} else {
 		if (s->st_file) {
 			put_nfs4_file(s->st_file);
-- 
1.9.3

