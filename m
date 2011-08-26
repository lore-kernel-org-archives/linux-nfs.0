Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53235 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752222Ab1HZW2m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Aug 2011 18:28:42 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 05/15] nfsd4: name openowner data structures more clearly
Date: Fri, 26 Aug 2011 18:28:26 -0400
Message-Id: <1314397716-18602-6-git-send-email-bfields@redhat.com>
In-Reply-To: <1314397716-18602-1-git-send-email-bfields@redhat.com>
References: <1314397716-18602-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

These appear to be generic (for both open and lock owners), but they're
actually just for open owners.  This has confused me more than once.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   36 ++++++++++++++++++------------------
 1 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index a98dc75..d32a1a6 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -136,27 +136,27 @@ unsigned int max_delegations;
  * Open owner state (share locks)
  */
 
-/* hash tables for nfs4_stateowner */
-#define OWNER_HASH_BITS              8
-#define OWNER_HASH_SIZE             (1 << OWNER_HASH_BITS)
-#define OWNER_HASH_MASK             (OWNER_HASH_SIZE - 1)
+/* hash tables for open owners */
+#define OPEN_OWNER_HASH_BITS              8
+#define OPEN_OWNER_HASH_SIZE             (1 << OPEN_OWNER_HASH_BITS)
+#define OPEN_OWNER_HASH_MASK             (OPEN_OWNER_HASH_SIZE - 1)
 
-static unsigned int ownerid_hashval(const u32 id)
+static unsigned int open_ownerid_hashval(const u32 id)
 {
-	return id & OWNER_HASH_MASK;
+	return id & OPEN_OWNER_HASH_MASK;
 }
 
-static unsigned int ownerstr_hashval(u32 clientid, struct xdr_netobj *ownername)
+static unsigned int open_ownerstr_hashval(u32 clientid, struct xdr_netobj *ownername)
 {
 	unsigned int ret;
 
 	ret = opaque_hashval(ownername->data, ownername->len);
 	ret += clientid;
-	return ret & OWNER_HASH_MASK;
+	return ret & OPEN_OWNER_HASH_MASK;
 }
 
-static struct list_head	ownerid_hashtbl[OWNER_HASH_SIZE];
-static struct list_head	ownerstr_hashtbl[OWNER_HASH_SIZE];
+static struct list_head	open_ownerid_hashtbl[OPEN_OWNER_HASH_SIZE];
+static struct list_head	open_ownerstr_hashtbl[OPEN_OWNER_HASH_SIZE];
 
 /* hash table for nfs4_file */
 #define FILE_HASH_BITS                   8
@@ -2242,7 +2242,7 @@ alloc_init_open_stateowner(unsigned int strhashval, struct nfs4_client *clp, str
 
 	if (!(sop = alloc_stateowner(&open->op_owner)))
 		return NULL;
-	idhashval = ownerid_hashval(current_ownerid);
+	idhashval = open_ownerid_hashval(current_ownerid);
 	INIT_LIST_HEAD(&sop->so_idhash);
 	INIT_LIST_HEAD(&sop->so_strhash);
 	INIT_LIST_HEAD(&sop->so_perclient);
@@ -2250,8 +2250,8 @@ alloc_init_open_stateowner(unsigned int strhashval, struct nfs4_client *clp, str
 	INIT_LIST_HEAD(&sop->so_perstateid);  /* not used */
 	INIT_LIST_HEAD(&sop->so_close_lru);
 	sop->so_time = 0;
-	list_add(&sop->so_idhash, &ownerid_hashtbl[idhashval]);
-	list_add(&sop->so_strhash, &ownerstr_hashtbl[strhashval]);
+	list_add(&sop->so_idhash, &open_ownerid_hashtbl[idhashval]);
+	list_add(&sop->so_strhash, &open_ownerstr_hashtbl[strhashval]);
 	list_add(&sop->so_perclient, &clp->cl_openowners);
 	sop->so_is_open_owner = 1;
 	sop->so_id = current_ownerid++;
@@ -2315,7 +2315,7 @@ find_openstateowner_str(unsigned int hashval, struct nfsd4_open *open)
 {
 	struct nfs4_stateowner *so = NULL;
 
-	list_for_each_entry(so, &ownerstr_hashtbl[hashval], so_strhash) {
+	list_for_each_entry(so, &open_ownerstr_hashtbl[hashval], so_strhash) {
 		if (same_owner_str(so, &open->op_owner, &open->op_clientid))
 			return so;
 	}
@@ -2466,7 +2466,7 @@ nfsd4_process_open1(struct nfsd4_compound_state *cstate,
 	if (STALE_CLIENTID(&open->op_clientid))
 		return nfserr_stale_clientid;
 
-	strhashval = ownerstr_hashval(clientid->cl_id, &open->op_owner);
+	strhashval = open_ownerstr_hashval(clientid->cl_id, &open->op_owner);
 	sop = find_openstateowner_str(strhashval, open);
 	open->op_stateowner = sop;
 	if (!sop) {
@@ -4520,9 +4520,9 @@ nfs4_state_init(void)
 	for (i = 0; i < FILE_HASH_SIZE; i++) {
 		INIT_LIST_HEAD(&file_hashtbl[i]);
 	}
-	for (i = 0; i < OWNER_HASH_SIZE; i++) {
-		INIT_LIST_HEAD(&ownerstr_hashtbl[i]);
-		INIT_LIST_HEAD(&ownerid_hashtbl[i]);
+	for (i = 0; i < OPEN_OWNER_HASH_SIZE; i++) {
+		INIT_LIST_HEAD(&open_ownerstr_hashtbl[i]);
+		INIT_LIST_HEAD(&open_ownerid_hashtbl[i]);
 	}
 	for (i = 0; i < STATEID_HASH_SIZE; i++) {
 		INIT_LIST_HEAD(&stateid_hashtbl[i]);
-- 
1.7.4.1

