From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH] nfsd4: remove a forward declaration
Date: Sun, 11 Jan 2009 18:52:28 -0500
Message-ID: <1231717949-31908-3-git-send-email-bfields@citi.umich.edu>
References: <1231717949-31908-1-git-send-email-bfields@citi.umich.edu>
 <1231717949-31908-2-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:45574 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752083AbZAKXwb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 11 Jan 2009 18:52:31 -0500
In-Reply-To: <1231717949-31908-2-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4state.c |   85 +++++++++++++++++++++++++--------------------------
 1 files changed, 42 insertions(+), 43 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 6b8e5a9..298d6ce 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -75,7 +75,6 @@ static stateid_t onestateid;              /* bits all 1 */
 /* forward declarations */
 static struct nfs4_stateid * find_stateid(stateid_t *stid, int flags);
 static struct nfs4_delegation * find_delegation_stateid(struct inode *ino, stateid_t *stid);
-static void release_stateid_lockowners(struct nfs4_stateid *open_stp);
 static char user_recovery_dirname[PATH_MAX] = "/var/lib/nfs/v4recovery";
 static void nfs4_set_recdir(char *recdir);
 
@@ -325,6 +324,20 @@ static void release_lock_stateid(struct nfs4_stateid *stp)
 	release_generic_stateid(stp);
 }
 
+static void
+release_stateid_lockowners(struct nfs4_stateid *open_stp)
+{
+	struct nfs4_stateowner *lock_sop;
+
+	while (!list_empty(&open_stp->st_lockowners)) {
+		lock_sop = list_entry(open_stp->st_lockowners.next,
+				struct nfs4_stateowner, so_perstateid);
+		/* list_del(&open_stp->st_lockowners);  */
+		BUG_ON(lock_sop->so_is_open_owner);
+		release_stateowner(lock_sop);
+	}
+}
+
 static void release_open_stateid(struct nfs4_stateid *stp)
 {
 	release_stateid_lockowners(stp);
@@ -332,6 +345,34 @@ static void release_open_stateid(struct nfs4_stateid *stp)
 	release_generic_stateid(stp);
 }
 
+static void
+unhash_stateowner(struct nfs4_stateowner *sop)
+{
+	struct nfs4_stateid *stp;
+
+	list_del(&sop->so_idhash);
+	list_del(&sop->so_strhash);
+	if (sop->so_is_open_owner)
+		list_del(&sop->so_perclient);
+	list_del(&sop->so_perstateid);
+	while (!list_empty(&sop->so_stateids)) {
+		stp = list_entry(sop->so_stateids.next,
+			struct nfs4_stateid, st_perstateowner);
+		if (sop->so_is_open_owner)
+			release_open_stateid(stp);
+		else
+			release_lock_stateid(stp);
+	}
+}
+
+static void
+release_stateowner(struct nfs4_stateowner *sop)
+{
+	unhash_stateowner(sop);
+	list_del(&sop->so_close_lru);
+	nfs4_put_stateowner(sop);
+}
+
 static inline void
 renew_client(struct nfs4_client *clp)
 {
@@ -1058,48 +1099,6 @@ alloc_init_open_stateowner(unsigned int strhashval, struct nfs4_client *clp, str
 	return sop;
 }
 
-static void
-release_stateid_lockowners(struct nfs4_stateid *open_stp)
-{
-	struct nfs4_stateowner *lock_sop;
-
-	while (!list_empty(&open_stp->st_lockowners)) {
-		lock_sop = list_entry(open_stp->st_lockowners.next,
-				struct nfs4_stateowner, so_perstateid);
-		/* list_del(&open_stp->st_lockowners);  */
-		BUG_ON(lock_sop->so_is_open_owner);
-		release_stateowner(lock_sop);
-	}
-}
-
-static void
-unhash_stateowner(struct nfs4_stateowner *sop)
-{
-	struct nfs4_stateid *stp;
-
-	list_del(&sop->so_idhash);
-	list_del(&sop->so_strhash);
-	if (sop->so_is_open_owner)
-		list_del(&sop->so_perclient);
-	list_del(&sop->so_perstateid);
-	while (!list_empty(&sop->so_stateids)) {
-		stp = list_entry(sop->so_stateids.next,
-			struct nfs4_stateid, st_perstateowner);
-		if (sop->so_is_open_owner)
-			release_open_stateid(stp);
-		else
-			release_lock_stateid(stp);
-	}
-}
-
-static void
-release_stateowner(struct nfs4_stateowner *sop)
-{
-	unhash_stateowner(sop);
-	list_del(&sop->so_close_lru);
-	nfs4_put_stateowner(sop);
-}
-
 static inline void
 init_stateid(struct nfs4_stateid *stp, struct nfs4_file *fp, struct nfsd4_open *open) {
 	struct nfs4_stateowner *sop = open->op_stateowner;
-- 
1.5.5.rc1

