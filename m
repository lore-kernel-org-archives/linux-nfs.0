Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f53.google.com ([209.85.216.53]:40220 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753244AbaG3M17 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jul 2014 08:27:59 -0400
Received: by mail-qa0-f53.google.com with SMTP id v10so1146676qac.40
        for <linux-nfs@vger.kernel.org>; Wed, 30 Jul 2014 05:27:58 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: [PATCH 10/37] nfsd: protect the close_lru list and oo_last_closed_stid with client_lock
Date: Wed, 30 Jul 2014 08:27:11 -0400
Message-Id: <1406723258-8512-11-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406723258-8512-1-git-send-email-jlayton@primarydata.com>
References: <1406723258-8512-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, it's protected by the client_mutex. Move it so that the list
and the fields in the openowner are protected by the client_lock.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 38 +++++++++++++++++++++++++++++++-------
 1 file changed, 31 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e7dfd4e9d942..818480035453 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1122,13 +1122,19 @@ static void unhash_openowner_locked(struct nfs4_openowner *oo)
 
 static void release_last_closed_stateid(struct nfs4_openowner *oo)
 {
-	struct nfs4_ol_stateid *s = oo->oo_last_closed_stid;
+	struct nfsd_net *nn = net_generic(oo->oo_owner.so_client->net,
+					  nfsd_net_id);
+	struct nfs4_ol_stateid *s;
 
+	spin_lock(&nn->client_lock);
+	s = oo->oo_last_closed_stid;
 	if (s) {
 		list_del_init(&oo->oo_close_lru);
 		oo->oo_last_closed_stid = NULL;
-		nfs4_put_stid(&s->st_stid);
 	}
+	spin_unlock(&nn->client_lock);
+	if (s)
+		nfs4_put_stid(&s->st_stid);
 }
 
 static void release_openowner(struct nfs4_openowner *oo)
@@ -3265,6 +3271,7 @@ static void init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp,
 static void
 move_to_close_lru(struct nfs4_ol_stateid *s, struct net *net)
 {
+	struct nfs4_ol_stateid *last;
 	struct nfs4_openowner *oo = openowner(s->st_stateowner);
 	struct nfsd_net *nn = net_generic(s->st_stid.sc_client->net,
 						nfsd_net_id);
@@ -3287,10 +3294,15 @@ move_to_close_lru(struct nfs4_ol_stateid *s, struct net *net)
 		put_nfs4_file(s->st_stid.sc_file);
 		s->st_stid.sc_file = NULL;
 	}
-	release_last_closed_stateid(oo);
+
+	spin_lock(&nn->client_lock);
+	last = oo->oo_last_closed_stid;
 	oo->oo_last_closed_stid = s;
 	list_move_tail(&oo->oo_close_lru, &nn->close_lru);
 	oo->oo_time = get_seconds();
+	spin_unlock(&nn->client_lock);
+	if (last)
+		nfs4_put_stid(&last->st_stid);
 }
 
 /* search file_hashtbl[] for file */
@@ -4148,6 +4160,7 @@ nfs4_laundromat(struct nfsd_net *nn)
 	struct nfs4_client *clp;
 	struct nfs4_openowner *oo;
 	struct nfs4_delegation *dp;
+	struct nfs4_ol_stateid *stp;
 	struct list_head *pos, *next, reaplist;
 	time_t cutoff = get_seconds() - nn->nfsd4_lease;
 	time_t t, new_timeo = nn->nfsd4_lease;
@@ -4201,15 +4214,26 @@ nfs4_laundromat(struct nfsd_net *nn)
 		list_del_init(&dp->dl_recall_lru);
 		revoke_delegation(dp);
 	}
-	list_for_each_safe(pos, next, &nn->close_lru) {
-		oo = container_of(pos, struct nfs4_openowner, oo_close_lru);
-		if (time_after((unsigned long)oo->oo_time, (unsigned long)cutoff)) {
+
+	spin_lock(&nn->client_lock);
+	while (!list_empty(&nn->close_lru)) {
+		oo = list_first_entry(&nn->close_lru, struct nfs4_openowner,
+					oo_close_lru);
+		if (time_after((unsigned long)oo->oo_time,
+			       (unsigned long)cutoff)) {
 			t = oo->oo_time - cutoff;
 			new_timeo = min(new_timeo, t);
 			break;
 		}
-		release_last_closed_stateid(oo);
+		list_del_init(&oo->oo_close_lru);
+		stp = oo->oo_last_closed_stid;
+		oo->oo_last_closed_stid = NULL;
+		spin_unlock(&nn->client_lock);
+		nfs4_put_stid(&stp->st_stid);
+		spin_lock(&nn->client_lock);
 	}
+	spin_unlock(&nn->client_lock);
+
 	new_timeo = max_t(time_t, new_timeo, NFSD_LAUNDROMAT_MINTIMEOUT);
 	nfs4_unlock_state();
 	return new_timeo;
-- 
1.9.3

