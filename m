Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53233 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752198Ab1HZW2m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Aug 2011 18:28:42 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 04/15] nfsd4: replace some macros by functions
Date: Fri, 26 Aug 2011 18:28:25 -0400
Message-Id: <1314397716-18602-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1314397716-18602-1-git-send-email-bfields@redhat.com>
References: <1314397716-18602-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

For all the usual reasons.  (Type safety, readability.)

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   53 ++++++++++++++++++++++++++++++++++++--------------
 1 files changed, 38 insertions(+), 15 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 08b8413..a98dc75 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -141,10 +141,19 @@ unsigned int max_delegations;
 #define OWNER_HASH_SIZE             (1 << OWNER_HASH_BITS)
 #define OWNER_HASH_MASK             (OWNER_HASH_SIZE - 1)
 
-#define ownerid_hashval(id) \
-        ((id) & OWNER_HASH_MASK)
-#define ownerstr_hashval(clientid, ownername) \
-        (((clientid) + opaque_hashval((ownername.data), (ownername.len))) & OWNER_HASH_MASK)
+static unsigned int ownerid_hashval(const u32 id)
+{
+	return id & OWNER_HASH_MASK;
+}
+
+static unsigned int ownerstr_hashval(u32 clientid, struct xdr_netobj *ownername)
+{
+	unsigned int ret;
+
+	ret = opaque_hashval(ownername->data, ownername->len);
+	ret += clientid;
+	return ret & OWNER_HASH_MASK;
+}
 
 static struct list_head	ownerid_hashtbl[OWNER_HASH_SIZE];
 static struct list_head	ownerstr_hashtbl[OWNER_HASH_SIZE];
@@ -158,10 +167,16 @@ static struct list_head	ownerstr_hashtbl[OWNER_HASH_SIZE];
 #define STATEID_HASH_SIZE              (1 << STATEID_HASH_BITS)
 #define STATEID_HASH_MASK              (STATEID_HASH_SIZE - 1)
 
-#define file_hashval(x) \
-        hash_ptr(x, FILE_HASH_BITS)
-#define stateid_hashval(owner_id, file_id)  \
-        (((owner_id) + (file_id)) & STATEID_HASH_MASK)
+static unsigned int file_hashval(struct inode *ino)
+{
+	/* XXX: why are we hashing on inode pointer, anyway? */
+	return hash_ptr(ino, FILE_HASH_BITS);
+}
+
+static unsigned int stateid_hashval(u32 owner_id, u32 file_id)
+{
+	return (owner_id + file_id) & STATEID_HASH_MASK;
+}
 
 static struct list_head file_hashtbl[FILE_HASH_SIZE];
 static struct list_head stateid_hashtbl[STATEID_HASH_SIZE];
@@ -292,10 +307,16 @@ static DEFINE_SPINLOCK(client_lock);
 #define CLIENT_HASH_SIZE                (1 << CLIENT_HASH_BITS)
 #define CLIENT_HASH_MASK                (CLIENT_HASH_SIZE - 1)
 
-#define clientid_hashval(id) \
-	((id) & CLIENT_HASH_MASK)
-#define clientstr_hashval(name) \
-	(opaque_hashval((name), 8) & CLIENT_HASH_MASK)
+static unsigned int clientid_hashval(u32 id)
+{
+	return id & CLIENT_HASH_MASK;
+}
+
+static unsigned int clientstr_hashval(const char *name)
+{
+	return opaque_hashval(name, 8) & CLIENT_HASH_MASK;
+}
+
 /*
  * reclaim_str_hashtbl[] holds known client info from previous reset/reboot
  * used in reboot/reset lease grace period processing
@@ -2445,7 +2466,7 @@ nfsd4_process_open1(struct nfsd4_compound_state *cstate,
 	if (STALE_CLIENTID(&open->op_clientid))
 		return nfserr_stale_clientid;
 
-	strhashval = ownerstr_hashval(clientid->cl_id, open->op_owner);
+	strhashval = ownerstr_hashval(clientid->cl_id, &open->op_owner);
 	sop = find_openstateowner_str(strhashval, open);
 	open->op_stateowner = sop;
 	if (!sop) {
@@ -3713,8 +3734,10 @@ last_byte_offset(u64 start, u64 len)
 	return end > start ? end - 1: NFS4_MAX_UINT64;
 }
 
-#define lockownerid_hashval(id) \
-        ((id) & LOCK_HASH_MASK)
+static unsigned int lockownerid_hashval(u32 id)
+{
+	return id & LOCK_HASH_MASK;
+}
 
 static inline unsigned int
 lock_ownerstr_hashval(struct inode *inode, u32 cl_id,
-- 
1.7.4.1

