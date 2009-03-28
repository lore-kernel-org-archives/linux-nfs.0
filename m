From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 09/47] nfsd41: introduce nfs4_client cl_sessions list
Date: Sat, 28 Mar 2009 11:31:27 +0300
Message-ID: <1238229087-9746-1-git-send-email-bhalevy@panasas.com>
References: <49CDDFC2.4070402@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:15804 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754914AbZC1IcR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 28 Mar 2009 04:32:17 -0400
In-Reply-To: <49CDDFC2.4070402@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Marc Eshel <eshel@almaden.ibm.com>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c        |    3 +++
 include/linux/nfsd/state.h |    3 +++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index f4b624b..b71ec72 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -532,6 +532,9 @@ static struct nfs4_client *create_client(struct xdr_netobj name, char *recdir)
 	INIT_LIST_HEAD(&clp->cl_strhash);
 	INIT_LIST_HEAD(&clp->cl_openowners);
 	INIT_LIST_HEAD(&clp->cl_delegations);
+#if defined(CONFIG_NFSD_V4_1)
+	INIT_LIST_HEAD(&clp->cl_sessions);
+#endif /* CONFIG_NFSD_V4_1 */
 	INIT_LIST_HEAD(&clp->cl_lru);
 	return clp;
 }
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index afae103..29624b4 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -164,6 +164,9 @@ struct nfs4_client {
 	struct nfs4_callback	cl_callback;    /* callback info */
 	atomic_t		cl_count;	/* ref count */
 	u32			cl_firststate;	/* recovery dir creation */
+#ifdef CONFIG_NFSD_V4_1
+	struct list_head	cl_sessions;
+#endif /* CONFIG_NFSD_V4_1 */
 };
 
 /* struct nfs4_client_reset
-- 
1.6.2.1

