Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:36819 "EHLO
	mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932195AbcEKKVf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 May 2016 06:21:35 -0400
Received: by mail-qk0-f193.google.com with SMTP id l68so2731135qkf.3
        for <linux-nfs@vger.kernel.org>; Wed, 11 May 2016 03:21:30 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: Trond Myklebust <trondmy@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 7/9] pnfs: fix bad error handling in send_layoutget
Date: Wed, 11 May 2016 06:21:12 -0400
Message-Id: <1462962074-6989-8-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1462962074-6989-1-git-send-email-jeff.layton@primarydata.com>
References: <1462962074-6989-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, the code will clear the fail bit if we get back a fatal
error. I don't think that's correct -- we only want to clear that
bit if the layoutget succeeds.

Fixes: 0bcbf039f6 (nfs: handle request add failure properly)
Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfs/pnfs.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index e6cad5ee5d29..5f6ed295acb5 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -876,11 +876,13 @@ send_layoutget(struct pnfs_layout_hdr *lo,
 		lseg = nfs4_proc_layoutget(lgp, gfp_flags);
 	} while (lseg == ERR_PTR(-EAGAIN));
 
-	if (IS_ERR(lseg) && !nfs_error_is_fatal(PTR_ERR(lseg)))
-		lseg = NULL;
-	else
+	if (IS_ERR(lseg)) {
+		if (!nfs_error_is_fatal(PTR_ERR(lseg)))
+			lseg = NULL;
+	} else {
 		pnfs_layout_clear_fail_bit(lo,
 				pnfs_iomode_to_fail_bit(range->iomode));
+	}
 
 	return lseg;
 }
-- 
2.5.5

