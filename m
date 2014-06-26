Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f51.google.com ([209.85.192.51]:50211 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751514AbaFZTVf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2014 15:21:35 -0400
Received: by mail-qg0-f51.google.com with SMTP id z60so3453031qgd.38
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jun 2014 12:21:35 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v2 087/117] nfsd: Ensure lookup_clientid() takes client_lock
Date: Thu, 26 Jun 2014 15:20:55 -0400
Message-Id: <1403810485-16497-4-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Ensure that the client lookup is done safely under the client_lock, so
we're not relying on the client_mutex.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 77e4e24c920d..e81c97435f7f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4016,12 +4016,14 @@ static __be32 lookup_clientid(clientid_t *clid,
 		 * if we don't have one cached already then we know this is for
 		 * is for v4.0 and "sessions" will be false.
 		 */
+		spin_lock(&nn->client_lock);
 		found = find_confirmed_client(clid, false, nn);
 		/* Cache the nfs4_client in cstate! */
 		if (found) {
 			cstate->clp = found;
 			atomic_inc(&found->cl_refcount);
 		}
+		spin_unlock(&nn->client_lock);
 	}
 	return found ? nfs_ok : nfserr_expired;
 }
-- 
1.9.3

