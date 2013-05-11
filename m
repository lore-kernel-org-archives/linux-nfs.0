Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f46.google.com ([74.125.82.46]:61313 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756664Ab3EKCoj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 May 2013 22:44:39 -0400
Received: by mail-wg0-f46.google.com with SMTP id n12so4512607wgh.25
        for <linux-nfs@vger.kernel.org>; Fri, 10 May 2013 19:44:38 -0700 (PDT)
Received: from bhalevy-lt.il.tonian.com (bzq-79-180-144-28.red.bezeqint.net. [79.180.144.28])
        by mx.google.com with ESMTPSA id e8sm1219631wic.5.2013.05.10.19.44.37
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 10 May 2013 19:44:37 -0700 (PDT)
From: Benny Halevy <bhalevy@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 33/38] pnfsd: pass layout stateid down to fs on layoutget
Date: Sat, 11 May 2013 05:44:33 +0300
Message-Id: <1368240273-1007-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <518B6377.3000207@tonian.com>
References: <518B6377.3000207@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

rather than the clientid which is deprecated from the fs pnfs api

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/nfs4pnfsd.c             | 7 +++++--
 fs/nfsd/nfs4proc.c              | 3 +--
 fs/nfsd/xdr4.h                  | 1 +
 include/linux/nfsd/nfsd4_pnfs.h | 1 +
 4 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index 7a5ba09..1a65f85 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -691,7 +691,7 @@ struct super_block *
 
 	nfs4_lock_state();
 	fp = find_alloc_file(ino, lgp->lg_fhp);
-	clp = find_confirmed_client((clientid_t *)&lgp->lg_seg.clientid, true,
+	clp = find_confirmed_client(&lgp->lg_clientid, true,
 				    net_generic(SVC_NET(rqstp), nfsd_net_id));
 	dprintk("pNFS %s: fp %p clp %p\n", __func__, fp, clp);
 	if (!fp || !clp) {
@@ -718,10 +718,13 @@ struct super_block *
 		goto out_unlock;
 	}
 
+	memcpy(&args.lg_sid, &lgp->lg_sid, sizeof(args.lg_sid));
+
 	dprintk("pNFS %s: pre-export type 0x%x maxcount %Zd "
-		"iomode %u offset %llu length %llu\n",
+		"ls %p stateid " STATEID_FMT " iomode %u offset %llu length %llu\n",
 		__func__, lgp->lg_seg.layout_type,
 		exp_xdr_qbytes(xdr->end - xdr->p),
+		ls, STATEID_VAL(&lgp->lg_sid),
 		lgp->lg_seg.iomode, lgp->lg_seg.offset, lgp->lg_seg.length);
 
 	/* FIXME: need to eliminate the use of the state lock */
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 4fd5549..e962dc6 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1193,9 +1193,8 @@ static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
 		goto out;
 	}
 
-	/* Set up arguments so layout can be retrieved at encode time */
 	lgp->lg_fhp = current_fh;
-	copy_clientid((clientid_t *)&lgp->lg_seg.clientid, cstate->session);
+	copy_clientid(&lgp->lg_clientid, cstate->session);
 	status = nfs_ok;
 out:
 	return status;
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 459d8ba..1862b16 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -452,6 +452,7 @@ struct nfsd4_pnfs_layoutget {
 	stateid_t		lg_sid;		/* request/response */
 	struct nfsd4_layout_seg	lg_seg;		/* request/response */
 	u32			lg_roc;		/* response */
+	clientid_t		lg_clientid;
 };
 
 struct nfsd4_pnfs_layoutcommit {
diff --git a/include/linux/nfsd/nfsd4_pnfs.h b/include/linux/nfsd/nfsd4_pnfs.h
index a10bcf2..2f311ac 100644
--- a/include/linux/nfsd/nfsd4_pnfs.h
+++ b/include/linux/nfsd/nfsd4_pnfs.h
@@ -81,6 +81,7 @@ struct nfsd4_pnfs_layoutget_arg {
 	u64			lg_minlength;
 	u64			lg_sbid;
 	const struct knfsd_fh	*lg_fh;
+	nfs4_stateid		lg_sid;
 };
 
 struct nfsd4_pnfs_layoutget_res {
-- 
1.7.11.7

