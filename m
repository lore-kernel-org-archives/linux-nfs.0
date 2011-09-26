Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:60616 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751046Ab1IZPaG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Sep 2011 11:30:06 -0400
Received: by mail-yw0-f46.google.com with SMTP id 5so4377130ywb.19
        for <linux-nfs@vger.kernel.org>; Mon, 26 Sep 2011 08:30:06 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/3] NFS: Clean up nfs4_xdr_dec_secinfo()
To: linux-nfs@vger.kernel.org
Cc: bjschuma@netapp.com, andros@netapp.com
Date: Mon, 26 Sep 2011 11:30:04 -0400
Message-ID: <20110926153004.8595.80144.stgit@degas.1015granger.net>
In-Reply-To: <20110926152657.8595.6375.stgit@degas.1015granger.net>
References: <20110926152657.8595.6375.stgit@degas.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

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

