Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f43.google.com ([209.85.216.43]:61733 "EHLO
	mail-qa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757787AbaFSOws (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:52:48 -0400
Received: by mail-qa0-f43.google.com with SMTP id k15so2049733qaq.16
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:52:47 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 076/104] nfsd: protect the close_lru list and oo_last_closed_stid with client_lock
Date: Thu, 19 Jun 2014 10:50:22 -0400
Message-Id: <1403189450-18729-77-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 33 +++++++++++++++++++++++++++------
 1 file changed, 27 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 72ca1b62cf16..561c77a02920 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -917,13 +917,19 @@ static void unhash_openowner_locked(struct nfs4_openowner *oo)
 
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
-		put_generic_stateid(s);
 	}
+	spin_unlock(&nn->client_lock);
+	if (s)
+		put_generic_stateid(s);
 }
 
 static void release_openowner(struct nfs4_openowner *oo)
@@ -3098,6 +3104,7 @@ static void init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp,
 static void
 move_to_close_lru(struct nfs4_ol_stateid *s, struct net *net)
 {
+	struct nfs4_ol_stateid *last;
 	struct nfs4_openowner *oo = openowner(s->st_stateowner);
 	struct nfsd_net *nn = net_generic(s->st_stid.sc_client->net,
 						nfsd_net_id);
@@ -3121,10 +3128,14 @@ move_to_close_lru(struct nfs4_ol_stateid *s, struct net *net)
 		s->st_stid.sc_file = NULL;
 	}
 
-	release_last_closed_stateid(oo);
+	spin_lock(&nn->client_lock);
+	last = oo->oo_last_closed_stid;
 	oo->oo_last_closed_stid = s;
 	list_move_tail(&oo->oo_close_lru, &nn->close_lru);
 	oo->oo_time = get_seconds();
+	spin_unlock(&nn->client_lock);
+	if (last)
+		put_generic_stateid(last);
 }
 
 static int
@@ -3970,6 +3981,7 @@ nfs4_laundromat(struct nfsd_net *nn)
 	struct nfs4_client *clp;
 	struct nfs4_openowner *oo;
 	struct nfs4_delegation *dp;
+	struct nfs4_ol_stateid *stp;
 	struct list_head *pos, *next, reaplist;
 	time_t cutoff = get_seconds() - nn->nfsd4_lease;
 	time_t t, new_timeo = nn->nfsd4_lease;
@@ -4021,15 +4033,24 @@ nfs4_laundromat(struct nfsd_net *nn)
 		dp = list_entry (pos, struct nfs4_delegation, dl_recall_lru);
 		revoke_delegation(dp);
 	}
-	list_for_each_safe(pos, next, &nn->close_lru) {
-		oo = container_of(pos, struct nfs4_openowner, oo_close_lru);
+
+	spin_lock(&nn->client_lock);
+	while (!list_empty(&nn->close_lru)) {
+		oo = list_first_entry(&nn->close_lru, struct nfs4_openowner, oo_close_lru);
 		if (time_after((unsigned long)oo->oo_time, (unsigned long)cutoff)) {
 			t = oo->oo_time - cutoff;
 			new_timeo = min(new_timeo, t);
 			break;
 		}
-		release_last_closed_stateid(oo);
+		list_del_init(&oo->oo_close_lru);
+		stp = oo->oo_last_closed_stid;
+		oo->oo_last_closed_stid = NULL;
+		spin_unlock(&nn->client_lock);
+		put_generic_stateid(stp);
+		spin_lock(&nn->client_lock);
 	}
+	spin_unlock(&nn->client_lock);
+
 	new_timeo = max_t(time_t, new_timeo, NFSD_LAUNDROMAT_MINTIMEOUT);
 	nfs4_unlock_state();
 	return new_timeo;
-- 
1.9.3

