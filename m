From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 10/47] nfsd41: introduce nfs4_client cl_sessions list
Date: Fri, 27 Mar 2009 06:07:48 +0300
Message-ID: <1238123268-7217-1-git-send-email-bhalevy@panasas.com>
References: <49CC40E5.2080506@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Marc Eshel <eshel@almaden.ibm.com>,
	Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:16987 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754949AbZC0DHx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Mar 2009 23:07:53 -0400
In-Reply-To: <49CC40E5.2080506@panasas.com>
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

