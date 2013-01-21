Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ea0-f172.google.com ([209.85.215.172]:46533 "EHLO
	mail-ea0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752612Ab3AUOy0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jan 2013 09:54:26 -0500
Received: by mail-ea0-f172.google.com with SMTP id f13so2561662eaa.3
        for <linux-nfs@vger.kernel.org>; Mon, 21 Jan 2013 06:54:25 -0800 (PST)
From: Benny Halevy <bhalevy@tonian.com>
To: linux-nfs@vger.kernel.org
Cc: Benny Halevy <bhalevy@tonian.com>
Subject: [PATCH 2/9] SQUASHME: pnfsd: return_on_close all layout segments
Date: Mon, 21 Jan 2013 16:54:22 +0200
Message-Id: <1358780062-5936-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <50FD5646.4020206@tonian.com>
References: <50FD5646.4020206@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As per errata #3226
http://www.rfc-editor.org/errata_search.php?rfc=5661
return_on_close refers to all segments acquired by the client
not only those marked with logr_return_on_close

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/nfs4pnfsd.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index 5c50d8a..fe3f693 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -1242,7 +1242,7 @@ void pnfsd_roc(struct nfs4_client *clp, struct nfs4_file *fp)
 		bool empty;
 
 		/* Check for a match */
-		if (!lo->lo_state->ls_roc || lo->lo_client != clp)
+		if (lo->lo_client != clp)
 			continue;
 
 		/* Return the layout */
-- 
1.7.11.7

