Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:43466 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964843Ab2KNPSw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Nov 2012 10:18:52 -0500
Subject: [PATCH v2 04/15] nfsd: make conf_id_hashtbl allocated per net
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, devel@openvz.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, jlayton@redhat.com
Date: Wed, 14 Nov 2012 18:21:21 +0300
Message-ID: <20121114152121.4708.60730.stgit@localhost.localdomain>
In-Reply-To: <20121114152018.4708.63125.stgit@localhost.localdomain>
References: <20121114152018.4708.63125.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This hash holds nfs4_clients info, which are network namespace aware.
So let's make it allocated per network namespace.

Note: this hash can be allocated in per-net operations. But it looks
better to allocate it on nfsd state start and thus don't waste resources
if server is not running.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfsd/netns.h     |    1 +
 fs/nfsd/nfs4state.c |   75 +++++++++++++++++++++++++++++++++++++--------------
 2 files changed, 55 insertions(+), 21 deletions(-)

diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index 49e5479..0cc85e9 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -50,6 +50,7 @@ struct nfsd_net {
 	 */
 	struct list_head *reclaim_str_hashtbl;
 	int reclaim_str_hashtbl_size;
+	struct list_head *conf_id_hashtbl;
 };
 
 extern int nfsd_net_id;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 58b4870..7b02c47 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -418,7 +418,6 @@ static unsigned int clientstr_hashval(const char *name)
  *
  * All of the above fields are protected by the client_mutex.
  */
-static struct list_head	conf_id_hashtbl[CLIENT_HASH_SIZE];
 static struct list_head	unconf_id_hashtbl[CLIENT_HASH_SIZE];
 static struct rb_root conf_name_tree;
 static struct rb_root unconf_name_tree;
@@ -1385,9 +1384,10 @@ static void
 move_to_confirmed(struct nfs4_client *clp)
 {
 	unsigned int idhashval = clientid_hashval(clp->cl_clientid.cl_id);
+	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
 
 	dprintk("NFSD: move_to_confirm nfs4_client %p\n", clp);
-	list_move(&clp->cl_idhash, &conf_id_hashtbl[idhashval]);
+	list_move(&clp->cl_idhash, &nn->conf_id_hashtbl[idhashval]);
 	rb_erase(&clp->cl_namenode, &unconf_name_tree);
 	add_clp_to_name_tree(clp, &conf_name_tree);
 	set_bit(NFSD4_CLIENT_CONFIRMED, &clp->cl_flags);
@@ -1395,12 +1395,12 @@ move_to_confirmed(struct nfs4_client *clp)
 }
 
 static struct nfs4_client *
