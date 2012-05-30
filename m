Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41413 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752340Ab2E3Sgb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 May 2012 14:36:31 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 4/5] nfsd4: don't remove rebooted client record until confirmation
Date: Wed, 30 May 2012 14:36:27 -0400
Message-Id: <1338402988-17356-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1338402988-17356-1-git-send-email-bfields@redhat.com>
References: <1338402988-17356-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

In the NFSv4.1 client-reboot case we're currently removing the client's
previous state in exchange_id.  That's wrong--we should be waiting till
the confirming create_session.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index c03c951..4bd5e4d 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1614,7 +1614,8 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 				status = nfserr_clid_inuse;
 				goto out;
 			}
-			goto expire_client;
+			expire_client(conf);
+			goto out_new;
 		}
 		if (verfs_match) { /* case 2 */
 			conf->cl_exchange_flags |= EXCHGID4_FLAG_CONFIRMED_R;
@@ -1622,8 +1623,6 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 			goto out_copy;
 		}
 		/* case 5, client reboot */
-expire_client:
-		expire_client(conf);
 		goto out_new;
 	}
 
@@ -1805,8 +1804,14 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 
 	/* cache solo and embedded create sessions under the state lock */
 	nfsd4_cache_create_session(cr_ses, cs_slot, status);
-	if (confirm_me)
+	if (confirm_me) {
+		unsigned int hash = clientstr_hashval(unconf->cl_recdir);
+		struct nfs4_client *old =
+			find_confirmed_client_by_str(conf->cl_recdir, hash);
+		if (old)
+			expire_client(old);
 		move_to_confirmed(conf);
+	}
 out:
 	nfs4_unlock_state();
 	dprintk("%s returns %d\n", __func__, ntohl(status));
-- 
1.7.10.2

