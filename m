Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:16722 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754046Ab2KMPqd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Nov 2012 10:46:33 -0500
Subject: [PATCH 09/15] nfsd: make lockowner_ino_hashtbl allocated per net
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, devel@openvz.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, jlayton@redhat.com
Date: Tue, 13 Nov 2012 18:49:04 +0300
Message-ID: <20121113154904.12577.62685.stgit@localhost.localdomain>
In-Reply-To: <20121113154722.12577.57671.stgit@localhost.localdomain>
References: <20121113154722.12577.57671.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This hash holds file lock owners and closely associated with nfs4_clients info,
which are network namespace aware. So let's make it allocated per network
namespace too.

Note: this hash can be allocated in per-net operations. But it looks
better to allocate it on nfsd state start and thus don't waste resources
if server is not running.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfsd/netns.h     |    4 ++++
 fs/nfsd/nfs4state.c |   27 ++++++++++++++++-----------
 2 files changed, 20 insertions(+), 11 deletions(-)

diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index 70f28f1..f7a6b87 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -29,6 +29,9 @@
 #define CLIENT_HASH_SIZE                (1 << CLIENT_HASH_BITS)
 #define CLIENT_HASH_MASK                (CLIENT_HASH_SIZE - 1)
 
+#define LOCKOWNER_INO_HASH_BITS		8
+#define LOCKOWNER_INO_HASH_SIZE		(1 << LOCKOWNER_INO_HASH_BITS)
+
 struct cld_net;
 
 struct nfsd_net {
@@ -61,6 +64,7 @@ struct nfsd_net {
 	struct list_head *unconf_str_hashtbl;
 	struct list_head *unconf_id_hashtbl;
 	struct list_head *ownerstr_hashtbl;
+	struct list_head *lockowner_ino_hashtbl;
 };
 
 extern int nfsd_net_id;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 5fa1bde..ddc5a9f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3841,8 +3841,6 @@ out:
 
 #define LOFF_OVERFLOW(start, len)      ((u64)(len) > ~(u64)(start))
 
-#define LOCKOWNER_INO_HASH_BITS 8
-#define LOCKOWNER_INO_HASH_SIZE (1 << LOCKOWNER_INO_HASH_BITS)
 #define LOCKOWNER_INO_HASH_MASK (LOCKOWNER_INO_HASH_SIZE - 1)
 
 static inline u64
@@ -3872,8 +3870,6 @@ static unsigned int lockowner_ino_hashval(struct inode *inode, u32 cl_id, struct
 		& LOCKOWNER_INO_HASH_MASK;
 }
 
-static struct list_head lockowner_ino_hashtbl[LOCKOWNER_INO_HASH_SIZE];
-
 /*
  * TODO: Linux file offsets are _signed_ 64-bit quantities, which means that
  * we can't properly handle lock requests that go beyond the (2^63 - 1)-th
@@ -3939,12 +3935,12 @@ static bool same_lockowner_ino(struct nfs4_lockowner *lo, struct inode *inode, c
 
 static struct nfs4_lockowner *
 find_lockowner_str(struct inode *inode, clientid_t *clid,
-		struct xdr_netobj *owner)
+		   struct xdr_netobj *owner, struct nfsd_net *nn)
 {
 	unsigned int hashval = lockowner_ino_hashval(inode, clid->cl_id, owner);
 	struct nfs4_lockowner *lo;
 
-	list_for_each_entry(lo, &lockowner_ino_hashtbl[hashval], lo_owner_ino_hash) {
+	list_for_each_entry(lo, &nn->lockowner_ino_hashtbl[hashval], lo_owner_ino_hash) {
 		if (same_lockowner_ino(lo, inode, clid, owner))
 			return lo;
 	}
@@ -3959,7 +3955,7 @@ static void hash_lockowner(struct nfs4_lockowner *lo, unsigned int strhashval, s
 	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
 
 	list_add(&lo->lo_owner.so_strhash, &nn->ownerstr_hashtbl[strhashval]);
-	list_add(&lo->lo_owner_ino_hash, &lockowner_ino_hashtbl[inohash]);
+	list_add(&lo->lo_owner_ino_hash, &nn->lockowner_ino_hashtbl[inohash]);
 	list_add(&lo->lo_perstateid, &open_stp->st_lockowners);
 }
 
@@ -4033,8 +4029,10 @@ static __be32 lookup_or_create_lock_state(struct nfsd4_compound_state *cstate, s
 	struct nfs4_client *cl = oo->oo_owner.so_client;
 	struct nfs4_lockowner *lo;
 	unsigned int strhashval;
+	struct nfsd_net *nn = net_generic(cl->net, nfsd_net_id);
 
-	lo = find_lockowner_str(fi->fi_inode, &cl->cl_clientid, &lock->v.new.owner);
+	lo = find_lockowner_str(fi->fi_inode, &cl->cl_clientid,
+				&lock->v.new.owner, nn);
 	if (lo) {
 		if (!cstate->minorversion)
 			return nfserr_bad_seqid;
@@ -4287,7 +4285,7 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		goto out;
 	}
 
-	lo = find_lockowner_str(inode, &lockt->lt_clientid, &lockt->lt_owner);
+	lo = find_lockowner_str(inode, &lockt->lt_clientid, &lockt->lt_owner, nn);
 	if (lo)
 		file_lock->fl_owner = (fl_owner_t)lo;
 	file_lock->fl_pid = current->tgid;
@@ -4706,8 +4704,6 @@ nfs4_state_init(void)
 	for (i = 0; i < FILE_HASH_SIZE; i++) {
 		INIT_LIST_HEAD(&file_hashtbl[i]);
 	}
-	for (i = 0; i < LOCKOWNER_INO_HASH_SIZE; i++)
-		INIT_LIST_HEAD(&lockowner_ino_hashtbl[i]);
 	INIT_LIST_HEAD(&close_lru);
 	INIT_LIST_HEAD(&client_lru);
 	INIT_LIST_HEAD(&del_recall_lru);
@@ -4759,6 +4755,10 @@ static int nfs4_state_start_net(struct net *net)
 			OWNER_HASH_SIZE, GFP_KERNEL);
 	if (!nn->ownerstr_hashtbl)
 		goto err_ownerstr;
+	nn->lockowner_ino_hashtbl = kmalloc(sizeof(struct list_head) *
+			LOCKOWNER_INO_HASH_SIZE, GFP_KERNEL);
+	if (!nn->lockowner_ino_hashtbl)
+		goto err_lockowner_ino;
 
 	for (i = 0; i < CLIENT_HASH_SIZE; i++) {
 		INIT_LIST_HEAD(&nn->conf_id_hashtbl[i]);
@@ -4768,9 +4768,13 @@ static int nfs4_state_start_net(struct net *net)
 	}
 	for (i = 0; i < OWNER_HASH_SIZE; i++)
 		INIT_LIST_HEAD(&nn->ownerstr_hashtbl[i]);
+	for (i = 0; i < LOCKOWNER_INO_HASH_SIZE; i++)
+		INIT_LIST_HEAD(&nn->lockowner_ino_hashtbl[i]);
 
 	return 0;
 
+err_lockowner_ino:
+	kfree(nn->ownerstr_hashtbl);
 err_ownerstr:
 	kfree(nn->unconf_id_hashtbl);
 err_unconf_id:
@@ -4800,6 +4804,7 @@ __nfs4_state_shutdown_net(struct net *net)
 			destroy_client(clp);
 		}
 	}
+	kfree(nn->lockowner_ino_hashtbl);
 	kfree(nn->ownerstr_hashtbl);
 	kfree(nn->unconf_id_hashtbl);
 	kfree(nn->unconf_str_hashtbl);

