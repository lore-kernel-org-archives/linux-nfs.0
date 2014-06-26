Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f182.google.com ([209.85.216.182]:59125 "EHLO
	mail-qc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751327AbaFZTVh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2014 15:21:37 -0400
Received: by mail-qc0-f182.google.com with SMTP id m20so3614527qcx.13
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jun 2014 12:21:36 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v2 088/117] nfsd: Add lockdep assertions to document the nfs4_client/session locking
Date: Thu, 26 Jun 2014 15:20:56 -0400
Message-Id: <1403810485-16497-5-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 30 ++++++++++++++++++++++++++++++
 1 file changed, 30 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e81c97435f7f..f49def48464d 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -146,6 +146,10 @@ static __be32 mark_client_expired_locked(struct nfs4_client *clp)
 
 static __be32 get_client_locked(struct nfs4_client *clp)
 {
+	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
+
+	lockdep_assert_held(&nn->client_lock);
+
 	if (is_client_expired(clp))
 		return nfserr_expired;
 	atomic_inc(&clp->cl_refcount);
@@ -186,6 +190,10 @@ renew_client(struct nfs4_client *clp)
 
 static void put_client_renew_locked(struct nfs4_client *clp)
 {
+	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
+
+	lockdep_assert_held(&nn->client_lock);
+
 	if (!atomic_dec_and_test(&clp->cl_refcount))
 		return;
 	if (!is_client_expired(clp))
@@ -217,6 +225,9 @@ static __be32 nfsd4_get_session_locked(struct nfsd4_session *ses)
 static void nfsd4_put_session_locked(struct nfsd4_session *ses)
 {
 	struct nfs4_client *clp = ses->se_client;
+	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
+
+	lockdep_assert_held(&nn->client_lock);
 
 	if (atomic_dec_and_test(&ses->se_ref) && is_session_dead(ses))
 		free_session(ses);
@@ -1399,6 +1410,8 @@ __find_in_sessionid_hashtbl(struct nfs4_sessionid *sessionid, struct net *net)
 	int idx;
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
+	lockdep_assert_held(&nn->client_lock);
+
 	dump_sessionid(__func__, sessionid);
 	idx = hash_sessionid(sessionid);
 	/* Search in the appropriate list */
@@ -1435,6 +1448,11 @@ out:
 static void
 unhash_session(struct nfsd4_session *ses)
 {
+	struct nfs4_client *clp = ses->se_client;
+	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
+
+	lockdep_assert_held(&nn->client_lock);
+
 	list_del(&ses->se_hash);
 	spin_lock(&ses->se_client->cl_lock);
 	list_del(&ses->se_perclnt);
@@ -1523,6 +1541,8 @@ unhash_client_locked(struct nfs4_client *clp)
 	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
 	struct nfsd4_session *ses;
 
+	lockdep_assert_held(&nn->client_lock);
+
 	/* Mark the client as expired! */
 	clp->cl_time = 0;
 	/* Make it invisible */
@@ -1852,6 +1872,8 @@ add_to_unconfirmed(struct nfs4_client *clp)
 	unsigned int idhashval;
 	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
 
+	lockdep_assert_held(&nn->client_lock);
+
 	clear_bit(NFSD4_CLIENT_CONFIRMED, &clp->cl_flags);
 	add_clp_to_name_tree(clp, &nn->unconf_name_tree);
 	idhashval = clientid_hashval(clp->cl_clientid.cl_id);
@@ -1865,6 +1887,8 @@ move_to_confirmed(struct nfs4_client *clp)
 	unsigned int idhashval = clientid_hashval(clp->cl_clientid.cl_id);
 	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
 
+	lockdep_assert_held(&nn->client_lock);
+
 	dprintk("NFSD: move_to_confirm nfs4_client %p\n", clp);
 	list_move(&clp->cl_idhash, &nn->conf_id_hashtbl[idhashval]);
 	rb_erase(&clp->cl_namenode, &nn->unconf_name_tree);
@@ -1895,6 +1919,7 @@ find_confirmed_client(clientid_t *clid, bool sessions, struct nfsd_net *nn)
 {
 	struct list_head *tbl = nn->conf_id_hashtbl;
 
+	lockdep_assert_held(&nn->client_lock);
 	return find_client_in_id_table(tbl, clid, sessions);
 }
 
@@ -1903,6 +1928,7 @@ find_unconfirmed_client(clientid_t *clid, bool sessions, struct nfsd_net *nn)
 {
 	struct list_head *tbl = nn->unconf_id_hashtbl;
 
+	lockdep_assert_held(&nn->client_lock);
 	return find_client_in_id_table(tbl, clid, sessions);
 }
 
@@ -1914,12 +1940,14 @@ static bool clp_used_exchangeid(struct nfs4_client *clp)
 static struct nfs4_client *
 find_confirmed_client_by_name(struct xdr_netobj *name, struct nfsd_net *nn)
 {
+	lockdep_assert_held(&nn->client_lock);
 	return find_clp_in_name_tree(name, &nn->conf_name_tree);
 }
 
 static struct nfs4_client *
 find_unconfirmed_client_by_name(struct xdr_netobj *name, struct nfsd_net *nn)
 {
+	lockdep_assert_held(&nn->client_lock);
 	return find_clp_in_name_tree(name, &nn->unconf_name_tree);
 }
 
@@ -4874,6 +4902,8 @@ find_lockowner_str_locked(clientid_t *clid, struct xdr_netobj *owner,
 	unsigned int strhashval = ownerstr_hashval(owner);
 	struct nfs4_stateowner *so;
 
+	lockdep_assert_held(&clp->cl_lock);
+
 	list_for_each_entry(so, &clp->cl_ownerstr_hashtbl[strhashval],
 			    so_strhash) {
 		if (so->so_is_open_owner)
-- 
1.9.3

