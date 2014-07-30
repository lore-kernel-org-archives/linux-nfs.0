Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f41.google.com ([209.85.192.41]:53718 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754673AbaG3M14 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jul 2014 08:27:56 -0400
Received: by mail-qg0-f41.google.com with SMTP id q107so1321222qgd.28
        for <linux-nfs@vger.kernel.org>; Wed, 30 Jul 2014 05:27:55 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH 08/37] nfsd: Ensure lookup_clientid() takes client_lock
Date: Wed, 30 Jul 2014 08:27:09 -0400
Message-Id: <1406723258-8512-9-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406723258-8512-1-git-send-email-jlayton@primarydata.com>
References: <1406723258-8512-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Ensure that the client lookup is done safely under the client_lock, so
we're not relying on the client_mutex.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 68383b09c7dc..f9d077d800ee 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3451,13 +3451,17 @@ static __be32 lookup_clientid(clientid_t *clid,
 	 * will be false.
 	 */
 	WARN_ON_ONCE(cstate->session);
+	spin_lock(&nn->client_lock);
 	found = find_confirmed_client(clid, false, nn);
-	if (!found)
+	if (!found) {
+		spin_unlock(&nn->client_lock);
 		return nfserr_expired;
+	}
+	atomic_inc(&found->cl_refcount);
+	spin_unlock(&nn->client_lock);
 
 	/* Cache the nfs4_client in cstate! */
 	cstate->clp = found;
-	atomic_inc(&found->cl_refcount);
 	return nfs_ok;
 }
 
-- 
1.9.3

