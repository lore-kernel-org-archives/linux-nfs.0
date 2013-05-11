Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f171.google.com ([209.85.212.171]:36618 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756986Ab3EKCnb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 May 2013 22:43:31 -0400
Received: by mail-wi0-f171.google.com with SMTP id hn3so1203446wib.10
        for <linux-nfs@vger.kernel.org>; Fri, 10 May 2013 19:43:30 -0700 (PDT)
Received: from bhalevy-lt.il.tonian.com (bzq-79-180-144-28.red.bezeqint.net. [79.180.144.28])
        by mx.google.com with ESMTPSA id o3sm1407487wia.2.2013.05.10.19.43.29
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 10 May 2013 19:43:29 -0700 (PDT)
From: Benny Halevy <bhalevy@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 15/38] SQUASHME: pnfsd: use nfsd_net for layoutget starting v3.8
Date: Sat, 11 May 2013 05:43:25 +0300
Message-Id: <1368240205-32301-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <518B6377.3000207@tonian.com>
References: <518B6377.3000207@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

---
 fs/nfsd/nfs4pnfsd.c | 10 +++++++---
 fs/nfsd/nfs4xdr.c   |  2 +-
 fs/nfsd/pnfsd.h     |  2 +-
 fs/nfsd/state.h     |  4 ++--
 4 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index 0fa0e8b..a15100b 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -22,6 +22,7 @@
  *****************************************************************************/
 
 #include "pnfsd.h"
+#include "netns.h"
 
 #define NFSDDBG_FACILITY                NFSDDBG_PNFS
 
@@ -195,7 +196,8 @@ struct sbid_tracker {
 	status = nfsd4_lookup_stateid(stateid,
 				      (NFS4_OPEN_STID | NFS4_LOCK_STID |
 				       NFS4_DELEG_STID | NFS4_LAYOUT_STID),
-				      &stid, true);
+				      &stid, true,
+				      net_generic(clp->net, nfsd_net_id));
 	if (status)
 		goto out;
 
@@ -633,7 +635,8 @@ struct super_block *
 }
 
 __be32
-nfs4_pnfs_get_layout(struct nfsd4_pnfs_layoutget *lgp,
+nfs4_pnfs_get_layout(struct svc_rqst *rqstp,
+		     struct nfsd4_pnfs_layoutget *lgp,
 		     struct exp_xdr_stream *xdr)
 {
 	u32 status;
@@ -685,7 +688,8 @@ struct super_block *
 
 	nfs4_lock_state();
 	fp = find_alloc_file(ino, lgp->lg_fhp);
-	clp = find_confirmed_client((clientid_t *)&lgp->lg_seg.clientid, true);
+	clp = find_confirmed_client((clientid_t *)&lgp->lg_seg.clientid, true,
+				    net_generic(SVC_NET(rqstp), nfsd_net_id));
 	dprintk("pNFS %s: fp %p clp %p\n", __func__, fp, clp);
 	if (!fp || !clp) {
 		nfserr = nfserr_inval;
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index b157eae..992e425 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3848,7 +3848,7 @@ static __be32 nfsd4_encode_bind_conn_to_session(struct nfsd4_compoundres *resp,
 		xdr.end = xdr.p + exp_xdr_qwords(maxcount & ~3);
 
 	/* Retrieve, encode, and merge layout; process stateid */
-	nfserr = nfs4_pnfs_get_layout(lgp, &xdr);
+	nfserr = nfs4_pnfs_get_layout(resp->rqstp, lgp, &xdr);
 	if (nfserr)
 		goto err;
 
diff --git a/fs/nfsd/pnfsd.h b/fs/nfsd/pnfsd.h
index 2405d47..d40694b 100644
--- a/fs/nfsd/pnfsd.h
+++ b/fs/nfsd/pnfsd.h
@@ -60,7 +60,7 @@ struct nfs4_layout {
 
 u64 find_create_sbid(struct super_block *);
 struct super_block *find_sbid_id(u64);
-__be32 nfs4_pnfs_get_layout(struct nfsd4_pnfs_layoutget *, struct exp_xdr_stream *);
+__be32 nfs4_pnfs_get_layout(struct svc_rqst *, struct nfsd4_pnfs_layoutget *, struct exp_xdr_stream *);
 int nfs4_pnfs_return_layout(struct super_block *, struct svc_fh *,
 					struct nfsd4_pnfs_layoutreturn *);
 int put_layoutrecall(struct nfs4_layoutrecall *);
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index fac8550..2e5b600 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -504,12 +504,12 @@ extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(const char *name,
 extern struct nfs4_file *find_alloc_file(struct inode *, struct svc_fh *);
 extern void put_nfs4_file(struct nfs4_file *);
 extern void get_nfs4_file(struct nfs4_file *);
-extern struct nfs4_client *find_confirmed_client(clientid_t *, bool sessions);
+extern struct nfs4_client *find_confirmed_client(clientid_t *, bool sessions, struct nfsd_net *);
 extern struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl, struct kmem_cache *slab);
 extern void nfsd4_init_stid(struct nfs4_stid *, struct nfs4_client *, unsigned char type);
 extern void nfsd4_unhash_stid(struct nfs4_stid *);
 extern struct nfs4_stid *find_stateid(struct nfs4_client *, stateid_t *);
-extern __be32 nfsd4_lookup_stateid(stateid_t *, unsigned char typemask, struct nfs4_stid **, bool sessions);
+extern __be32 nfsd4_lookup_stateid(stateid_t *, unsigned char typemask, struct nfs4_stid **, bool sessions, struct nfsd_net *);
 extern int filter_confirmed_clients(int (* func)(struct nfs4_client *, void *), void *);
 
 #if defined(CONFIG_PNFSD)
-- 
1.7.11.7

