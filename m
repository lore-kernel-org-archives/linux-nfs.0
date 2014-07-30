Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f42.google.com ([209.85.216.42]:40659 "EHLO
	mail-qa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754652AbaG3Bfq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jul 2014 21:35:46 -0400
Received: by mail-qa0-f42.google.com with SMTP id j15so600842qaq.1
        for <linux-nfs@vger.kernel.org>; Tue, 29 Jul 2014 18:35:45 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: [PATCH v3 37/38] nfsd: don't thrash the cl_lock while freeing an open stateid
Date: Tue, 29 Jul 2014 21:34:42 -0400
Message-Id: <1406684083-19736-38-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406684083-19736-1-git-send-email-jlayton@primarydata.com>
References: <1406684083-19736-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When we remove the client_mutex, we'll have a potential race between
FREE_STATEID and CLOSE.

The root of the problem is that we are walking the st_locks list,
dropping the spinlock and then trying to release the persistent
reference to the lockstateid. In between, a FREE_STATEID call can come
along and take the lock, find the stateid and then try to put the
reference. That leads to a double put.

Fix this by not releasing the cl_lock in order to release each lock
stateid. Use put_generic_stateid_locked to unhash them and gather them
onto a list, and free_ol_stateid_reaplist to free any that end up on the
list.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 34 +++++++++++++++++++---------------
 1 file changed, 19 insertions(+), 15 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 879342bc16b2..1f67a96c4941 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1077,27 +1077,26 @@ static void release_lockowner(struct nfs4_lockowner *lo)
 	nfs4_put_stateowner(&lo->lo_owner);
 }
 
-static void release_open_stateid_locks(struct nfs4_ol_stateid *open_stp)
-	__releases(&open_stp->st_stateowner->so_client->cl_lock)
-	__acquires(&open_stp->st_stateowner->so_client->cl_lock)
+static void release_open_stateid_locks(struct nfs4_ol_stateid *open_stp,
+				       struct list_head *reaplist)
 {
 	struct nfs4_ol_stateid *stp;
 
 	while (!list_empty(&open_stp->st_locks)) {
 		stp = list_entry(open_stp->st_locks.next,
 				struct nfs4_ol_stateid, st_locks);
-		spin_unlock(&open_stp->st_stateowner->so_client->cl_lock);
-		release_lock_stateid(stp);
-		spin_lock(&open_stp->st_stateowner->so_client->cl_lock);
+		unhash_lock_stateid(stp);
+		put_ol_stateid_locked(stp, reaplist);
 	}
 }
 
-static void unhash_open_stateid(struct nfs4_ol_stateid *stp)
+static void unhash_open_stateid(struct nfs4_ol_stateid *stp,
+				struct list_head *reaplist)
 {
 	lockdep_assert_held(&stp->st_stid.sc_client->cl_lock);
 
 	unhash_generic_stateid(stp);
-	release_open_stateid_locks(stp);
+	release_open_stateid_locks(stp, reaplist);
 }
 
 static void release_open_stateid(struct nfs4_ol_stateid *stp)
@@ -1105,7 +1104,7 @@ static void release_open_stateid(struct nfs4_ol_stateid *stp)
 	LIST_HEAD(reaplist);
 
 	spin_lock(&stp->st_stid.sc_client->cl_lock);
-	unhash_open_stateid(stp);
+	unhash_open_stateid(stp, &reaplist);
 	put_ol_stateid_locked(stp, &reaplist);
 	spin_unlock(&stp->st_stid.sc_client->cl_lock);
 	free_ol_stateid_reaplist(&reaplist);
@@ -1145,7 +1144,7 @@ static void release_openowner(struct nfs4_openowner *oo)
 	while (!list_empty(&oo->oo_owner.so_stateids)) {
 		stp = list_first_entry(&oo->oo_owner.so_stateids,
 				struct nfs4_ol_stateid, st_perstateowner);
-		unhash_open_stateid(stp);
+		unhash_open_stateid(stp, &reaplist);
 		put_ol_stateid_locked(stp, &reaplist);
 	}
 	spin_unlock(&clp->cl_lock);
@@ -4701,16 +4700,21 @@ out:
 static void nfsd4_close_open_stateid(struct nfs4_ol_stateid *s)
 {
 	struct nfs4_client *clp = s->st_stid.sc_client;
+	LIST_HEAD(reaplist);
 
 	s->st_stid.sc_type = NFS4_CLOSED_STID;
 	spin_lock(&clp->cl_lock);
-	unhash_open_stateid(s);
-	spin_unlock(&clp->cl_lock);
+	unhash_open_stateid(s, &reaplist);
 
-	if (clp->cl_minorversion)
-		nfs4_put_stid(&s->st_stid);
-	else
+	if (clp->cl_minorversion) {
+		put_ol_stateid_locked(s, &reaplist);
+		spin_unlock(&clp->cl_lock);
+		free_ol_stateid_reaplist(&reaplist);
+	} else {
+		spin_unlock(&clp->cl_lock);
+		free_ol_stateid_reaplist(&reaplist);
 		move_to_close_lru(s, clp->net);
+	}
 }
 
 /*
-- 
1.9.3

