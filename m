Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f174.google.com ([209.85.216.174]:51249 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757959AbaFSOvi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:51:38 -0400
Received: by mail-qc0-f174.google.com with SMTP id x13so2232214qcv.19
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:51:37 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 028/104] nfsd: do filp_close in sc_free callback for lock stateids
Date: Thu, 19 Jun 2014 10:49:34 -0400
Message-Id: <1403189450-18729-29-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It seems wrong to release the locks on each put of the stateid, instead
of doing so only when the stateid is actually released, and doing so
complicates some later changes.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index b0e22d1ea6df..99995d2537c3 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -777,6 +777,18 @@ static void nfs4_free_generic_stateid(struct nfs4_stid *stid)
 	nfs4_free_stid(stateid_slab, stid);
 }
 
+static void nfs4_free_lock_stateid(struct nfs4_stid *stid)
+{
+	struct nfs4_ol_stateid *stp = openlockstateid(stid);
+	struct nfs4_lockowner *lo = lockowner(stp->st_stateowner);
+	struct file *file;
+
+	file = find_any_file(stp->st_stid.sc_file);
+	if (file)
+		filp_close(file, (fl_owner_t)lo);
+	nfs4_free_generic_stateid(stid);
+}
+
 static void put_generic_stateid(struct nfs4_ol_stateid *stp)
 {
 	nfs4_put_stid(&stp->st_stid);
@@ -785,14 +797,9 @@ static void put_generic_stateid(struct nfs4_ol_stateid *stp)
 static void __release_lock_stateid(struct nfs4_lockowner *lo,
 		struct nfs4_ol_stateid *stp)
 {
-	struct file *file;
-
 	list_del(&stp->st_locks);
 	unhash_generic_stateid(stp);
 	unhash_stid(&stp->st_stid);
-	file = find_any_file(stp->st_stid.sc_file);
-	if (file)
-		filp_close(file, (fl_owner_t)lo);
 	put_generic_stateid(stp);
 }
 
@@ -4548,6 +4555,7 @@ alloc_init_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp, struct
 	stp->st_stateowner = &lo->lo_owner;
 	get_nfs4_file(fp);
 	stp->st_stid.sc_file = fp;
+	stp->st_stid.sc_free = nfs4_free_lock_stateid;
 	stp->st_access_bmap = 0;
 	stp->st_deny_bmap = open_stp->st_deny_bmap;
 	stp->st_openstp = open_stp;
-- 
1.9.3

