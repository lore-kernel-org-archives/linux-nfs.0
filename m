Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f172.google.com ([209.85.223.172]:39452 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752956AbaDRSpd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Apr 2014 14:45:33 -0400
Received: by mail-ie0-f172.google.com with SMTP id as1so1903311iec.17
        for <linux-nfs@vger.kernel.org>; Fri, 18 Apr 2014 11:45:32 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 18/70] NFSd: Clean up helper __release_lock_stateid
Date: Fri, 18 Apr 2014 14:44:12 -0400
Message-Id: <1397846704-14567-19-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1397846704-14567-18-git-send-email-trond.myklebust@primarydata.com>
References: <1397846704-14567-1-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-2-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-3-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-4-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-5-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-6-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-7-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-8-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-9-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-10-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-11-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-12-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-13-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-14-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-15-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-16-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-17-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-18-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use filp_close() instead of open coding

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 8a12d59c8f36..0809e8355577 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -704,7 +704,8 @@ static void free_generic_stateid(struct nfs4_ol_stateid *stp)
 	nfs4_free_stid(stateid_slab, &stp->st_stid);
 }
 
-static void __release_lock_stateid(struct nfs4_ol_stateid *stp)
+static void __release_lock_stateid(struct nfs4_lockowner *lo,
+		struct nfs4_ol_stateid *stp)
 {
 	struct file *file;
 
@@ -712,10 +713,8 @@ static void __release_lock_stateid(struct nfs4_ol_stateid *stp)
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
@@ -729,7 +728,7 @@ static void unhash_lockowner(struct nfs4_lockowner *lo)
 	while (!list_empty(&lo->lo_owner.so_stateids)) {
 		stp = list_first_entry(&lo->lo_owner.so_stateids,
 				struct nfs4_ol_stateid, st_perstateowner);
-		__release_lock_stateid(stp);
+		__release_lock_stateid(lo, stp);
 	}
 }
 
@@ -756,7 +755,7 @@ static void release_lock_stateid(struct nfs4_ol_stateid *stp)
 	struct nfs4_lockowner *lo;
 
 	lo = lockowner(stp->st_stateowner);
-	__release_lock_stateid(stp);
+	__release_lock_stateid(lo, stp);
 	release_lockowner_if_empty(lo);
 }
 
-- 
1.9.0

