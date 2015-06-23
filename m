Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:33131 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753097AbbFWLwd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Jun 2015 07:52:33 -0400
Received: by pdjn11 with SMTP id n11so5920027pdj.0
        for <linux-nfs@vger.kernel.org>; Tue, 23 Jun 2015 04:52:33 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-nfs <linux-nfs@vger.kernel.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH-v2 03/10] pnfs: add pnfs_report_layoutstat helper function
Date: Tue, 23 Jun 2015 19:51:57 +0800
Message-Id: <1435060324-13279-4-git-send-email-tao.peng@primarydata.com>
In-Reply-To: <1435060324-13279-1-git-send-email-tao.peng@primarydata.com>
References: <1435060324-13279-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Reviewed-by: Jeff Layton <jeff.layton@primarydata.com>
Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/nfs42proc.c |  4 ++++
 fs/nfs/pnfs.c      | 49 +++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/pnfs.h      |  3 +++
 3 files changed, 56 insertions(+)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index a053041..ee02483 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -198,6 +198,10 @@ static void
 nfs42_layoutstat_release(void *calldata)
 {
 	struct nfs42_layoutstat_data *data = calldata;
+	struct nfs_server *nfss = NFS_SERVER(data->args.inode);
+
+	if (nfss->pnfs_curr_ld->cleanup_layoutstats)
+		nfss->pnfs_curr_ld->cleanup_layoutstats(data);
 
 	pnfs_put_layout_hdr(NFS_I(data->args.inode)->layout);
 	nfs_iput_and_deactive(data->inode);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 2306062..389f7c9 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -35,6 +35,7 @@
 #include "iostat.h"
 #include "nfs4trace.h"
 #include "delegation.h"
+#include "nfs42.h"
 
 #define NFSDBG_FACILITY		NFSDBG_PNFS
 #define PNFS_LAYOUTGET_RETRY_TIMEOUT (120*HZ)
@@ -2247,3 +2248,51 @@ struct nfs4_threshold *pnfs_mdsthreshold_alloc(void)
 	}
 	return thp;
 }
+
+int
+pnfs_report_layoutstat(struct inode *inode)
+{
+	struct pnfs_layoutdriver_type *ld = NFS_SERVER(inode)->pnfs_curr_ld;
+	struct nfs_server *server = NFS_SERVER(inode);
+	struct nfs42_layoutstat_data *data;
+	struct pnfs_layout_hdr *hdr;
+	int status = 0;
+
+	if (!pnfs_enabled_sb(server) || !ld->prepare_layoutstats)
+		goto out;
+
+	spin_lock(&inode->i_lock);
+	if (!NFS_I(inode)->layout) {
+		spin_unlock(&inode->i_lock);
+		goto out;
+	}
+	hdr = NFS_I(inode)->layout;
+	pnfs_get_layout_hdr(hdr);
+	spin_unlock(&inode->i_lock);
+
+	data = kzalloc(sizeof(*data), GFP_KERNEL);
+	if (!data) {
+		status = -ENOMEM;
+		goto out_put;
+	}
+
+	data->args.fh = NFS_FH(inode);
+	data->args.inode = inode;
+	nfs4_stateid_copy(&data->args.stateid, &hdr->plh_stateid);
+	status = ld->prepare_layoutstats(&data->args);
+	if (status)
+		goto out_free;
+
+	status = nfs42_proc_layoutstats_generic(NFS_SERVER(inode), data);
+
+out:
+	dprintk("%s returns %d\n", __func__, status);
+	return status;
+
+out_free:
+	kfree(data);
+out_put:
+	pnfs_put_layout_hdr(hdr);
+	goto out;
+}
+EXPORT_SYMBOL_GPL(pnfs_report_layoutstat);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 1e6308f..0a47239 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -178,6 +178,8 @@ struct pnfs_layoutdriver_type {
 	void (*encode_layoutcommit) (struct pnfs_layout_hdr *lo,
 				     struct xdr_stream *xdr,
 				     const struct nfs4_layoutcommit_args *args);
+	int (*prepare_layoutstats) (struct nfs42_layoutstat_args *args);
+	void (*cleanup_layoutstats) (struct nfs42_layoutstat_data *data);
 };
 
 struct pnfs_layout_hdr {
@@ -290,6 +292,7 @@ int pnfs_write_done_resend_to_mds(struct nfs_pgio_header *);
 struct nfs4_threshold *pnfs_mdsthreshold_alloc(void);
 void pnfs_error_mark_layout_for_return(struct inode *inode,
 				       struct pnfs_layout_segment *lseg);
+int pnfs_report_layoutstat(struct inode *inode);
 
 /* nfs4_deviceid_flags */
 enum {
-- 
1.8.3.1

