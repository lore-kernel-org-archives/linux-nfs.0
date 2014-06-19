Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f46.google.com ([209.85.216.46]:48851 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757947AbaFSOvP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:51:15 -0400
Received: by mail-qa0-f46.google.com with SMTP id i13so2003655qae.19
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:51:15 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 012/104] NFSd: Clean up helper __release_lock_stateid
Date: Thu, 19 Jun 2014 10:49:18 -0400
Message-Id: <1403189450-18729-13-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Use filp_close() instead of open coding

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 8b0aa9ea343d..f4c71bc96970 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -739,7 +739,8 @@ static void free_generic_stateid(struct nfs4_ol_stateid *stp)
 	nfs4_free_stid(stateid_slab, &stp->st_stid);
 }
 
-static void __release_lock_stateid(struct nfs4_ol_stateid *stp)
+static void __release_lock_stateid(struct nfs4_lockowner *lo,
+		struct nfs4_ol_stateid *stp)
 {
 	struct file *file;
 
@@ -747,10 +748,8 @@ static void __release_lock_stateid(struct nfs4_ol_stateid *stp)
 	unhash_generic_stateid(stp);
 	unhash_stid(&stp->st_stid);
 	file = find_any_file(stp->st_file);
-	if (file) {
-		locks_remove_posix(file, (fl_owner_t)lockowner(stp->st_stateowner));
-		fput(file);
-	}
+	if (file)
+		filp_close(file, (fl_owner_t)lo);
 	close_generic_stateid(stp);
 	free_generic_stateid(stp);
 }
@@ -764,7 +763,7 @@ static void unhash_lockowner(struct nfs4_lockowner *lo)
 	while (!list_empty(&lo->lo_owner.so_stateids)) {
 		stp = list_first_entry(&lo->lo_owner.so_stateids,
 				struct nfs4_ol_stateid, st_perstateowner);
-		__release_lock_stateid(stp);
+		__release_lock_stateid(lo, stp);
 	}
 }
 
@@ -791,7 +790,7 @@ static void release_lock_stateid(struct nfs4_ol_stateid *stp)
 	struct nfs4_lockowner *lo;
 
 	lo = lockowner(stp->st_stateowner);
-	__release_lock_stateid(stp);
+	__release_lock_stateid(lo, stp);
 	release_lockowner_if_empty(lo);
 }
 
-- 
1.9.3

