From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 33/51] nfsd41: introduce cl_cb_mutex
Date: Mon, 10 Nov 2008 22:52:00 +0200
Message-ID: <1226350320-11342-1-git-send-email-bhalevy@panasas.com>
References: <491895A0.3040809@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:57385 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752135AbYKJUwM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:52:12 -0500
In-Reply-To: <491895A0.3040809@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To be used for serializing nfs41 callbacks.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c        |    1 +
 include/linux/nfsd/state.h |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index edac97a..9377ad0 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -625,6 +625,7 @@ static struct nfs4_client *create_client(struct xdr_netobj name, char *recdir)
 	INIT_LIST_HEAD(&clp->cl_delegations);
 #if defined(CONFIG_NFSD_V4_1)
 	INIT_LIST_HEAD(&clp->cl_sessions);
+	mutex_init(&clp->cl_cb_mutex);
 #endif /* CONFIG_NFSD_V4_1 */
 	INIT_LIST_HEAD(&clp->cl_lru);
 	return clp;
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index 918adde..eb8d55c 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -221,6 +221,7 @@ struct nfs4_client {
 	nfs41_sessionid		cl_sessionid;
 
 	struct svc_xprt		*cl_cb_xprt;	/* 4.1 callback transport */
+	struct mutex		cl_cb_mutex;
 #endif /* CONFIG_NFSD_V4_1 */
 };
 
-- 
1.6.0.2

