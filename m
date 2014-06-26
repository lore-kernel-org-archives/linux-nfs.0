Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f177.google.com ([209.85.216.177]:60466 "EHLO
	mail-qc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750986AbaFZTPg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2014 15:15:36 -0400
Received: by mail-qc0-f177.google.com with SMTP id r5so3542974qcx.36
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jun 2014 12:15:36 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v2 081/117] nfsd: Ensure that the laundromat unhashes the client before releasing locks
Date: Thu, 26 Jun 2014 15:13:01 -0400
Message-Id: <1403810017-16062-82-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

If we leave the client on the confirmed/unconfirmed tables, and leave
the sessions visible on the sessionid_hashtbl, then someone might
find them before we've had a chance to destroy them.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 8a973601718e..889854591557 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4085,13 +4085,15 @@ nfs4_laundromat(struct nfsd_net *nn)
 				clp->cl_clientid.cl_id);
 			continue;
 		}
-		list_move(&clp->cl_lru, &reaplist);
+		unhash_client_locked(clp);
+		list_add(&clp->cl_lru, &reaplist);
 	}
 	spin_unlock(&nn->client_lock);
 	list_for_each_safe(pos, next, &reaplist) {
 		clp = list_entry(pos, struct nfs4_client, cl_lru);
 		dprintk("NFSD: purging unused client (clientid %08x)\n",
 			clp->cl_clientid.cl_id);
+		list_del_init(&clp->cl_lru);
 		expire_client(clp);
 	}
 	spin_lock(&state_lock);
-- 
1.9.3

