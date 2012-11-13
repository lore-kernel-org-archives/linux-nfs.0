Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:3031 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932078Ab2KMPqc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Nov 2012 10:46:32 -0500
Subject: [PATCH 08/15] nfsd: make ownerstr_hashtbl allocated per net
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, devel@openvz.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, jlayton@redhat.com
Date: Tue, 13 Nov 2012 18:48:59 +0300
Message-ID: <20121113154859.12577.2408.stgit@localhost.localdomain>
In-Reply-To: <20121113154722.12577.57671.stgit@localhost.localdomain>
References: <20121113154722.12577.57671.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This hash holds open owner state and closely associated with nfs4_clients
info, which are network namespace aware. So let's make it allocated per
network namespace too.

Note: this hash can be allocated in per-net operations. But it looks
better to allocate it on nfsd state start and thus don't waste resources
if server is not running.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfsd/netns.h     |    1 +
 fs/nfsd/nfs4state.c |   41 ++++++++++++++++++++++++++---------------
 2 files changed, 27 insertions(+), 15 deletions(-)

diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index ad08208..70f28f1 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -60,6 +60,7 @@ struct nfsd_net {
 	struct list_head *conf_str_hashtbl;
 	struct list_head *unconf_str_hashtbl;
 	struct list_head *unconf_id_hashtbl;
+	struct list_head *ownerstr_hashtbl;
 };
 
 extern int nfsd_net_id;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 10ee3ec..5fa1bde 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -176,8 +176,6 @@ static unsigned int ownerstr_hashval(u32 clientid, struct xdr_netobj *ownername)
 	return ret & OWNER_HASH_MASK;
 }
 
-static struct list_head	ownerstr_hashtbl[OWNER_HASH_SIZE];
-
 /* hash table for nfs4_file */
 #define FILE_HASH_BITS                   8
 #define FILE_HASH_SIZE                  (1 << FILE_HASH_BITS)
