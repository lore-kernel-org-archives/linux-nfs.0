Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f176.google.com ([209.85.192.176]:60529 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751312AbaLPTDO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Dec 2014 14:03:14 -0500
Received: by mail-pd0-f176.google.com with SMTP id r10so12473882pdi.21
        for <linux-nfs@vger.kernel.org>; Tue, 16 Dec 2014 11:03:13 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <Trond.Myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 37/50] pnfs: fail comparison when bucket verifier not set
Date: Tue, 16 Dec 2014 11:01:40 -0800
Message-Id: <1418756513-95187-38-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1418756513-95187-1-git-send-email-loghyr@primarydata.com>
References: <1418756513-95187-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Weston Andros Adamson <dros@primarydata.com>

This skips the WARN_ON_ONCE, but doesnt change behavior (the memcmp would
fail).

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
Signed-off-by: Tom Haynes <Thomas.Haynes@primarydata.com>
---
 fs/nfs/direct.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 651387b..eb81478 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -222,7 +222,11 @@ static int nfs_direct_cmp_commit_data_verf(struct nfs_direct_req *dreq,
 
 	verfp = nfs_direct_select_verf(dreq, data->ds_clp,
 					 data->ds_commit_index);
-	WARN_ON_ONCE(verfp->committed < 0);
+
+	/* verifier not set so always fail */
+	if (verfp->committed < 0)
+		return 1;
+
 	return memcmp(verfp, &data->verf, sizeof(struct nfs_writeverf));
 }
 
-- 
1.9.3

