Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f46.google.com ([209.85.213.46]:62181 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750918Ab1JYQR4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Oct 2011 12:17:56 -0400
Received: by mail-yw0-f46.google.com with SMTP id 3so650637ywm.19
        for <linux-nfs@vger.kernel.org>; Tue, 25 Oct 2011 09:17:56 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/3] NFS: Clean up nfs4_xdr_dec_secinfo()
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 25 Oct 2011 12:17:53 -0400
Message-ID: <20111025161753.5996.83383.stgit@seurat.1015granger.net>
In-Reply-To: <20111025161631.5996.30680.stgit@seurat.1015granger.net>
References: <20111025161631.5996.30680.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Remove superfluous logic at the tail of
nfs4_xdr_dec_secinfo() .

Introduced by commit 5a5ea0d4 "NFS: Add secinfo procedure" (March 24,
2011).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4xdr.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 1dce12f..e6161b2 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -6602,8 +6602,6 @@ static int nfs4_xdr_dec_secinfo(struct rpc_rqst *rqstp,
 	if (status)
 		goto out;
 	status = decode_secinfo(xdr, res);
-	if (status)
-		goto out;
 out:
 	return status;
 }

