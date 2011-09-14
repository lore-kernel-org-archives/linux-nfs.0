Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60190 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932250Ab1INLp3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Sep 2011 07:45:29 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 21/25] nfsd4: share common stid-hashing helper function
Date: Wed, 14 Sep 2011 07:45:17 -0400
Message-Id: <1316000721-3289-22-git-send-email-bfields@redhat.com>
In-Reply-To: <1316000721-3289-1-git-send-email-bfields@redhat.com>
References: <1316000721-3289-1-git-send-email-bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   15 +++++++++++----
 1 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 3e3d605..581a5d0 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -218,6 +218,15 @@ static void nfs4_file_put_access(struct nfs4_file *fp, int oflag)
 		__nfs4_file_put_access(fp, oflag);
 }
 
+static inline void hash_stid(struct nfs4_stid *stid)
+{
+	stateid_t *s = &stid->sc_stateid;
+	unsigned int hashval;
+
+	hashval = stateid_hashval(s->si_stateownerid, s->si_fileid);
+	list_add(&stid->sc_hash, &stateid_hashtbl[hashval]);
+}
+
 static struct nfs4_delegation *
 alloc_init_deleg(struct nfs4_client *clp, struct nfs4_ol_stateid *stp, struct svc_fh *current_fh, u32 type)
 {
@@ -2316,10 +2325,8 @@ alloc_init_open_stateowner(unsigned int strhashval, struct nfs4_client *clp, str
 static inline void
 init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp, struct nfsd4_open *open) {
 	struct nfs4_openowner *oo = open->op_openowner;
-	unsigned int hashval = stateid_hashval(oo->oo_owner.so_id, fp->fi_id);
 
 	INIT_LIST_HEAD(&stp->st_lockowners);
-	list_add(&stp->st_stid.sc_hash, &stateid_hashtbl[hashval]);
 	list_add(&stp->st_perstateowner, &oo->oo_owner.so_stateids);
 	list_add(&stp->st_perfile, &fp->fi_stateids);
 	stp->st_stid.sc_type = NFS4_OPEN_STID;
@@ -2331,6 +2338,7 @@ init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp, struct nfsd
 	stp->st_stid.sc_stateid.si_fileid = fp->fi_id;
 	/* note will be incremented before first return to client: */
 	stp->st_stid.sc_stateid.si_generation = 0;
+	hash_stid(&stp->st_stid);
 	stp->st_access_bmap = 0;
 	stp->st_deny_bmap = 0;
 	__set_bit(open->op_share_access & ~NFS4_SHARE_WANT_MASK,
@@ -3866,12 +3874,10 @@ static struct nfs4_ol_stateid *
 alloc_init_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp, struct nfs4_ol_stateid *open_stp)
 {
 	struct nfs4_ol_stateid *stp;
-	unsigned int hashval = stateid_hashval(lo->lo_owner.so_id, fp->fi_id);
 
 	stp = nfs4_alloc_stateid();
 	if (stp == NULL)
 		goto out;
-	list_add(&stp->st_stid.sc_hash, &stateid_hashtbl[hashval]);
 	list_add(&stp->st_perfile, &fp->fi_stateids);
 	list_add(&stp->st_perstateowner, &lo->lo_owner.so_stateids);
 	stp->st_stateowner = &lo->lo_owner;
@@ -3883,6 +3889,7 @@ alloc_init_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp, struct
 	stp->st_stid.sc_stateid.si_fileid = fp->fi_id;
 	/* note will be incremented before first return to client: */
 	stp->st_stid.sc_stateid.si_generation = 0;
+	hash_stid(&stp->st_stid);
 	stp->st_access_bmap = 0;
 	stp->st_deny_bmap = open_stp->st_deny_bmap;
 	stp->st_openstp = open_stp;
-- 
1.7.4.1

