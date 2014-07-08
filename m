Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f169.google.com ([209.85.216.169]:40994 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755376AbaGHSGP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jul 2014 14:06:15 -0400
Received: by mail-qc0-f169.google.com with SMTP id i17so1402487qcy.0
        for <linux-nfs@vger.kernel.org>; Tue, 08 Jul 2014 11:06:14 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 074/100] nfsd: move unhash_client_locked call into mark_client_expired_locked
Date: Tue,  8 Jul 2014 14:04:02 -0400
Message-Id: <1404842668-22521-75-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
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
index 06b6e3387ec7..d47359b8a84e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -70,6 +70,7 @@ static u64 current_sessionid = 1;
 #define CURRENT_STATEID(stateid) (!memcmp((stateid), &currentstateid, sizeof(stateid_t)))
 
 /* forward declarations */
+static void unhash_client_locked(struct nfs4_client *clp);
 static int check_for_locks(struct nfs4_file *filp, struct nfs4_lockowner *lowner);
 static void nfs4_free_generic_stateid(struct nfs4_stid *stid);
 static struct nfs4_openowner *find_openstateowner_str_locked(
@@ -137,7 +138,7 @@ static __be32 mark_client_expired_locked(struct nfs4_client *clp)
 {
 	if (atomic_read(&clp->cl_refcount))
 		return nfserr_jukebox;
-	clp->cl_time = 0;
+	unhash_client_locked(clp);
 	return nfs_ok;
 }
 
@@ -2474,7 +2475,6 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 			status = mark_client_expired_locked(old);
 			if (status)
 				goto out_free_conn;
-			unhash_client_locked(old);
 		}
 		move_to_confirmed(unconf);
 		conf = unconf;
@@ -3020,7 +3020,6 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 			status = mark_client_expired_locked(old);
 			if (status)
 				goto out;
-			unhash_client_locked(old);
 		}
 		move_to_confirmed(unconf);
 		conf = unconf;
@@ -4185,7 +4184,6 @@ nfs4_laundromat(struct nfsd_net *nn)
 				clp->cl_clientid.cl_id);
 			continue;
 		}
-		unhash_client_locked(clp);
 		list_add(&clp->cl_lru, &reaplist);
 	}
 	spin_unlock(&nn->client_lock);
-- 
1.9.3

