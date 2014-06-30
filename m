Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f175.google.com ([209.85.216.175]:41192 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755314AbaF3Pz1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 11:55:27 -0400
Received: by mail-qc0-f175.google.com with SMTP id i8so7253054qcq.34
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2014 08:55:27 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 113/114] nfsd: remove the client_mutex and the nfs4_lock/unlock_state wrappers
Date: Mon, 30 Jun 2014 11:55:00 -0400
Message-Id: <1404143701-24740-15-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 15 ---------------
 1 file changed, 15 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 36a8ba158ed3..6895bc518d88 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -80,9 +80,6 @@ static void nfs4_put_stateowner(struct nfs4_stateowner *sop);
 
 /* Locking: */
 
-/* Currently used for almost all code touching nfsv4 state: */
-static DEFINE_MUTEX(client_mutex);
-
 /*
  * Currently used for the del_recall_lru and file hash table.  In an
  * effort to decrease the scope of the client_mutex, this spinlock may
@@ -102,12 +99,6 @@ static struct kmem_cache *file_slab;
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
@@ -123,12 +114,6 @@ static __be32 mark_session_dead_locked(struct nfsd4_session *ses, int ref_held_b
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

