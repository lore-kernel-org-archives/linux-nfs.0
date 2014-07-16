Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f53.google.com ([209.85.216.53]:47185 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965094AbaGPOcT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Jul 2014 10:32:19 -0400
Received: by mail-qa0-f53.google.com with SMTP id v10so748130qac.40
        for <linux-nfs@vger.kernel.org>; Wed, 16 Jul 2014 07:32:18 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: hch@infradead.org, linux-nfs@vger.kernel.org
Subject: [PATCH v2 04/10] nfsd: Ensure stateids remain unique until they are freed
Date: Wed, 16 Jul 2014 10:31:59 -0400
Message-Id: <1405521125-2303-5-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1405521125-2303-1-git-send-email-jlayton@primarydata.com>
References: <1405521125-2303-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Add an extra delegation state to allow the stateid to remain in the idr
tree until the last reference has been released. This will be necessary
to ensure uniqueness once the client_mutex is removed.

[jlayton: reset the sc_type under the state_lock in unhash_delegation]

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs4state.c | 8 ++++----
 fs/nfsd/state.h     | 1 +
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 1b01a20827ab..fd4deb049ddf 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -616,6 +616,7 @@ void
 nfs4_put_delegation(struct nfs4_delegation *dp)
 {
 	if (atomic_dec_and_test(&dp->dl_count)) {
+		remove_stid(&dp->dl_stid);
 		nfs4_free_stid(deleg_slab, &dp->dl_stid);
 		num_delegations--;
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
 
@@ -4036,7 +4034,9 @@ static __be32 nfsd4_validate_stateid(struct nfs4_client *cl, stateid_t *stateid)
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

