Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:11394 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753328Ab0LNWDE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Dec 2010 17:03:04 -0500
Received: from localhost.localdomain (vpn2ntap-71744.hq.netapp.com [10.58.57.236])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oBEM32od010255
	for <linux-nfs@vger.kernel.org>; Tue, 14 Dec 2010 14:03:03 -0800 (PST)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/3] pnfs-submit: wave2: remove forgotten layoutreturn struct definitions
Date: Tue, 14 Dec 2010 17:02:58 -0500
Message-Id: <1292364180-28512-2-git-send-email-iisaman@netapp.com>
In-Reply-To: <1292364180-28512-1-git-send-email-iisaman@netapp.com>
References: <1292364180-28512-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 include/linux/nfs4.h    |    1 -
 include/linux/nfs_xdr.h |   23 -----------------------
 2 files changed, 0 insertions(+), 24 deletions(-)

diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 55511e8..8ca7700 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -557,7 +557,6 @@ enum {
 	NFSPROC4_CLNT_RECLAIM_COMPLETE,
 	NFSPROC4_CLNT_LAYOUTGET,
 	NFSPROC4_CLNT_LAYOUTCOMMIT,
-	NFSPROC4_CLNT_LAYOUTRETURN,
 	NFSPROC4_CLNT_GETDEVICEINFO,
 	NFSPROC4_CLNT_PNFS_WRITE,
 	NFSPROC4_CLNT_PNFS_COMMIT,
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index a651574..9d847ac 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -258,29 +258,6 @@ struct nfs4_layoutcommit_data {
 	int status;
 };
 
-struct nfs4_layoutreturn_args {
-	__u32   reclaim;
-	__u32   layout_type;
-	__u32   return_type;
-	struct pnfs_layout_range range;
-	struct inode *inode;
-	struct nfs4_sequence_args seq_args;
-};
-
-struct nfs4_layoutreturn_res {
-	struct nfs4_sequence_res seq_res;
-	u32 lrs_present;
-	nfs4_stateid stateid;
-};
-
-struct nfs4_layoutreturn {
-	struct nfs4_layoutreturn_args args;
-	struct nfs4_layoutreturn_res res;
-	struct rpc_cred *cred;
-	struct nfs_client *clp;
-	int rpc_status;
-};
-
 struct nfs4_getdeviceinfo_args {
 	struct pnfs_device *pdev;
 	struct nfs4_sequence_args seq_args;
-- 
1.7.2.1