@@ -2407,7 +2405,9 @@ static inline void *alloc_stateowner(struct kmem_cache *slab, struct xdr_netobj
 
 static void hash_openowner(struct nfs4_openowner *oo, struct nfs4_client *clp, unsigned int strhashval)
 {
-	list_add(&oo->oo_owner.so_strhash, &ownerstr_hashtbl[strhashval]);
+	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
+
+	list_add(&oo->oo_owner.so_strhash, &nn->ownerstr_hashtbl[strhashval]);
 	list_add(&oo->oo_perclient, &clp->cl_openowners);
 }
 
@@ -2465,13 +2465,14 @@ same_owner_str(struct nfs4_stateowner *sop, struct xdr_netobj *owner,
 }
 
 static struct nfs4_openowner *
-find_openstateowner_str(unsigned int hashval, struct nfsd4_open *open, bool sessions)
+find_openstateowner_str(unsigned int hashval, struct nfsd4_open *open,
+			bool sessions, struct nfsd_net *nn)
 {
 	struct nfs4_stateowner *so;
 	struct nfs4_openowner *oo;
 	struct nfs4_client *clp;
 
-	list_for_each_entry(so, &ownerstr_hashtbl[hashval], so_strhash) {
+	list_for_each_entry(so, &nn->ownerstr_hashtbl[hashval], so_strhash) {
 		if (!so->so_is_open_owner)
 			continue;
 		if (same_owner_str(so, &open->op_owner, &open->op_clientid)) {
@@ -2627,7 +2628,7 @@ nfsd4_process_open1(struct nfsd4_compound_state *cstate,
 		return nfserr_jukebox;
 
 	strhashval = ownerstr_hashval(clientid->cl_id, &open->op_owner);
-	oo = find_openstateowner_str(strhashval, open, cstate->minorversion);
+	oo = find_openstateowner_str(strhashval, open, cstate->minorversion, nn);
 	open->op_openowner = oo;
 	if (!oo) {
 		clp = find_confirmed_client(clientid, cstate->minorversion,
@@ -3955,8 +3956,9 @@ static void hash_lockowner(struct nfs4_lockowner *lo, unsigned int strhashval, s
 	struct inode *inode = open_stp->st_file->fi_inode;
 	unsigned int inohash = lockowner_ino_hashval(inode,
 			clp->cl_clientid.cl_id, &lo->lo_owner.so_owner);
+	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
 
-	list_add(&lo->lo_owner.so_strhash, &ownerstr_hashtbl[strhashval]);
+	list_add(&lo->lo_owner.so_strhash, &nn->ownerstr_hashtbl[strhashval]);
 	list_add(&lo->lo_owner_ino_hash, &lockowner_ino_hashtbl[inohash]);
 	list_add(&lo->lo_perstateid, &open_stp->st_lockowners);
 }
@@ -4437,7 +4439,7 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
 	status = nfserr_locks_held;
 	INIT_LIST_HEAD(&matches);
 
-	list_for_each_entry(sop, &ownerstr_hashtbl[hashval], so_strhash) {
+	list_for_each_entry(sop, &nn->ownerstr_hashtbl[hashval], so_strhash) {
 		if (sop->so_is_open_owner)
 			continue;
 		if (!same_owner_str(sop, owner, clid))
@@ -4594,13 +4596,14 @@ static void release_openowner_sop(struct nfs4_stateowner *sop)
 }
 
 static int nfsd_release_n_owners(u64 num, bool is_open_owner,
-				void (*release_sop)(struct nfs4_stateowner *))
+				void (*release_sop)(struct nfs4_stateowner *),
+				struct nfsd_net *nn)
 {
 	int i, count = 0;
 	struct nfs4_stateowner *sop, *next;
 
 	for (i = 0; i < OWNER_HASH_SIZE; i++) {
-		list_for_each_entry_safe(sop, next, &ownerstr_hashtbl[i], so_strhash) {
+		list_for_each_entry_safe(sop, next, &nn->ownerstr_hashtbl[i], so_strhash) {
 			if (sop->so_is_open_owner != is_open_owner)
 				continue;
 			release_sop(sop);
@@ -4614,9 +4617,10 @@ static int nfsd_release_n_owners(u64 num, bool is_open_owner,
 void nfsd_forget_locks(u64 num)
 {
 	int count;
+	struct nfsd_net *nn = net_generic(&init_net, nfsd_net_id);
 
 	nfs4_lock_state();
-	count = nfsd_release_n_owners(num, false, release_lockowner_sop);
+	count = nfsd_release_n_owners(num, false, release_lockowner_sop, nn);
 	nfs4_unlock_state();
 
 	printk(KERN_INFO "NFSD: Forgot %d locks", count);
@@ -4625,9 +4629,10 @@ void nfsd_forget_locks(u64 num)
 void nfsd_forget_openowners(u64 num)
 {
 	int count;
+	struct nfsd_net *nn = net_generic(&init_net, nfsd_net_id);
 
 	nfs4_lock_state();
-	count = nfsd_release_n_owners(num, true, release_openowner_sop);
+	count = nfsd_release_n_owners(num, true, release_openowner_sop, nn);
 	nfs4_unlock_state();
 
 	printk(KERN_INFO "NFSD: Forgot %d open owners", count);
@@ -4701,9 +4706,6 @@ nfs4_state_init(void)
 	for (i = 0; i < FILE_HASH_SIZE; i++) {
 		INIT_LIST_HEAD(&file_hashtbl[i]);
 	}
-	for (i = 0; i < OWNER_HASH_SIZE; i++) {
-		INIT_LIST_HEAD(&ownerstr_hashtbl[i]);
-	}
 	for (i = 0; i < LOCKOWNER_INO_HASH_SIZE; i++)
 		INIT_LIST_HEAD(&lockowner_ino_hashtbl[i]);
 	INIT_LIST_HEAD(&close_lru);
@@ -4753,6 +4755,10 @@ static int nfs4_state_start_net(struct net *net)
 			CLIENT_HASH_SIZE, GFP_KERNEL);
 	if (!nn->unconf_id_hashtbl)
 		goto err_unconf_id;
+	nn->ownerstr_hashtbl = kmalloc(sizeof(struct list_head) *
+			OWNER_HASH_SIZE, GFP_KERNEL);
+	if (!nn->ownerstr_hashtbl)
+		goto err_ownerstr;
 
 	for (i = 0; i < CLIENT_HASH_SIZE; i++) {
 		INIT_LIST_HEAD(&nn->conf_id_hashtbl[i]);
@@ -4760,9 +4766,13 @@ static int nfs4_state_start_net(struct net *net)
 		INIT_LIST_HEAD(&nn->unconf_str_hashtbl[i]);
 		INIT_LIST_HEAD(&nn->unconf_id_hashtbl[i]);
 	}
+	for (i = 0; i < OWNER_HASH_SIZE; i++)
+		INIT_LIST_HEAD(&nn->ownerstr_hashtbl[i]);
 
 	return 0;
 
+err_ownerstr:
+	kfree(nn->unconf_id_hashtbl);
 err_unconf_id:
 	kfree(nn->unconf_str_hashtbl);
 err_unconf_str:
@@ -4790,6 +4800,7 @@ __nfs4_state_shutdown_net(struct net *net)
 			destroy_client(clp);
 		}
 	}
+	kfree(nn->ownerstr_hashtbl);
 	kfree(nn->unconf_id_hashtbl);
 	kfree(nn->unconf_str_hashtbl);
 	kfree(nn->conf_str_hashtbl);

