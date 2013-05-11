Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f170.google.com ([74.125.82.170]:44020 "EHLO
	mail-we0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754337Ab3EKCmj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 May 2013 22:42:39 -0400
Received: by mail-we0-f170.google.com with SMTP id u54so4661318wes.29
        for <linux-nfs@vger.kernel.org>; Fri, 10 May 2013 19:42:38 -0700 (PDT)
Received: from bhalevy-lt.il.tonian.com (bzq-79-180-144-28.red.bezeqint.net. [79.180.144.28])
        by mx.google.com with ESMTPSA id ge7sm1363458wib.6.2013.05.10.19.42.37
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 10 May 2013 19:42:38 -0700 (PDT)
From: Benny Halevy <bhalevy@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 02/38] Revert "pnfsd: Clean up all stateids on DS on shutdown"
Date: Sat, 11 May 2013 05:42:33 +0300
Message-Id: <1368240153-31792-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <518B6377.3000207@tonian.com>
References: <518B6377.3000207@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This reverts commit 82d356f0294487cfc6b98d16ddea74d67eabddb4.

Conflicts:
	fs/nfsd/state.h
---
 fs/nfsd/nfs4pnfsds.c | 19 -------------------
 fs/nfsd/nfs4state.c  |  1 -
 fs/nfsd/state.h      |  2 --
 3 files changed, 22 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsds.c b/fs/nfsd/nfs4pnfsds.c
index 2732f20..13fe811 100644
--- a/fs/nfsd/nfs4pnfsds.c
+++ b/fs/nfsd/nfs4pnfsds.c
@@ -274,25 +274,6 @@ static int stateid_hashval(stateid_t *stidp)
 	kref_get(&dsp->ds_ref);
 }
 
-void
-nfs4_pnfs_state_shutdown(void)
-{
-	struct pnfs_ds_stateid *dsp;
-	int i;
-
-	dprintk("pNFSD %s: -->\n", __func__);
-
-	ds_lock_state();
-	for (i = 0; i < STATEID_HASH_SIZE; i++) {
-		while (!list_empty(&ds_stid_hashtbl[i])) {
-			dsp = list_entry(ds_stid_hashtbl[i].next,
-					 struct pnfs_ds_stateid, ds_hash);
-			put_ds_stateid(dsp);
-		}
-	}
-	ds_unlock_state();
-}
-
 static struct pnfs_mds_id *
 alloc_init_mds_id(struct pnfs_get_state *gsp)
 {
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 3c25405..d2256d8 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5090,7 +5090,6 @@ static int nfs4_state_create_net(struct net *net)
 
 	nfsd4_client_tracking_exit(net);
 	nfs4_state_destroy_net(net);
-	nfs4_pnfs_state_shutdown();
 }
 
 void
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 9935edc..31d5d0f 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -531,7 +531,6 @@ extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(const char *name,
 extern void pnfs_expire_client(struct nfs4_client *);
 extern void release_pnfs_ds_dev_list(struct nfs4_ol_stateid *);
 extern void nfs4_pnfs_state_init(void);
-extern void nfs4_pnfs_state_shutdown(void);
 extern void nfs4_ds_get_verifier(stateid_t *, struct super_block *, u32 *);
 extern int nfs4_preprocess_pnfs_ds_stateid(struct svc_fh *, stateid_t *);
 extern void pnfsd_roc(struct nfs4_client *clp, struct nfs4_file *fp);
@@ -540,7 +539,6 @@ static inline void nfsd4_free_pnfs_slabs(void) {}
 static inline int nfsd4_init_pnfs_slabs(void) { return 0; }
 static inline void pnfs_expire_client(struct nfs4_client *clp) {}
 static inline void release_pnfs_ds_dev_list(struct nfs4_ol_stateid *stp) {}
-static inline void nfs4_pnfs_state_shutdown(void) {}
 static inline void pnfsd_roc(struct nfs4_client *clp, struct nfs4_file *fp) {}
 #endif /* CONFIG_PNFSD */
 
-- 
1.7.11.7

