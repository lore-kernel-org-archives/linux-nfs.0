Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f54.google.com ([209.85.192.54]:39132 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757899AbaFSOwu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:52:50 -0400
Received: by mail-qg0-f54.google.com with SMTP id q107so2217954qgd.13
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:52:49 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 078/104] nfsd: move unhash_client_locked call into mark_client_expired_locked
Date: Thu, 19 Jun 2014 10:50:24 -0400
Message-Id: <1403189450-18729-79-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

All the callers except for the fault injection code call it directly
afterward, and in the fault injection case it won't hurt to do so
anyway.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 8267531ed455..cfb090b9bb21 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -69,6 +69,7 @@ static u64 current_sessionid = 1;
 #define CURRENT_STATEID(stateid) (!memcmp((stateid), &currentstateid, sizeof(stateid_t)))
 
 /* forward declarations */
+static void unhash_client_locked(struct nfs4_client *clp);
 static int check_for_locks(struct nfs4_file *filp, struct nfs4_lockowner *lowner);
 static void nfs4_free_generic_stateid(struct nfs4_stid *stid);
 static struct nfs4_openowner *find_openstateowner_str_locked(
@@ -139,7 +140,7 @@ static __be32 mark_client_expired_locked(struct nfs4_client *clp)
 {
 	if (atomic_read(&clp->cl_refcount))
 		return nfserr_jukebox;
-	clp->cl_time = 0;
+	unhash_client_locked(clp);
 	return nfs_ok;
 }
 
@@ -2323,7 +2324,6 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 			status = mark_client_expired_locked(old);
 			if (status)
 				goto out_free_conn;
-			unhash_client_locked(old);
 		}
 		move_to_confirmed(unconf);
 		conf = unconf;
@@ -2869,7 +2869,6 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 			status = mark_client_expired_locked(old);
 			if (status)
 				goto out;
-			unhash_client_locked(old);
 		}
 		move_to_confirmed(unconf);
 		conf = unconf;
@@ -4008,7 +4007,6 @@ nfs4_laundromat(struct nfsd_net *nn)
 				clp->cl_clientid.cl_id);
 			continue;
 		}
-		unhash_client_locked(clp);
 		list_add(&clp->cl_lru, &reaplist);
 	}
 	spin_unlock(&nn->client_lock);
-- 
1.9.3

