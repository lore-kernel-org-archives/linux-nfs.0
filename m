Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f49.google.com ([209.85.216.49]:39899 "EHLO
	mail-qa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758066AbaFSOwP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:52:15 -0400
Received: by mail-qa0-f49.google.com with SMTP id w8so2017769qac.22
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:52:14 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 053/104] nfsd: make openstateids hold references to their openowners
Date: Thu, 19 Jun 2014 10:49:59 -0400
Message-Id: <1403189450-18729-54-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Change it so that only openstateids hold persistent references to
openowners. References can still be held by compounds in progress.

With this, we can get rid of NFS4_OO_NEW. It's possible that we
will create a new openowner in the process of doing the open, but
something later fails. In the meantime, another task could find
that openowner and start using it on a successful open. If that
occurs we don't necessarily want to tear it down, just put the
reference.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 71 +++++++++++++++++++++++------------------------------
 fs/nfsd/state.h     |  1 -
 2 files changed, 31 insertions(+), 41 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 28bfffbafb0c..46629846fd7d 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -782,7 +782,7 @@ static void nfs4_free_generic_stateid(struct nfs4_stid *stid)
 	struct nfs4_ol_stateid *stp = openlockstateid(stid);
 
 	release_all_access(stp);
-	if (stp->st_stateowner && stid->sc_type == NFS4_LOCK_STID)
+	if (stp->st_stateowner)
 		nfs4_put_stateowner(stp->st_stateowner);
 	nfs4_free_stid(stateid_slab, stid);
 }
@@ -879,8 +879,9 @@ static void release_last_closed_stateid(struct nfs4_openowner *oo)
 	struct nfs4_ol_stateid *s = oo->oo_last_closed_stid;
 
 	if (s) {
-		put_generic_stateid(s);
+		list_del_init(&oo->oo_close_lru);
 		oo->oo_last_closed_stid = NULL;
+		put_generic_stateid(s);
 	}
 }
 
@@ -899,7 +900,6 @@ static void release_openowner(struct nfs4_openowner *oo)
 {
 	unhash_openowner(oo);
 	release_openowner_stateids(oo);
-	list_del(&oo->oo_close_lru);
 	release_last_closed_stateid(oo);
 	nfs4_put_stateowner(&oo->oo_owner);
 }
@@ -1372,6 +1372,7 @@ destroy_client(struct nfs4_client *clp)
 	}
 	while (!list_empty(&clp->cl_openowners)) {
 		oo = list_entry(clp->cl_openowners.next, struct nfs4_openowner, oo_perclient);
+		atomic_inc(&oo->oo_owner.so_count);
 		release_openowner(oo);
 	}
 	nfsd4_shutdown_callback(clp);
@@ -2915,7 +2916,7 @@ alloc_init_open_stateowner(unsigned int strhashval, struct nfs4_client *clp,
 	oo->oo_owner.so_unhash = nfs4_unhash_openowner;
 	oo->oo_owner.so_is_open_owner = 1;
 	oo->oo_owner.so_seqid = open->op_seqid;
-	oo->oo_flags = NFS4_OO_NEW;
+	oo->oo_flags = 0;
 	if (nfsd4_has_session(cstate))
 		oo->oo_flags |= NFS4_OO_CONFIRMED;
 	oo->oo_time = 0;
@@ -2932,6 +2933,7 @@ static void init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp,
 	stp->st_stid.sc_type = NFS4_OPEN_STID;
 	INIT_LIST_HEAD(&stp->st_locks);
 	stp->st_stateowner = &oo->oo_owner;
+	atomic_inc(&stp->st_stateowner->so_count);
 	get_nfs4_file(fp);
 	stp->st_stid.sc_file = fp;
 	stp->st_access_bmap = 0;
@@ -2947,13 +2949,27 @@ static void init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp,
 	spin_unlock(&oo->oo_owner.so_client->cl_lock);
 }
 
+/*
+ * In the 4.0 case we need to keep the owners around a little while to handle
+ * CLOSE replay. We still do need to release any file access that is held by
+ * them before returning however.
+ */
 static void
