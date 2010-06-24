From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 1/6] nfsd4; fix session reference count leak
Date: Thu, 24 Jun 2010 12:29:05 -0400
Message-ID: <1277396950-18298-2-git-send-email-bfields@citi.umich.edu>
References: <1277396950-18298-1-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:52615 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756048Ab0FXQ3K (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Jun 2010 12:29:10 -0400
In-Reply-To: <1277396950-18298-1-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Note the session has to be put() here regardless of what happens to the
client.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4state.c |    1 -
 fs/nfsd/nfs4xdr.c   |    1 +
 2 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 1176708..5a69ee6 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -714,7 +714,6 @@ release_session_client(struct nfsd4_session *session)
 	} else
 		renew_client_locked(clp);
 	spin_unlock(&client_lock);
-	nfsd4_put_session(session);
 }
 
 /* must be called under the client_lock */
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index ac17a70..835924f 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3325,6 +3325,7 @@ nfs4svc_encode_compoundres(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compo
 		}
 		/* Renew the clientid on success and on replay */
 		release_session_client(cs->session);
+		nfsd4_put_session(cs->session);
 	}
 	return 1;
 }
-- 
1.7.0.4

