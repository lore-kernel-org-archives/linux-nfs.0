Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F13A6C433F5
	for <linux-nfs@archiver.kernel.org>; Mon, 28 Mar 2022 02:49:07 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S237657AbiC1Cup (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 27 Mar 2022 22:50:45 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:53178 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S235045AbiC1Cuo (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Mar 2022 22:50:44 -0400
Received: from mail.meizu.com (unknown [14.29.68.187])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id DCF8B4199A;
        Sun, 27 Mar 2022 19:49:02 -0700 (PDT)
Received: from IT-EXMB-1-125.meizu.com (172.16.1.125) by mz-mail04.meizu.com
 (172.16.1.16) with Microsoft SMTP Server (TLS) id 14.3.487.0; Mon, 28 Mar
 2022 10:49:00 +0800
Received: from meizu.meizu.com (172.16.137.70) by IT-EXMB-1-125.meizu.com
 (172.16.1.125) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id 15.1.2308.14; Mon, 28 Mar
 2022 10:49:00 +0800
From:   Haowen Bai <baihaowen@meizu.com>
To:     <chuck.lever@oracle.com>
CC:     <linux-nfs@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        Haowen Bai <baihaowen@meizu.com>
Subject: [PATCH] SUNRPC: Return true/false (not 1/0) from bool functions
Date:   Mon, 28 Mar 2022 10:48:59 +0800
Message-ID: <1648435739-3034-1-git-send-email-baihaowen@meizu.com>
X-Mailer: git-send-email 2.7.4
MIME-Version: 1.0
Content-Type: text/plain
X-Originating-IP: [172.16.137.70]
X-ClientProxiedBy: IT-EXMB-1-125.meizu.com (172.16.1.125) To
 IT-EXMB-1-125.meizu.com (172.16.1.125)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Return boolean values ("true" or "false") instead of 1 or 0 from bool
functions.  This fixes the following warnings from coccicheck:

./fs/nfsd/nfs2acl.c:289:9-10: WARNING: return of 0/1 in function
'nfsaclsvc_encode_accessres' with return type bool
./fs/nfsd/nfs2acl.c:252:9-10: WARNING: return of 0/1 in function
'nfsaclsvc_encode_getaclres' with return type bool

Signed-off-by: Haowen Bai <baihaowen@meizu.com>
---
 fs/nfsd/nfs2acl.c | 24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
index 367551b..b576080 100644
--- a/fs/nfsd/nfs2acl.c
+++ b/fs/nfsd/nfs2acl.c
@@ -249,34 +249,34 @@ nfsaclsvc_encode_getaclres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 	int w;
 
 	if (!svcxdr_encode_stat(xdr, resp->status))
-		return 0;
+		return false;
 
 	if (dentry == NULL || d_really_is_negative(dentry))
-		return 1;
+		return true;
 	inode = d_inode(dentry);
 
 	if (!svcxdr_encode_fattr(rqstp, xdr, &resp->fh, &resp->stat))
-		return 0;
+		return false;
 	if (xdr_stream_encode_u32(xdr, resp->mask) < 0)
-		return 0;
+		return false;
 
 	rqstp->rq_res.page_len = w = nfsacl_size(
 		(resp->mask & NFS_ACL)   ? resp->acl_access  : NULL,
 		(resp->mask & NFS_DFACL) ? resp->acl_default : NULL);
 	while (w > 0) {
 		if (!*(rqstp->rq_next_page++))
-			return 1;
+			return true;
 		w -= PAGE_SIZE;
 	}
 
 	if (!nfs_stream_encode_acl(xdr, inode, resp->acl_access,
 				   resp->mask & NFS_ACL, 0))
-		return 0;
+		return false;
 	if (!nfs_stream_encode_acl(xdr, inode, resp->acl_default,
 				   resp->mask & NFS_DFACL, NFS_ACL_DEFAULT))
-		return 0;
+		return false;
 
-	return 1;
+	return true;
 }
 
 /* ACCESS */
@@ -286,17 +286,17 @@ nfsaclsvc_encode_accessres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 	struct nfsd3_accessres *resp = rqstp->rq_resp;
 
 	if (!svcxdr_encode_stat(xdr, resp->status))
-		return 0;
+		return false;
 	switch (resp->status) {
 	case nfs_ok:
 		if (!svcxdr_encode_fattr(rqstp, xdr, &resp->fh, &resp->stat))
-			return 0;
+			return false;
 		if (xdr_stream_encode_u32(xdr, resp->access) < 0)
-			return 0;
+			return false;
 		break;
 	}
 
-	return 1;
+	return true;
 }
 
 /*
-- 
2.7.4

