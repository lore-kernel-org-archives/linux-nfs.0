From: andros@netapp.com
Subject: [PATCH 17/22] SQUASHME nfsd41 remove CONFIG_NFS_V4_1 around nfsd4_release_respages
Date: Thu,  2 Apr 2009 20:19:58 -0400
Message-ID: <1238718003-8764-17-git-send-email-andros@netapp.com>
References: <1238718003-8764-1-git-send-email-andros@netapp.com>
 <1238718003-8764-2-git-send-email-andros@netapp.com>
 <1238718003-8764-3-git-send-email-andros@netapp.com>
 <1238718003-8764-4-git-send-email-andros@netapp.com>
 <1238718003-8764-5-git-send-email-andros@netapp.com>
 <1238718003-8764-6-git-send-email-andros@netapp.com>
 <1238718003-8764-7-git-send-email-andros@netapp.com>
 <1238718003-8764-8-git-send-email-andros@netapp.com>
 <1238718003-8764-9-git-send-email-andros@netapp.com>
 <1238718003-8764-10-git-send-email-andros@netapp.com>
 <1238718003-8764-11-git-send-email-andros@netapp.com>
 <1238718003-8764-12-git-send-email-andros@netapp.com>
 <1238718003-8764-13-git-send-email-andros@netapp.com>
 <1238718003-8764-14-git-send-email-andros@netapp.com>
 <1238718003-8764-15-git-send-email-andros@netapp.com>
 <1238718003-8764-16-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33624 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757331AbZDCAUi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Apr 2009 20:20:38 -0400
In-Reply-To: <1238718003-8764-16-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

March 31 review comments.
Squash into nfsd41: Add a create session replay cache

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 852b101..7110278 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -659,12 +659,10 @@ static inline void
 free_client(struct nfs4_client *clp)
 {
 	shutdown_callback_client(clp);
-#if defined(CONFIG_NFSD_V4_1)
 	if (clp->cl_cb_xprt)
 		svc_xprt_put(clp->cl_cb_xprt);
 	nfsd4_release_respages(clp->cl_slot.sl_cache_entry.ce_respages,
 			     clp->cl_slot.sl_cache_entry.ce_resused);
-#endif /* CONFIG_NFSD_V4_1 */
 	if (clp->cl_cred.cr_group_info)
 		put_group_info(clp->cl_cred.cr_group_info);
 	kfree(clp->cl_principal);
@@ -1540,6 +1538,8 @@ out:
 	dprintk("%s: return %d\n", __func__, ntohl(status));
 	return status;
 }
+#else /* CONFIG_NFSD_V4_1 */
+static void nfsd4_release_respages(struct page **respages, short resused) {}
 #endif /* CONFIG_NFSD_V4_1 */
 
 __be32
-- 
1.5.4.3

