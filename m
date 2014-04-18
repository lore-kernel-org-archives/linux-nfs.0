Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f182.google.com ([209.85.223.182]:53301 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753153AbaDRSpU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Apr 2014 14:45:20 -0400
Received: by mail-ie0-f182.google.com with SMTP id y20so1904337ier.13
        for <linux-nfs@vger.kernel.org>; Fri, 18 Apr 2014 11:45:19 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 09/70] NFSd: Mark nfs4_free_lockowner and nfs4_free_openowner as static functions
Date: Fri, 18 Apr 2014 14:44:03 -0400
Message-Id: <1397846704-14567-10-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1397846704-14567-9-git-send-email-trond.myklebust@primarydata.com>
References: <1397846704-14567-1-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-2-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-3-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-4-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-5-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-6-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-7-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-8-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-9-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

They do not need to be used outside fs/nfsd/nfs4state.c

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 24 ++++++++++++------------
 fs/nfsd/state.h     |  2 --
 2 files changed, 12 insertions(+), 14 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 45c4b692e30d..6d691aa2bb27 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -659,6 +659,12 @@ static void unhash_lockowner(struct nfs4_lockowner *lo)
 	}
 }
 
+static void nfs4_free_lockowner(struct nfs4_lockowner *lo)
+{
+	kfree(lo->lo_owner.so_owner.data);
+	kmem_cache_free(lockowner_slab, lo);
+}
+
 static void release_lockowner(struct nfs4_lockowner *lo)
 {
 	unhash_lockowner(lo);
@@ -713,6 +719,12 @@ static void release_last_closed_stateid(struct nfs4_openowner *oo)
 	}
 }
 
+static void nfs4_free_openowner(struct nfs4_openowner *oo)
+{
+	kfree(oo->oo_owner.so_owner.data);
+	kmem_cache_free(openowner_slab, oo);
+}
+
 static void release_openowner(struct nfs4_openowner *oo)
 {
 	unhash_openowner(oo);
@@ -2571,18 +2583,6 @@ out_nomem:
 	return -ENOMEM;
 }
 
-void nfs4_free_openowner(struct nfs4_openowner *oo)
-{
-	kfree(oo->oo_owner.so_owner.data);
-	kmem_cache_free(openowner_slab, oo);
-}
-
-void nfs4_free_lockowner(struct nfs4_lockowner *lo)
-{
-	kfree(lo->lo_owner.so_owner.data);
-	kmem_cache_free(lockowner_slab, lo);
-}
-
 static void init_nfs4_replay(struct nfs4_replay *rp)
 {
 	rp->rp_status = nfserr_serverfault;
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 424d8f5f2317..1aa22f39fc65 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -464,8 +464,6 @@ extern void nfs4_release_reclaim(struct nfsd_net *);
 extern struct nfs4_client_reclaim *nfsd4_find_reclaim_client(const char *recdir,
 							struct nfsd_net *nn);
 extern __be32 nfs4_check_open_reclaim(clientid_t *clid, bool sessions, struct nfsd_net *nn);
-extern void nfs4_free_openowner(struct nfs4_openowner *);
-extern void nfs4_free_lockowner(struct nfs4_lockowner *);
 extern int set_callback_cred(void);
 extern void nfsd4_init_callback(struct nfsd4_callback *);
 extern void nfsd4_probe_callback(struct nfs4_client *clp);
-- 
1.9.0

