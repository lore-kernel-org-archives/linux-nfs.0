Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60976 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752845Ab3CUO4W (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Mar 2013 10:56:22 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 3/9] nfsd4: remove some dprintk's
Date: Thu, 21 Mar 2013 10:56:14 -0400
Message-Id: <1363877780-28825-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1363877780-28825-1-git-send-email-bfields@redhat.com>
References: <1363877780-28825-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

E.g. printk's that just report the return value from an op are
uninteresting as we already do that in the main proc_compound loop.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |    9 +--------
 1 file changed, 1 insertion(+), 8 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index cfd4430..91ad066 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1839,15 +1839,13 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 	/* cache solo and embedded create sessions under the state lock */
 	nfsd4_cache_create_session(cr_ses, cs_slot, status);
 	nfs4_unlock_state();
-out:
-	dprintk("%s returns %d\n", __func__, ntohl(status));
 	return status;
 out_free_conn:
 	nfs4_unlock_state();
 	free_conn(conn);
 out_free_session:
 	__free_session(new);
-	goto out;
+	return status;
 }
 
 static __be32 nfsd4_map_bcts_dir(u32 *dir)
@@ -1959,7 +1957,6 @@ nfsd4_destroy_session(struct svc_rqst *r,
 	spin_unlock(&nn->client_lock);
 	status = nfs_ok;
 out:
-	dprintk("%s returns %d\n", __func__, ntohl(status));
 	return status;
 }
 
@@ -2112,7 +2109,6 @@ out:
 	}
 	kfree(conn);
 	spin_unlock(&nn->client_lock);
-	dprintk("%s: return %d\n", __func__, ntohl(status));
 	return status;
 }
 
@@ -2151,7 +2147,6 @@ nfsd4_destroy_clientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *csta
 	expire_client(clp);
 out:
 	nfs4_unlock_state();
-	dprintk("%s return %d\n", __func__, ntohl(status));
 	return status;
 }
 
@@ -2528,8 +2523,6 @@ nfs4_share_conflict(struct svc_fh *current_fh, unsigned int deny_type)
 	struct nfs4_ol_stateid *stp;
 	__be32 ret;
 
-	dprintk("NFSD: nfs4_share_conflict\n");
-
 	fp = find_file(ino);
 	if (!fp)
 		return nfs_ok;
-- 
1.7.9.5

