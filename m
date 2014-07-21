Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f51.google.com ([209.85.216.51]:40276 "EHLO
	mail-qa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932489AbaGUPD5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jul 2014 11:03:57 -0400
Received: by mail-qa0-f51.google.com with SMTP id k15so5133244qaq.24
        for <linux-nfs@vger.kernel.org>; Mon, 21 Jul 2014 08:03:56 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: [PATCH 40/40] nfsd: don't thrash the cl_lock while freeing an open stateid
Date: Mon, 21 Jul 2014 11:02:52 -0400
Message-Id: <1405954972-28904-41-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1405954972-28904-1-git-send-email-jlayton@primarydata.com>
References: <1405954972-28904-1-git-send-email-jlayton@primarydata.com>
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
index 918c09b45843..21bd52714c09 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1038,27 +1038,26 @@ static void release_lockowner(struct nfs4_lockowner *lo)
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
+		put_generic_stateid_locked(stp, reaplist);
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
@@ -1066,7 +1065,7 @@ static void release_open_stateid(struct nfs4_ol_stateid *stp)
 	LIST_HEAD(reaplist);
 
 	spin_lock(&stp->st_stid.sc_client->cl_lock);
-	unhash_open_stateid(stp);
+	unhash_open_stateid(stp, &reaplist);
 	put_generic_stateid_locked(stp, &reaplist);
 	spin_unlock(&stp->st_stid.sc_client->cl_lock);
 	free_ol_stateid_reaplist(&reaplist);
@@ -1106,7 +1105,7 @@ static void release_openowner(struct nfs4_openowner *oo)
 	while (!list_empty(&oo->oo_owner.so_stateids)) {
 		stp = list_first_entry(&oo->oo_owner.so_stateids,
 				struct nfs4_ol_stateid, st_perstateowner);
-		unhash_open_stateid(stp);
+		unhash_open_stateid(stp, &reaplist);
 		put_generic_stateid_locked(stp, &reaplist);
 	}
 	spin_unlock(&clp->cl_lock);
@@ -4717,16 +4716,21 @@ out:
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
-		put_generic_stateid(s);
-	else
+	if (clp->cl_minorversion) {
+		put_generic_stateid_locked(s, &reaplist);
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

