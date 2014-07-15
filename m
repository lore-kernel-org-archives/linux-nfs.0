Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f48.google.com ([209.85.192.48]:52496 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758266AbaGOKh6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jul 2014 06:37:58 -0400
Received: by mail-qg0-f48.google.com with SMTP id i50so1825260qgf.35
        for <linux-nfs@vger.kernel.org>; Tue, 15 Jul 2014 03:37:58 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: [PATCH 2/7] nfsd: Ensure stateids remain unique until they are freed
Date: Tue, 15 Jul 2014 06:37:44 -0400
Message-Id: <1405420669-4030-3-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1405420669-4030-1-git-send-email-jlayton@primarydata.com>
References: <1405420669-4030-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Add an extra delegation state to allow the stateid to remain in the idr
tree until the last reference has been released. This will be necessary
to ensure uniqueness once the client_mutex is removed.

[jlayton: reset the sc_type under the state_lock in unhash_delegation]

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 9 ++++-----
 fs/nfsd/state.h     | 1 +
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 1b01a20827ab..df3e9ef1fb38 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -609,6 +609,7 @@ static void remove_stid(struct nfs4_stid *s)
 
 static void nfs4_free_stid(struct kmem_cache *slab, struct nfs4_stid *s)
 {
+	remove_stid(s);
 	kmem_cache_free(slab, s);
 }
 
@@ -657,6 +658,7 @@ unhash_delegation(struct nfs4_delegation *dp)
 	struct nfs4_file *fp = dp->dl_file;
 
 	spin_lock(&state_lock);
+	dp->dl_stid.sc_type = NFS4_CLOSED_DELEG_STID;
 	list_del_init(&dp->dl_perclnt);
 	list_del_init(&dp->dl_recall_lru);
 	spin_lock(&fp->fi_lock);
@@ -670,19 +672,15 @@ unhash_delegation(struct nfs4_delegation *dp)
 	}
 }
 
-
-
 static void destroy_revoked_delegation(struct nfs4_delegation *dp)
 {
 	list_del_init(&dp->dl_recall_lru);
-	remove_stid(&dp->dl_stid);
 	nfs4_put_delegation(dp);
 }
 
 static void destroy_delegation(struct nfs4_delegation *dp)
 {
 	unhash_delegation(dp);
-	remove_stid(&dp->dl_stid);
 	nfs4_put_delegation(dp);
 }
 
@@ -885,7 +883,6 @@ static void close_generic_stateid(struct nfs4_ol_stateid *stp)
 
 static void free_generic_stateid(struct nfs4_ol_stateid *stp)
 {
-	remove_stid(&stp->st_stid);
 	nfs4_free_stid(stateid_slab, &stp->st_stid);
 }
 
@@ -4036,7 +4033,9 @@ static __be32 nfsd4_validate_stateid(struct nfs4_client *cl, stateid_t *stateid)
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
index 81b7522e3f67..996d61eeb357 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -80,6 +80,7 @@ struct nfs4_stid {
 #define NFS4_CLOSED_STID 8
 /* For a deleg stateid kept around only to process free_stateid's: */
 #define NFS4_REVOKED_DELEG_STID 16
+#define NFS4_CLOSED_DELEG_STID 32
 	unsigned char sc_type;
 	stateid_t sc_stateid;
 	struct nfs4_client *sc_client;
-- 
1.9.3

