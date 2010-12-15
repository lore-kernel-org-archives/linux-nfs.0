Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:47205 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752103Ab0LOSbA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Dec 2010 13:31:00 -0500
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/9] Revert "pnfs-submit: wave2: remove forgotten layoutreturn struct definitions"
Date: Wed, 15 Dec 2010 20:30:54 +0200
Message-Id: <1292437854-21651-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4D0908F9.4060208@panasas.com>
References: <4D0908F9.4060208@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This reverts commit 19e1e5ae1ec0a3f5d997a1a5d924d482e147bea2.
---
 include/linux/nfs4.h    |    1 +
 include/linux/nfs_xdr.h |   23 +++++++++++++++++++++++
 2 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 8ca7700..55511e8 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -557,6 +557,7 @@ enum {
 	NFSPROC4_CLNT_RECLAIM_COMPLETE,
 	NFSPROC4_CLNT_LAYOUTGET,
 	NFSPROC4_CLNT_LAYOUTCOMMIT,
+	NFSPROC4_CLNT_LAYOUTRETURN,
 	NFSPROC4_CLNT_GETDEVICEINFO,
 	NFSPROC4_CLNT_PNFS_WRITE,
 	NFSPROC4_CLNT_PNFS_COMMIT,
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 9d847ac..a651574 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -258,6 +258,29 @@ struct nfs4_layoutcommit_data {
 	int status;
 };
 
+struct nfs4_layoutreturn_args {
+	__u32   reclaim;
+	__u32   layout_type;
+	__u32   return_type;
+	struct pnfs_layout_range range;
+	struct inode *inode;
+	struct nfs4_sequence_args seq_args;
+};
+
+struct nfs4_layoutreturn_res {
+	struct nfs4_sequence_res seq_res;
+	u32 lrs_present;
+	nfs4_stateid stateid;
+};
+
+struct nfs4_layoutreturn {
+	struct nfs4_layoutreturn_args args;
+	struct nfs4_layoutreturn_res res;
+	struct rpc_cred *cred;
+	struct nfs_client *clp;
+	int rpc_status;
+};
+
 struct nfs4_getdeviceinfo_args {
 	struct pnfs_device *pdev;
 	struct nfs4_sequence_args seq_args;
-- 
1.7.2.3

