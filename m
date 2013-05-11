Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f171.google.com ([209.85.212.171]:35477 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757013Ab3EKCnj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 May 2013 22:43:39 -0400
Received: by mail-wi0-f171.google.com with SMTP id hn3so1205878wib.4
        for <linux-nfs@vger.kernel.org>; Fri, 10 May 2013 19:43:38 -0700 (PDT)
Received: from bhalevy-lt.il.tonian.com (bzq-79-180-144-28.red.bezeqint.net. [79.180.144.28])
        by mx.google.com with ESMTPSA id e8sm1217483wic.5.2013.05.10.19.43.37
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 10 May 2013 19:43:37 -0700 (PDT)
From: Benny Halevy <bhalevy@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 17/38] SQUASHME: use nfsd_net for layoutreturn starting v3.8
Date: Sat, 11 May 2013 05:43:33 +0300
Message-Id: <1368240213-32377-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <518B6377.3000207@tonian.com>
References: <518B6377.3000207@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

---
 fs/nfsd/nfs4pnfsd.c |  7 +++++--
 fs/nfsd/nfs4proc.c  |  2 +-
 fs/nfsd/nfs4state.c | 18 ------------------
 fs/nfsd/pnfsd.h     |  3 +--
 fs/nfsd/state.h     |  1 -
 5 files changed, 7 insertions(+), 24 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index e516eba..96206d9 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -1002,7 +1002,9 @@ struct super_block *
 	       lo_seg_overlapping(&clr->cb.cbl_seg, &lrp->args.lr_seg);
 }
 
-int nfs4_pnfs_return_layout(struct super_block *sb, struct svc_fh *current_fh,
+int nfs4_pnfs_return_layout(struct svc_rqst *rqstp,
+			    struct super_block *sb,
+			    struct svc_fh *current_fh,
 			    struct nfsd4_pnfs_layoutreturn *lrp)
 {
 	int status = 0;
@@ -1019,7 +1021,8 @@ int nfs4_pnfs_return_layout(struct super_block *sb, struct svc_fh *current_fh,
 	dprintk("NFSD: %s\n", __func__);
 
 	nfs4_lock_state();
-	clp = find_confirmed_client((clientid_t *)&lrp->args.lr_seg.clientid, true);
+	clp = find_confirmed_client((clientid_t *)&lrp->args.lr_seg.clientid,
+				    true, net_generic(SVC_NET(rqstp), nfsd_net_id));
 	if (!clp)
 		goto out;
 
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index c9befff..4fd5549 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1327,7 +1327,7 @@ static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
 	/* Set clientid from sessionid */
 	copy_clientid((clientid_t *)&lrp->args.lr_seg.clientid, cstate->session);
 	lrp->lrs_present = 0;
-	status = nfs4_pnfs_return_layout(sb, current_fh, lrp);
+	status = nfs4_pnfs_return_layout(rqstp, sb, current_fh, lrp);
 out:
 	dprintk("pNFS %s: status %d return_type 0x%x lrs_present %d\n",
 		__func__, status, lrp->args.lr_return_type, lrp->lrs_present);
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 0871146..1170f8a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1456,24 +1456,6 @@ static bool clp_used_exchangeid(struct nfs4_client *clp)
 	return find_clp_in_name_tree(name, &nn->unconf_name_tree);
 }
 
-int
-filter_confirmed_clients(int (* func)(struct nfs4_client *, void *),
-			 void *arg)
-{
-	struct nfs4_client *clp, *next;
-	int i, status = 0;
-
-	for (i = 0; i < CLIENT_HASH_SIZE; i++)
-		list_for_each_entry_safe (clp, next, &conf_str_hashtbl[i],
-					  cl_strhash) {
-			status = func(clp, arg);
-			if (status)
-				break;
-		}
-
-	return status;
-}
-
 static void
 gen_callback(struct nfs4_client *clp, struct nfsd4_setclientid *se, struct svc_rqst *rqstp)
 {
diff --git a/fs/nfsd/pnfsd.h b/fs/nfsd/pnfsd.h
index d40694b..2507d31 100644
--- a/fs/nfsd/pnfsd.h
+++ b/fs/nfsd/pnfsd.h
@@ -61,8 +61,7 @@ struct nfs4_layout {
 u64 find_create_sbid(struct super_block *);
 struct super_block *find_sbid_id(u64);
 __be32 nfs4_pnfs_get_layout(struct svc_rqst *, struct nfsd4_pnfs_layoutget *, struct exp_xdr_stream *);
-int nfs4_pnfs_return_layout(struct super_block *, struct svc_fh *,
-					struct nfsd4_pnfs_layoutreturn *);
+int nfs4_pnfs_return_layout(struct svc_rqst *, struct super_block *, struct svc_fh *, struct nfsd4_pnfs_layoutreturn *);
 int put_layoutrecall(struct nfs4_layoutrecall *);
 void nomatching_layout(struct nfs4_layoutrecall *);
 void *layoutrecall_done(struct nfs4_layoutrecall *);
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 2e5b600..5c613ba 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -510,7 +510,6 @@ extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(const char *name,
 extern void nfsd4_unhash_stid(struct nfs4_stid *);
 extern struct nfs4_stid *find_stateid(struct nfs4_client *, stateid_t *);
 extern __be32 nfsd4_lookup_stateid(stateid_t *, unsigned char typemask, struct nfs4_stid **, bool sessions, struct nfsd_net *);
-extern int filter_confirmed_clients(int (* func)(struct nfs4_client *, void *), void *);
 
 #if defined(CONFIG_PNFSD)
 extern int nfsd4_init_pnfs_slabs(void);
-- 
1.7.11.7

