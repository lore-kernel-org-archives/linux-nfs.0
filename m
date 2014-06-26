Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f52.google.com ([209.85.216.52]:64705 "EHLO
	mail-qa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751511AbaFZTOp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2014 15:14:45 -0400
Received: by mail-qa0-f52.google.com with SMTP id w8so3165337qac.39
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jun 2014 12:14:44 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v2 043/117] nfsd: Ensure stateids remain unique until they are freed
Date: Thu, 26 Jun 2014 15:12:23 -0400
Message-Id: <1403810017-16062-44-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Add an extra delegation state to allow the stateid to remain in the idr
tree until the last reference has been released. This will be necessary
to ensure uniqueness once the client_mutex is removed.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 8 +++++---
 fs/nfsd/state.h     | 1 +
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index a02a5892f839..2aa21a263510 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -640,6 +640,7 @@ static void remove_stid(struct nfs4_stid *s)
 
 static void nfs4_free_stid(struct kmem_cache *slab, struct nfs4_stid *s)
 {
+	remove_stid(s);
 	if (s->sc_file)
 		put_nfs4_file(s->sc_file);
 	kmem_cache_free(slab, s);
@@ -710,7 +711,7 @@ unhash_delegation(struct nfs4_delegation *dp)
 
 static void destroy_delegation(struct nfs4_delegation *dp)
 {
-	remove_stid(&dp->dl_stid);
+	dp->dl_stid.sc_type = NFS4_CLOSED_DELEG_STID;
 	nfs4_put_delegation(dp);
 }
 
@@ -723,7 +724,7 @@ static void unhash_and_destroy_delegation(struct nfs4_delegation *dp)
 static void destroy_revoked_delegation(struct nfs4_delegation *dp)
 {
 	list_del_init(&dp->dl_recall_lru);
-	destroy_delegation(dp);
+	nfs4_put_delegation(dp);
 }
 
 static void revoke_delegation(struct nfs4_delegation *dp)
@@ -876,7 +877,6 @@ static void put_generic_stateid(struct nfs4_ol_stateid *stp)
 {
 	if (!atomic_dec_and_test(&stp->st_stid.sc_count))
 		return;
-	remove_stid(&stp->st_stid);
 	nfs4_free_stid(stateid_slab, &stp->st_stid);
 }
 
@@ -4041,7 +4041,9 @@ static __be32 nfsd4_validate_stateid(struct nfs4_client *cl, stateid_t *stateid)
 		return nfs_ok;
 	default:
 		printk("unknown stateid type %x\n", s->sc_type);
+		/* Fallthrough */
 	case NFS4_CLOSED_STID:
+	case NFS4_CLOSED_DELEG_STID:
 		return nfserr_bad_stateid;
 	}
 }
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index fc71ad61238d..7aaf6e74504c 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -81,6 +81,7 @@ struct nfs4_stid {
 #define NFS4_CLOSED_STID 8
 /* For a deleg stateid kept around only to process free_stateid's: */
 #define NFS4_REVOKED_DELEG_STID 16
+#define NFS4_CLOSED_DELEG_STID 32
 	unsigned char sc_type;
 	stateid_t sc_stateid;
 	struct nfs4_client *sc_client;
-- 
1.9.3

