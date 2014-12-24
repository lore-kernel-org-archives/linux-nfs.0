Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f174.google.com ([209.85.213.174]:33536 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751841AbaLXHOL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Dec 2014 02:14:11 -0500
Received: by mail-ig0-f174.google.com with SMTP id hn15so6575520igb.7
        for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2014 23:14:10 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <Trond.Myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 37/49] pnfs: fail comparison when bucket verifier not set
Date: Tue, 23 Dec 2014 23:13:16 -0800
Message-Id: <1419405208-25975-38-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1419405208-25975-1-git-send-email-loghyr@primarydata.com>
References: <1419405208-25975-1-git-send-email-loghyr@primarydata.com>
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

