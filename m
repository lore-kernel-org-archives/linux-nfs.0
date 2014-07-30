Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f48.google.com ([209.85.216.48]:51793 "EHLO
	mail-qa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754671AbaG3M2B (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jul 2014 08:28:01 -0400
Received: by mail-qa0-f48.google.com with SMTP id m5so1167434qaj.21
        for <linux-nfs@vger.kernel.org>; Wed, 30 Jul 2014 05:28:00 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: [PATCH 11/37] nfsd: move unhash_client_locked call into mark_client_expired_locked
Date: Wed, 30 Jul 2014 08:27:12 -0400
Message-Id: <1406723258-8512-12-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406723258-8512-1-git-send-email-jlayton@primarydata.com>
References: <1406723258-8512-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

All the callers except for the fault injection code call it directly
afterward, and in the fault injection case it won't hurt to do so
anyway.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 19 ++++++++-----------
 1 file changed, 8 insertions(+), 11 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 818480035453..56999cbe84a7 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -129,14 +129,6 @@ static bool is_client_expired(struct nfs4_client *clp)
 	return clp->cl_time == 0;
 }
 
-static __be32 mark_client_expired_locked(struct nfs4_client *clp)
-{
-	if (atomic_read(&clp->cl_refcount))
-		return nfserr_jukebox;
-	clp->cl_time = 0;
-	return nfs_ok;
-}
-
 static __be32 get_client_locked(struct nfs4_client *clp)
 {
 	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
@@ -1628,6 +1620,14 @@ unhash_client(struct nfs4_client *clp)
 	spin_unlock(&nn->client_lock);
 }
 
+static __be32 mark_client_expired_locked(struct nfs4_client *clp)
+{
+	if (atomic_read(&clp->cl_refcount))
+		return nfserr_jukebox;
+	unhash_client_locked(clp);
+	return nfs_ok;
+}
+
 static void
 __destroy_client(struct nfs4_client *clp)
 {
@@ -2498,7 +2498,6 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 			status = mark_client_expired_locked(old);
 			if (status)
 				goto out_free_conn;
-			unhash_client_locked(old);
 		}
 		move_to_confirmed(unconf);
 		conf = unconf;
@@ -3044,7 +3043,6 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 			status = mark_client_expired_locked(old);
 			if (status)
 				goto out;
-			unhash_client_locked(old);
 		}
 		move_to_confirmed(unconf);
 		conf = unconf;
@@ -4183,7 +4181,6 @@ nfs4_laundromat(struct nfsd_net *nn)
 				clp->cl_clientid.cl_id);
 			continue;
 		}
-		unhash_client_locked(clp);
 		list_add(&clp->cl_lru, &reaplist);
 	}
 	spin_unlock(&nn->client_lock);
-- 
1.9.3

