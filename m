Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f53.google.com ([209.85.192.53]:54054 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755376AbaGHSGK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jul 2014 14:06:10 -0400
Received: by mail-qg0-f53.google.com with SMTP id i50so5449159qgf.40
        for <linux-nfs@vger.kernel.org>; Tue, 08 Jul 2014 11:06:09 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 070/100] nfsd: Ensure lookup_clientid() takes client_lock
Date: Tue,  8 Jul 2014 14:03:58 -0400
Message-Id: <1404842668-22521-71-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
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
index 8c3f63f9dd4e..eea6a844e2f2 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3467,13 +3467,17 @@ static __be32 lookup_clientid(clientid_t *clid,
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

