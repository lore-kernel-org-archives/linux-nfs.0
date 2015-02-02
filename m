Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f42.google.com ([209.85.220.42]:49656 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965072AbbBBWk5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Feb 2015 17:40:57 -0500
Received: by mail-pa0-f42.google.com with SMTP id bj1so88034780pad.1
        for <linux-nfs@vger.kernel.org>; Mon, 02 Feb 2015 14:40:57 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH v6 37/53] pnfs: fail comparison when bucket verifier not set
Date: Mon,  2 Feb 2015 14:38:51 -0800
Message-Id: <1422916747-86649-38-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1422916747-86649-1-git-send-email-loghyr@primarydata.com>
References: <1422916747-86649-1-git-send-email-loghyr@primarydata.com>
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
index 23ee1bc..c26cc22 100644
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

