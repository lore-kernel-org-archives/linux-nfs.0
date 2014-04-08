Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f169.google.com ([209.85.192.169]:49464 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750789AbaDHFGr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Apr 2014 01:06:47 -0400
Received: by mail-pd0-f169.google.com with SMTP id fp1so482458pdb.28
        for <linux-nfs@vger.kernel.org>; Mon, 07 Apr 2014 22:06:47 -0700 (PDT)
Message-ID: <534383D4.50504@gmail.com>
Date: Tue, 08 Apr 2014 13:06:28 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: [PATCH] NFSD: Get rid of empty function nfs4_state_init
Content-Type: text/plain; charset=GB2312
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4state.c | 7 -------
 fs/nfsd/nfsctl.c    | 1 -
 fs/nfsd/nfsd.h      | 2 --
 3 files changed, 10 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 5a9588e..6e786a8 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4969,13 +4969,6 @@ struct nfs4_client *nfsd_find_client(struct
sockaddr_storage *addr, size_t addr_

 #endif /* CONFIG_NFSD_FAULT_INJECTION */

-/* initialization to perform at module load time: */
-
-void
-nfs4_state_init(void)
-{
-}
-
 /*
  * Since the lifetime of a delegation isn't limited to that of an open, a
  * client may quite reasonably hang on to a delegation as long as it has
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 7f55517..493f3d4 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1174,7 +1174,6 @@ static int __init init_nfsd(void)
 	retval = nfsd4_init_slabs();
 	if (retval)
 		goto out_unregister_pernet;
-	nfs4_state_init();
 	retval = nfsd_fault_inject_init(); /* nfsd fault injection controls */
 	if (retval)
 		goto out_free_slabs;
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 30f34ab..22259f8 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -106,7 +106,6 @@ static inline int nfsd_v4client(struct svc_rqst *rq)
  */
 #ifdef CONFIG_NFSD_V4
 extern unsigned long max_delegations;
-void nfs4_state_init(void);
 int nfsd4_init_slabs(void);
 void nfsd4_free_slabs(void);
 int nfs4_state_start(void);
@@ -117,7 +116,6 @@ void nfs4_reset_lease(time_t leasetime);
 int nfs4_reset_recoverydir(char *recdir);
 char * nfs4_recoverydir(void);
 #else
-static inline void nfs4_state_init(void) { }
 static inline int nfsd4_init_slabs(void) { return 0; }
 static inline void nfsd4_free_slabs(void) { }
 static inline int nfs4_state_start(void) { return 0; }
-- 
1.9.0

