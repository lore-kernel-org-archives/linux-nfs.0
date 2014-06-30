Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f50.google.com ([209.85.216.50]:39924 "EHLO
	mail-qa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751302AbaF3Pwb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 11:52:31 -0400
Received: by mail-qa0-f50.google.com with SMTP id m5so6668228qaj.9
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2014 08:52:31 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v3 084/114] nfsd: Ensure lookup_clientid() takes client_lock
Date: Mon, 30 Jun 2014 11:49:53 -0400
Message-Id: <1404143423-24381-85-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
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
index e8d92b468218..dd7667008554 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3430,13 +3430,17 @@ static __be32 lookup_clientid(clientid_t *clid,
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

