Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53641 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753015Ab0LGAJc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Dec 2010 19:09:32 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/3] nfsd4: replace unintuitive match_clientid_establishment
Date: Mon,  6 Dec 2010 19:09:24 -0500
Message-Id: <1291680566-13980-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1291680566-13980-1-git-send-email-bfields@redhat.com>
References: <1291680566-13980-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   14 ++++----------
 1 files changed, 4 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index afa7525..febb283 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1135,19 +1135,13 @@ find_unconfirmed_client(clientid_t *clid)
 }
 
 /*
- * Return 1 iff clp's clientid establishment method matches the use_exchange_id
- * parameter. Matching is based on the fact the at least one of the
- * EXCHGID4_FLAG_USE_{NON_PNFS,PNFS_MDS,PNFS_DS} flags must be set for v4.1
- *
  * FIXME: we need to unify the clientid namespaces for nfsv4.x
  * and correctly deal with client upgrade/downgrade in EXCHANGE_ID
  * and SET_CLIENTID{,_CONFIRM}
  */
-static inline int
-match_clientid_establishment(struct nfs4_client *clp, bool use_exchange_id)
+static bool clp_used_exchangeid(struct nfs4_client *clp)
 {
-	bool has_exchange_flags = (clp->cl_exchange_flags != 0);
-	return use_exchange_id == has_exchange_flags;
+	return clp->cl_exchange_flags != 0;
 }
 
 static struct nfs4_client *
@@ -1158,7 +1152,7 @@ find_confirmed_client_by_str(const char *dname, unsigned int hashval,
 
 	list_for_each_entry(clp, &conf_str_hashtbl[hashval], cl_strhash) {
 		if (same_name(clp->cl_recdir, dname) &&
-		    match_clientid_establishment(clp, use_exchange_id))
+		    clp_used_exchangeid(clp) == use_exchange_id)
 			return clp;
 	}
 	return NULL;
@@ -1172,7 +1166,7 @@ find_unconfirmed_client_by_str(const char *dname, unsigned int hashval,
 
 	list_for_each_entry(clp, &unconf_str_hashtbl[hashval], cl_strhash) {
 		if (same_name(clp->cl_recdir, dname) &&
-		    match_clientid_establishment(clp, use_exchange_id))
+		    clp_used_exchangeid(clp) == use_exchange_id)
 			return clp;
 	}
 	return NULL;
-- 
1.7.1

