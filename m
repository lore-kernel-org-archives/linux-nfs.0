Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f49.google.com ([209.85.192.49]:38780 "EHLO
	mail-qg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753304AbaGHSFz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jul 2014 14:05:55 -0400
Received: by mail-qg0-f49.google.com with SMTP id f51so5277255qge.22
        for <linux-nfs@vger.kernel.org>; Tue, 08 Jul 2014 11:05:54 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 058/100] nfsd: add locking to stateowner release
Date: Tue,  8 Jul 2014 14:03:46 -0400
Message-Id: <1404842668-22521-59-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Once we remove the client_mutex, we'll need to properly protect
the stateowner reference counts using the cl_lock.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 15 ++++++---------
 1 file changed, 6 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index fb2f3ec0708f..346bdf320a35 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3047,9 +3047,14 @@ static inline void *alloc_stateowner(struct kmem_cache *slab, struct xdr_netobj
 
 static void nfs4_put_stateowner(struct nfs4_stateowner *sop)
 {
-	if (!atomic_dec_and_test(&sop->so_count))
+	struct nfs4_client *clp = sop->so_client;
+
+	might_lock(&clp->cl_lock);
+
+	if (!atomic_dec_and_lock(&sop->so_count, &clp->cl_lock))
 		return;
 	sop->so_unhash(sop);
+	spin_unlock(&clp->cl_lock);
 	sop->so_free(sop);
 }
 
@@ -3064,11 +3069,7 @@ static void hash_openowner(struct nfs4_openowner *oo, struct nfs4_client *clp, u
 
 static void nfs4_unhash_openowner(struct nfs4_stateowner *so)
 {
-	struct nfs4_client *clp = so->so_client;
-
-	spin_lock(&clp->cl_lock);
 	unhash_openowner_locked(openowner(so));
-	spin_unlock(&clp->cl_lock);
 }
 
 static void nfs4_free_openowner(struct nfs4_stateowner *so)
@@ -4837,11 +4838,7 @@ find_lockowner_str(clientid_t *clid, struct xdr_netobj *owner,
 
 static void nfs4_unhash_lockowner(struct nfs4_stateowner *sop)
 {
-	struct nfs4_client *clp = sop->so_client;
-
-	spin_lock(&clp->cl_lock);
 	unhash_lockowner_locked(lockowner(sop));
-	spin_unlock(&clp->cl_lock);
 }
 
 static void nfs4_free_lockowner(struct nfs4_stateowner *sop)
-- 
1.9.3

