Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f181.google.com ([209.85.216.181]:63468 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757787AbaFSOwp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:52:45 -0400
Received: by mail-qc0-f181.google.com with SMTP id x13so2234429qcv.40
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:52:44 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 074/104] NFSd: Ensure lookup_clientid() takes client_lock
Date: Thu, 19 Jun 2014 10:50:20 -0400
Message-Id: <1403189450-18729-75-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Ensure that the client lookup is done safely under the client_lock.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 955027d4dc85..6e6d34111f5f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3880,12 +3880,14 @@ static __be32 lookup_clientid(clientid_t *clid,
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