-move_to_close_lru(struct nfs4_openowner *oo, struct net *net)
+move_to_close_lru(struct nfs4_ol_stateid *s, struct net *net)
 {
-	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
+	struct nfs4_openowner *oo = openowner(s->st_stateowner);
+	struct nfsd_net *nn = net_generic(s->st_stid.sc_client->net,
+						nfsd_net_id);
 
 	dprintk("NFSD: move_to_close_lru nfs4_openowner %p\n", oo);
 
+	release_all_access(s);
+	if (s->st_stid.sc_file) {
+		put_nfs4_file(s->st_stid.sc_file);
+		s->st_stid.sc_file = NULL;
+	}
+	release_last_closed_stateid(oo);
+	oo->oo_last_closed_stid = s;
 	list_move_tail(&oo->oo_close_lru, &nn->close_lru);
 	oo->oo_time = get_seconds();
 }
@@ -2984,6 +3000,7 @@ find_openstateowner_str(unsigned int hashval, struct nfsd4_open *open,
 			if ((bool)clp->cl_minorversion != sessions)
 				return NULL;
 			renew_client(oo->oo_owner.so_client);
+			atomic_inc(&oo->oo_owner.so_count);
 			return oo;
 		}
 	}
@@ -3705,19 +3722,10 @@ void nfsd4_cleanup_open_state(struct nfsd4_compound_state *cstate,
 			      struct nfsd4_open *open, __be32 status)
 {
 	if (open->op_openowner) {
-		struct nfs4_openowner *oo = open->op_openowner;
-
-		if (!list_empty(&oo->oo_owner.so_stateids))
-			list_del_init(&oo->oo_close_lru);
-		if (oo->oo_flags & NFS4_OO_NEW) {
-			if (status) {
-				release_openowner(oo);
-				open->op_openowner = NULL;
-			} else
-				oo->oo_flags &= ~NFS4_OO_NEW;
-		}
-		if (open->op_openowner)
-			nfsd4_cstate_assign_replay(cstate, &oo->oo_owner);
+		struct nfs4_stateowner *so = &open->op_openowner->oo_owner;
+
+		nfsd4_cstate_assign_replay(cstate, so);
+		nfs4_put_stateowner(so);
 	}
 	if (open->op_file)
 		nfsd4_free_file(open->op_file);
@@ -3842,7 +3850,7 @@ nfs4_laundromat(struct nfsd_net *nn)
 			new_timeo = min(new_timeo, t);
 			break;
 		}
-		release_openowner(oo);
+		release_last_closed_stateid(oo);
 	}
 	new_timeo = max_t(time_t, new_timeo, NFSD_LAUNDROMAT_MINTIMEOUT);
 	nfs4_unlock_state();
@@ -4435,31 +4443,14 @@ out:
 static void nfsd4_close_open_stateid(struct nfs4_ol_stateid *s)
 {
 	struct nfs4_client *clp = s->st_stid.sc_client;
-	struct nfs4_openowner *oo = openowner(s->st_stateowner);
 
 	s->st_stid.sc_type = NFS4_CLOSED_STID;
 	unhash_open_stateid(s);
 
-	if (clp->cl_minorversion) {
-		if (list_empty(&oo->oo_owner.so_stateids))
-			release_openowner(oo);
+	if (clp->cl_minorversion)
 		put_generic_stateid(s);
-	} else {
-		if (s->st_stid.sc_file) {
-			put_nfs4_file(s->st_stid.sc_file);
-			s->st_stid.sc_file = NULL;
-		}
-		oo->oo_last_closed_stid = s;
-		/*
-		 * In the 4.0 case we need to keep the owners around a
-		 * little while to handle CLOSE replay. We still do need
-		 * to release any file access that is held by them
-		 * before returning however.
-		 */
-		release_all_access(s);
-		if (list_empty(&oo->oo_owner.so_stateids))
-			move_to_close_lru(oo, clp->net);
-	}
+	else
+		move_to_close_lru(s, clp->net);
 }
 
 /*
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 00f2951423cc..fd87df9f66ed 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -364,7 +364,6 @@ struct nfs4_openowner {
 	struct nfs4_ol_stateid *oo_last_closed_stid;
 	time_t			oo_time; /* time of placement on so_close_lru */
 #define NFS4_OO_CONFIRMED   1
-#define NFS4_OO_NEW         4
 	unsigned char		oo_flags;
 };
 
-- 
1.9.3

