Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f51.google.com ([209.85.216.51]:37554 "EHLO
	mail-qa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752447Ab3IZSnJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Sep 2013 14:43:09 -0400
Received: by mail-qa0-f51.google.com with SMTP id j15so1100736qaq.17
        for <linux-nfs@vger.kernel.org>; Thu, 26 Sep 2013 11:43:09 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: " J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC v0 47/49] pnfsd: pnfs_expire_client
Date: Thu, 26 Sep 2013 14:43:07 -0400
Message-Id: <1380220987-14853-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <52447EA0.7070004@primarydata.com>
References: <52447EA0.7070004@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Destroy the client layout state upon expiry.

pnfs_return_client_layouts is used to locate the related layout state
as if the client returned all of its layouts via RETURN_ALL with IOMODE_ANY.

Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfs4pnfsd.c | 22 ++++++++++++++++++++++
 fs/nfsd/nfs4state.c |  1 +
 fs/nfsd/state.h     |  2 ++
 3 files changed, 25 insertions(+)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index 2ba4a29..d18e2a1 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -862,3 +862,25 @@ int nfs4_pnfs_return_layout(struct svc_rqst *rqstp,
 	dprintk("pNFS %s: exit status %d\n", __func__, status);
 	return status;
 }
+
+/*
+ * Note: must be called under the state lock
+ */
+void pnfs_expire_client(struct nfs4_client *clp)
+{
+	struct nfsd4_pnfs_layoutreturn lr = {
+		.args.lr_return_type = RETURN_ALL,
+		.args.lr_seg = {
+			.iomode = IOMODE_ANY,
+			.offset = 0,
+			.length = NFS4_MAX_UINT64,
+		},
+	};
+	LIST_HEAD(lo_destroy_list);
+
+	nfs4_assert_state_locked();
+
+	pnfs_return_client_layouts(clp, &lr, 0, &lo_destroy_list);
+
+	destroy_layout_list(&lo_destroy_list);
+}
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index a9bd82b..600edbc 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1172,6 +1172,7 @@ static struct nfs4_client *alloc_client(struct xdr_netobj name)
 		oo = list_entry(clp->cl_openowners.next, struct nfs4_openowner, oo_perclient);
 		release_openowner(oo);
 	}
+	pnfs_expire_client(clp);
 	nfsd4_shutdown_callback(clp);
 	if (clp->cl_cb_conn.cb_xprt)
 		svc_xprt_put(clp->cl_cb_conn.cb_xprt);
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index d2c75c5..90ec8b9 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -506,9 +506,11 @@ extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(const char *name,
 #if defined(CONFIG_PNFSD)
 extern int nfsd4_init_pnfs_slabs(void);
 extern void nfsd4_free_pnfs_slabs(void);
+extern void pnfs_expire_client(struct nfs4_client *);
 #else /* CONFIG_PNFSD */
 static inline void nfsd4_free_pnfs_slabs(void) {}
 static inline int nfsd4_init_pnfs_slabs(void) { return 0; }
+static inline void pnfs_expire_client(struct nfs4_client *clp) {}
 #endif /* CONFIG_PNFSD */
 
 static inline u64
-- 
1.8.3.1

