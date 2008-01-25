From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 001/100] nfsd4: probe callback channel only once
Date: Fri, 25 Jan 2008 18:15:41 -0500
Message-ID: <1201303040-7779-1-git-send-email-bfields@citi.umich.edu>
References: <20080125231521.GG25141@fieldses.org>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47305 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758613AbYAYXRV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 18:17:21 -0500
In-Reply-To: <20080125231521.GG25141@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Our callback code doesn't actually handle concurrent attempts to probe
the callback channel.  Some rethinking of the locking may be required.
However, we can also just move the callback probing to this case.  Since
this is the only time a client is "confirmed" (and since that can only
happen once in the lifetime of a client), this ensures we only probe
once.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4callback.c |    3 +--
 fs/nfsd/nfs4state.c    |    3 +--
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 9d536a8..a9735a6 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -395,8 +395,7 @@ nfsd4_probe_callback(struct nfs4_client *clp)
 	};
 	struct task_struct *t;
 
-	if (atomic_read(&cb->cb_set))
-		return;
+	BUG_ON(atomic_read(&clp->cl_callback.cb_set));
 
 	/* Initialize address */
 	memset(&addr, 0, sizeof(addr));
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 31673cd..9d81c71 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -948,6 +948,7 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 			}
 			move_to_confirmed(unconf);
 			conf = unconf;
+			nfsd4_probe_callback(conf);
 			status = nfs_ok;
 		}
 	} else if ((!conf || (conf && !same_verf(&conf->cl_confirm, &confirm)))
@@ -965,8 +966,6 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 		status = nfserr_clid_inuse;
 	}
 out:
-	if (!status)
-		nfsd4_probe_callback(conf);
 	nfs4_unlock_state();
 	return status;
 }
-- 
1.5.4.rc2.60.gb2e62

