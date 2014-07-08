Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f45.google.com ([209.85.192.45]:52814 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754460AbaGHSFQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jul 2014 14:05:16 -0400
Received: by mail-qg0-f45.google.com with SMTP id a108so5326421qge.32
        for <linux-nfs@vger.kernel.org>; Tue, 08 Jul 2014 11:05:15 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 029/100] nfsd: do filp_close in sc_free callback for lock stateids
Date: Tue,  8 Jul 2014 14:03:17 -0400
Message-Id: <1404842668-22521-30-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Releasing locks when we unhash the stateid instead of doing so only when
the stateid is actually released is problematic and will complicate some
later changes.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 947cd157ee82..e3ca5bcd1c3f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -914,6 +914,18 @@ static void nfs4_free_generic_stateid(struct nfs4_stid *stid)
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
@@ -921,14 +933,9 @@ static void put_generic_stateid(struct nfs4_ol_stateid *stp)
 
 static void __release_lock_stateid(struct nfs4_ol_stateid *stp)
 {
-	struct file *file;
-
 	list_del(&stp->st_locks);
 	unhash_generic_stateid(stp);
 	unhash_stid(&stp->st_stid);
-	file = find_any_file(stp->st_stid.sc_file);
-	if (file)
-		filp_close(file, (fl_owner_t)lockowner(stp->st_stateowner));
 	put_generic_stateid(stp);
 }
 
@@ -4687,6 +4694,7 @@ alloc_init_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp, struct
 	stp->st_stateowner = &lo->lo_owner;
 	get_nfs4_file(fp);
 	stp->st_stid.sc_file = fp;
+	stp->st_stid.sc_free = nfs4_free_lock_stateid;
 	stp->st_access_bmap = 0;
 	stp->st_deny_bmap = open_stp->st_deny_bmap;
 	stp->st_openstp = open_stp;
-- 
1.9.3

