From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 39/47] nfsd41: introduce cl_cb_mutex
Date: Fri, 27 Mar 2009 06:19:37 +0300
Message-ID: <1238123977-8135-1-git-send-email-bhalevy@panasas.com>
References: <49CC40E5.2080506@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:24999 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752351AbZC0DTm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Mar 2009 23:19:42 -0400
In-Reply-To: <49CC40E5.2080506@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

To be used for serializing nfs41 callbacks.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c        |    1 +
 include/linux/nfsd/state.h |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index eb3d0dc..e5c7ddb 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -741,6 +741,7 @@ static struct nfs4_client *create_client(struct xdr_netobj name, char *recdir)
 	INIT_LIST_HEAD(&clp->cl_delegations);
 #if defined(CONFIG_NFSD_V4_1)
 	INIT_LIST_HEAD(&clp->cl_sessions);
+	mutex_init(&clp->cl_cb_mutex);
 #endif /* CONFIG_NFSD_V4_1 */
 	INIT_LIST_HEAD(&clp->cl_lru);
 	return clp;
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index b78021a..f2783d4 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -197,6 +197,7 @@ struct nfs4_client {
 	struct nfs4_sessionid	cl_sessionid;
 
 	struct svc_xprt		*cl_cb_xprt;	/* 4.1 callback transport */
+	struct mutex		cl_cb_mutex;
 #endif /* CONFIG_NFSD_V4_1 */
 };
 
-- 
1.6.2.1

