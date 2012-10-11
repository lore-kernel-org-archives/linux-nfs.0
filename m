Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:43586 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754856Ab2JKUlJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Oct 2012 16:41:09 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] NFSv4.1: Use kcalloc() to allocate zeroed arrays instead of kzalloc()
Date: Thu, 11 Oct 2012 16:40:31 -0400
Message-Id: <1349988031-1122-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1349988031-1122-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1349988031-1122-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Don't circumvent the array size checks.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4filelayout.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index e7aee56..2e45fd9 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -750,7 +750,7 @@ filelayout_decode_layout(struct pnfs_layout_hdr *flo,
 		goto out_err;
 
 	if (fl->num_fh > 0) {
-		fl->fh_array = kzalloc(fl->num_fh * sizeof(struct nfs_fh *),
+		fl->fh_array = kcalloc(fl->num_fh, sizeof(fl->fh_array[0]),
 				       gfp_flags);
 		if (!fl->fh_array)
 			goto out_err;
-- 
1.7.11.7

