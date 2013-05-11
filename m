Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f50.google.com ([74.125.82.50]:33497 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756664Ab3EKCon (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 May 2013 22:44:43 -0400
Received: by mail-wg0-f50.google.com with SMTP id m15so4731251wgh.29
        for <linux-nfs@vger.kernel.org>; Fri, 10 May 2013 19:44:41 -0700 (PDT)
Received: from bhalevy-lt.il.tonian.com (bzq-79-180-144-28.red.bezeqint.net. [79.180.144.28])
        by mx.google.com with ESMTPSA id g8sm1389664wiy.4.2013.05.10.19.44.41
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 10 May 2013 19:44:41 -0700 (PDT)
From: Benny Halevy <bhalevy@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 34/38] pnfsd: pass layout stateid down to fs on layoutreturn
Date: Sat, 11 May 2013 05:44:37 +0300
Message-Id: <1368240277-1045-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <518B6377.3000207@tonian.com>
References: <518B6377.3000207@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

rather than the clientid which is deprecated from the fs pnfs api

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/nfs4pnfsd.c             | 8 +++++---
 fs/nfsd/nfs4proc.c              | 2 +-
 fs/nfsd/nfs4xdr.c               | 4 ++--
 fs/nfsd/xdr4.h                  | 2 +-
 include/linux/nfsd/nfsd4_pnfs.h | 1 +
 5 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index 1a65f85..0b256f5 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -927,7 +927,7 @@ struct super_block *
 			lrp->lrs_present = 1;
 	}
 	if (ls && layouts_found && lrp->lrs_present)
-		update_layout_stateid_locked(ls, &lrp->lr_sid);
+		update_layout_stateid_locked(ls, (stateid_t *)&lrp->args.lr_sid);
 	spin_unlock(&layout_lock);
 
 	return layouts_found;
@@ -1035,7 +1035,7 @@ int nfs4_pnfs_return_layout(struct svc_rqst *rqstp,
 	dprintk("NFSD: %s\n", __func__);
 
 	nfs4_lock_state();
-	clp = find_confirmed_client((clientid_t *)&lrp->args.lr_seg.clientid,
+	clp = find_confirmed_client(&lrp->lr_clientid,
 				    true, net_generic(SVC_NET(rqstp), nfsd_net_id));
 	if (!clp)
 		goto out;
@@ -1058,7 +1058,9 @@ int nfs4_pnfs_return_layout(struct svc_rqst *rqstp,
 
 		/* Check the stateid */
 		dprintk("%s PROCESS LO_STATEID inode %p\n", __func__, ino);
-		status = nfs4_process_layout_stateid(clp, fp, &lrp->lr_sid, &ls, false);
+		status = nfs4_process_layout_stateid(clp, fp,
+						     (stateid_t *)&lrp->args.lr_sid,
+						     &ls, false);
 		if (status)
 			goto out_put_file;
 
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index e962dc6..cd52393 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1324,7 +1324,7 @@ static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
 	}
 
 	/* Set clientid from sessionid */
-	copy_clientid((clientid_t *)&lrp->args.lr_seg.clientid, cstate->session);
+	copy_clientid(&lrp->lr_clientid, cstate->session);
 	lrp->lrs_present = 0;
 	status = nfs4_pnfs_return_layout(rqstp, sb, current_fh, lrp);
 out:
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 992e425..070e25a 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1560,7 +1560,7 @@ static __be32 nfsd4_decode_reclaim_complete(struct nfsd4_compoundargs *argp, str
 		READ_BUF(16);
 		READ64(lrp->args.lr_seg.offset);
 		READ64(lrp->args.lr_seg.length);
-		nfsd4_decode_stateid(argp, &lrp->lr_sid);
+		nfsd4_decode_stateid(argp, (stateid_t *)&lrp->args.lr_sid);
 		READ_BUF(4);
 		READ32(lrp->args.lrf_body_len);
 		if (lrp->args.lrf_body_len > 0) {
@@ -3925,7 +3925,7 @@ static __be32 nfsd4_encode_bind_conn_to_session(struct nfsd4_compoundres *resp,
 	WRITE32(lrp->lrs_present != 0);    /* got stateid? */
 	ADJUST_ARGS();
 	if (lrp->lrs_present)
-		nfsd4_encode_stateid(resp, &lrp->lr_sid);
+		nfsd4_encode_stateid(resp, (stateid_t *)&lrp->args.lr_sid);
 out:
 	return nfserr;
 }
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 1862b16..802a151 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -463,7 +463,7 @@ struct nfsd4_pnfs_layoutcommit {
 
 struct nfsd4_pnfs_layoutreturn {
 	struct nfsd4_pnfs_layoutreturn_arg args;
-	stateid_t		lr_sid;		/* request/resopnse */
+	clientid_t		lr_clientid;	/* request */
 	u32			lrs_present;	/* response */
 };
 
diff --git a/include/linux/nfsd/nfsd4_pnfs.h b/include/linux/nfsd/nfsd4_pnfs.h
index 2f311ac..2e09065 100644
--- a/include/linux/nfsd/nfsd4_pnfs.h
+++ b/include/linux/nfsd/nfsd4_pnfs.h
@@ -117,6 +117,7 @@ struct nfsd4_pnfs_layoutreturn_arg {
 	u32			lr_reclaim;	/* request */
 	u32			lrf_body_len;	/* request */
 	void			*lrf_body;	/* request */
+	nfs4_stateid		lr_sid;		/* request/response */
 	void			*lr_cookie;	/* fs private */
 	enum layoutreturn_flags	lr_flags;	/* internal flags */
 };
-- 
1.7.11.7

