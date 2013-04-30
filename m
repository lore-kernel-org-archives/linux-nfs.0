Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f180.google.com ([209.85.223.180]:56033 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933885Ab3D3WtH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Apr 2013 18:49:07 -0400
Received: by mail-ie0-f180.google.com with SMTP id to1so1311600ieb.39
        for <linux-nfs@vger.kernel.org>; Tue, 30 Apr 2013 15:49:07 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/3] NFSD: Simplify GSS flavor encoding in
 nfsd4_do_encode_secinfo()
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Date: Tue, 30 Apr 2013 18:48:45 -0400
Message-ID: <20130430224845.21406.96490.stgit@seurat.1015granger.net>
In-Reply-To: <20130430224730.21406.27294.stgit@seurat.1015granger.net>
References: <20130430224730.21406.27294.stgit@seurat.1015granger.net>
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
index 2502951..ce327e3 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3174,17 +3174,11 @@ nfsd4_do_encode_secinfo(struct nfsd4_compoundres *resp,
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

