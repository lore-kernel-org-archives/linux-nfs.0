Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f48.google.com ([209.85.192.48]:65294 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932778AbaFSOxZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:53:25 -0400
Received: by mail-qg0-f48.google.com with SMTP id q108so2209158qgd.35
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:53:25 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 103/104] nfsd: remove the client_mutex and the nfs4_lock/unlock_state wrappers
Date: Thu, 19 Jun 2014 10:50:49 -0400
Message-Id: <1403189450-18729-104-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 15 ---------------
 1 file changed, 15 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index a37e9d2aa047..e3df298b7aee 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -82,9 +82,6 @@ static __be32 lookup_clientid(clientid_t *clid,
 
 /* Locking: */
 
-/* Currently used for almost all code touching nfsv4 state: */
-static DEFINE_MUTEX(client_mutex);
-
 /*
  * Currently used for the del_recall_lru and file hash table.  In an
  * effort to decrease the scope of the client_mutex, this spinlock may
@@ -104,12 +101,6 @@ static struct kmem_cache *file_slab;
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
@@ -125,12 +116,6 @@ static __be32 mark_session_dead_locked(struct nfsd4_session *ses, int ref_held_b
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

