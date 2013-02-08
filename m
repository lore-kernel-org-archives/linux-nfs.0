Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ia0-f179.google.com ([209.85.210.179]:44015 "EHLO
	mail-ia0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1947146Ab3BHV14 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Feb 2013 16:27:56 -0500
Received: by mail-ia0-f179.google.com with SMTP id x24so4681321iak.24
        for <linux-nfs@vger.kernel.org>; Fri, 08 Feb 2013 13:27:56 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v1 1/3] NFSD: Simplify GSS flavor encoding in
 nfsd4_do_encode_secinfo()
To: linux-nfs@vger.kernel.org
Cc: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 08 Feb 2013 16:27:54 -0500
Message-ID: <20130208212753.2234.91110.stgit@seurat.1015granger.net>
In-Reply-To: <20130208212007.2234.35721.stgit@seurat.1015granger.net>
References: <20130208212007.2234.35721.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfsd/nfs4xdr.c |    8 +-------
 1 files changed, 1 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 424f5a2..0c1ae2c 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3163,17 +3163,11 @@ nfsd4_do_encode_secinfo(struct nfsd4_compoundres *resp,
 		struct rpcsec_gss_info info;
 
 		if (rpcauth_get_gssinfo(flavs[i].pseudoflavor, &info) == 0) {
-			RESERVE_SPACE(4);
+			RESERVE_SPACE(4 + 4 + info.oid.len + 4 + 4);
 			WRITE32(RPC_AUTH_GSS);
-			ADJUST_ARGS();
-			RESERVE_SPACE(4 + info.oid.len);
 			WRITE32(info.oid.len);
 			WRITEMEM(info.oid.data, info.oid.len);
-			ADJUST_ARGS();
-			RESERVE_SPACE(4);
 			WRITE32(info.qop);
-			ADJUST_ARGS();
-			RESERVE_SPACE(4);
 			WRITE32(info.service);
 			ADJUST_ARGS();
 		} else {

