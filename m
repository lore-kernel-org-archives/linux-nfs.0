Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f169.google.com ([209.85.216.169]:49496 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750897AbaF3Pv2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 11:51:28 -0400
Received: by mail-qc0-f169.google.com with SMTP id c9so7251938qcz.14
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2014 08:51:27 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v3 039/114] nfsd: Ensure stateids remain unique until they are freed
Date: Mon, 30 Jun 2014 11:49:08 -0400
Message-Id: <1404143423-24381-40-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
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
index 0d62692b525b..902e5f54c166 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -596,6 +596,7 @@ static void remove_stid(struct nfs4_stid *s)
 
 static void nfs4_free_stid(struct kmem_cache *slab, struct nfs4_stid *s)
 {
+	remove_stid(s);
 	if (s->sc_file)
 		put_nfs4_file(s->sc_file);
 	kmem_cache_free(slab, s);
@@ -666,7 +667,7 @@ unhash_delegation(struct nfs4_delegation *dp)
 
 static void destroy_delegation(struct nfs4_delegation *dp)
 {
-	remove_stid(&dp->dl_stid);
+	dp->dl_stid.sc_type = NFS4_CLOSED_DELEG_STID;
 	nfs4_put_delegation(dp);
 }
 
@@ -679,7 +680,7 @@ static void unhash_and_destroy_delegation(struct nfs4_delegation *dp)
 static void destroy_revoked_delegation(struct nfs4_delegation *dp)
 {
 	list_del_init(&dp->dl_recall_lru);
-	destroy_delegation(dp);
+	nfs4_put_delegation(dp);
 }
 
 static void revoke_delegation(struct nfs4_delegation *dp)
@@ -854,7 +855,6 @@ static void put_generic_stateid(struct nfs4_ol_stateid *stp)
 {
 	if (!atomic_dec_and_test(&stp->st_stid.sc_count))
 		return;
-	remove_stid(&stp->st_stid);
 	nfs4_free_stid(stateid_slab, &stp->st_stid);
 }
 
@@ -4029,7 +4029,9 @@ static __be32 nfsd4_validate_stateid(struct nfs4_client *cl, stateid_t *stateid)
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
index 722adb4e144b..95d04fae365a 100644
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

