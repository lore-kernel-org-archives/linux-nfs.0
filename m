Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f181.google.com ([209.85.216.181]:34751 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751936AbaFZTWO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2014 15:22:14 -0400
Received: by mail-qc0-f181.google.com with SMTP id x13so3541444qcv.40
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jun 2014 12:22:13 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 116/117] nfsd: remove the client_mutex and the nfs4_lock/unlock_state wrappers
Date: Thu, 26 Jun 2014 15:21:24 -0400
Message-Id: <1403810485-16497-33-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 15 ---------------
 1 file changed, 15 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 55c3405d0327..d2103a67d6c6 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -83,9 +83,6 @@ static __be32 lookup_clientid(clientid_t *clid,
 
 /* Locking: */
 
-/* Currently used for almost all code touching nfsv4 state: */
-static DEFINE_MUTEX(client_mutex);
-
 /*
  * Currently used for the del_recall_lru and file hash table.  In an
  * effort to decrease the scope of the client_mutex, this spinlock may
@@ -105,12 +102,6 @@ static struct kmem_cache *file_slab;
 static struct kmem_cache *stateid_slab;
 static struct kmem_cache *deleg_slab;
 
-void
-nfs4_lock_state(void)
-{
-	mutex_lock(&client_mutex);
-}
-
 static void free_session(struct nfsd4_session *);
 
 static bool is_session_dead(struct nfsd4_session *ses)
@@ -126,12 +117,6 @@ static __be32 mark_session_dead_locked(struct nfsd4_session *ses, int ref_held_b
 	return nfs_ok;
 }
 
-void
-nfs4_unlock_state(void)
-{
-	mutex_unlock(&client_mutex);
-}
-
 static bool is_client_expired(struct nfs4_client *clp)
 {
 	return clp->cl_time == 0;
-- 
1.9.3