-find_confirmed_client(clientid_t *clid, bool sessions)
+find_confirmed_client(clientid_t *clid, bool sessions, struct nfsd_net *nn)
 {
 	struct nfs4_client *clp;
 	unsigned int idhashval = clientid_hashval(clid->cl_id);
 
-	list_for_each_entry(clp, &conf_id_hashtbl[idhashval], cl_idhash) {
+	list_for_each_entry(clp, &nn->conf_id_hashtbl[idhashval], cl_idhash) {
 		if (same_clid(&clp->cl_clientid, clid)) {
 			if ((bool)clp->cl_minorversion != sessions)
 				return NULL;
@@ -1787,6 +1787,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 	struct nfsd4_conn *conn;
 	struct nfsd4_clid_slot *cs_slot = NULL;
 	__be32 status = 0;
+	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
 
 	if (cr_ses->flags & ~SESSION4_FLAG_MASK_A)
 		return nfserr_inval;
@@ -1802,7 +1803,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 
 	nfs4_lock_state();
 	unconf = find_unconfirmed_client(&cr_ses->clientid, true);
-	conf = find_confirmed_client(&cr_ses->clientid, true);
+	conf = find_confirmed_client(&cr_ses->clientid, true, nn);
 
 	if (conf) {
 		cs_slot = &conf->cl_cs_slot;
@@ -2142,10 +2143,11 @@ nfsd4_destroy_clientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *csta
 {
 	struct nfs4_client *conf, *unconf, *clp;
 	__be32 status = 0;
+	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
 
 	nfs4_lock_state();
 	unconf = find_unconfirmed_client(&dc->clientid, true);
-	conf = find_confirmed_client(&dc->clientid, true);
+	conf = find_confirmed_client(&dc->clientid, true, nn);
 
 	if (conf) {
 		clp = conf;
@@ -2280,7 +2282,7 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 		return nfserr_stale_clientid;
 	nfs4_lock_state();
 
-	conf = find_confirmed_client(clid, false);
+	conf = find_confirmed_client(clid, false, nn);
 	unconf = find_unconfirmed_client(clid, false);
 	/*
 	 * We try hard to give out unique clientid's, so if we get an
@@ -2656,7 +2658,8 @@ nfsd4_process_open1(struct nfsd4_compound_state *cstate,
 	oo = find_openstateowner_str(strhashval, open, cstate->minorversion);
 	open->op_openowner = oo;
 	if (!oo) {
-		clp = find_confirmed_client(clientid, cstate->minorversion);
+		clp = find_confirmed_client(clientid, cstate->minorversion,
+					    nn);
 		if (clp == NULL)
 			return nfserr_expired;
 		goto new_owner;
@@ -3152,7 +3155,7 @@ nfsd4_renew(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	status = nfserr_stale_clientid;
 	if (STALE_CLIENTID(clid, nn))
 		goto out;
-	clp = find_confirmed_client(clid, cstate->minorversion);
+	clp = find_confirmed_client(clid, cstate->minorversion, nn);
 	status = nfserr_expired;
 	if (clp == NULL) {
 		/* We assume the client took too long to RENEW. */
@@ -3428,7 +3431,7 @@ static __be32 nfsd4_lookup_stateid(stateid_t *stateid, unsigned char typemask, s
 		return nfserr_bad_stateid;
 	if (STALE_STATEID(stateid, nn))
 		return nfserr_stale_stateid;
-	cl = find_confirmed_client(&stateid->si_opaque.so_clid, sessions);
+	cl = find_confirmed_client(&stateid->si_opaque.so_clid, sessions, nn);
 	if (!cl)
 		return nfserr_expired;
 	*s = find_stateid_by_type(cl, stateid, typemask);
@@ -4579,9 +4582,10 @@ __be32
 nfs4_check_open_reclaim(clientid_t *clid, bool sessions)
 {
 	struct nfs4_client *clp;
+	struct nfsd_net *nn = net_generic(&init_net, nfsd_net_id);
 
 	/* find clientid in conf_id_hashtbl */
-	clp = find_confirmed_client(clid, sessions);
+	clp = find_confirmed_client(clid, sessions, nn);
 	if (clp == NULL)
 		return nfserr_reclaim_bad;
 
@@ -4720,7 +4724,6 @@ nfs4_state_init(void)
 	int i;
 
 	for (i = 0; i < CLIENT_HASH_SIZE; i++) {
-		INIT_LIST_HEAD(&conf_id_hashtbl[i]);
 		INIT_LIST_HEAD(&unconf_id_hashtbl[i]);
 	}
 	conf_name_tree = RB_ROOT;
@@ -4761,6 +4764,38 @@ set_max_delegations(void)
 	max_delegations = nr_free_buffer_pages() >> (20 - 2 - PAGE_SHIFT);
 }
 
+static int nfs4_state_start_net(struct net *net)
+{
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
+	int i;
+
+	nn->conf_id_hashtbl = kmalloc(sizeof(struct list_head) *
+			CLIENT_HASH_SIZE, GFP_KERNEL);
+	if (!nn->conf_id_hashtbl)
+		return -ENOMEM;
+
+	for (i = 0; i < CLIENT_HASH_SIZE; i++)
+		INIT_LIST_HEAD(&nn->conf_id_hashtbl[i]);
+
+	return 0;
+}
+
+static void
+__nfs4_state_shutdown_net(struct net *net)
+{
+	int i;
+	struct nfs4_client *clp = NULL;
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
+
+	for (i = 0; i < CLIENT_HASH_SIZE; i++) {
+		while (!list_empty(&nn->conf_id_hashtbl[i])) {
+			clp = list_entry(nn->conf_id_hashtbl[i].next, struct nfs4_client, cl_idhash);
+			destroy_client(clp);
+		}
+	}
+	kfree(nn->conf_id_hashtbl);
+}
+
 /* initialization to perform when the nfsd service is started: */
 
 int
@@ -4778,6 +4813,9 @@ nfs4_state_start(void)
 	 * basis.
 	 */
 	get_net(net);
+	ret = nfs4_state_start_net(net);
+	if (ret)
+		return ret;
 	nfsd4_client_tracking_init(net);
 	nn->boot_time = get_seconds();
 	locks_start_grace(net, &nn->nfsd4_manager);
@@ -4804,26 +4842,21 @@ out_free_laundry:
 	destroy_workqueue(laundry_wq);
 out_recovery:
 	nfsd4_client_tracking_exit(net);
+	__nfs4_state_shutdown_net(net);
 	put_net(net);
 	return ret;
 }
 
 /* should be called with the state lock held */
 static void
-__nfs4_state_shutdown(void)
+__nfs4_state_shutdown(struct net *net)
 {
-	int i;
 	struct nfs4_client *clp = NULL;
 	struct nfs4_delegation *dp = NULL;
 	struct list_head *pos, *next, reaplist;
 	struct rb_node *node, *tmp;
 
-	for (i = 0; i < CLIENT_HASH_SIZE; i++) {
-		while (!list_empty(&conf_id_hashtbl[i])) {
-			clp = list_entry(conf_id_hashtbl[i].next, struct nfs4_client, cl_idhash);
-			destroy_client(clp);
-		}
-	}
+	__nfs4_state_shutdown_net(net);
 
 	node = rb_first(&unconf_name_tree);
 	while (node != NULL) {
@@ -4860,7 +4893,7 @@ nfs4_state_shutdown(void)
 	destroy_workqueue(laundry_wq);
 	locks_end_grace(&nn->nfsd4_manager);
 	nfs4_lock_state();
-	__nfs4_state_shutdown();
+	__nfs4_state_shutdown(net);
 	nfs4_unlock_state();
 	nfsd4_destroy_callback_queue();
 }

