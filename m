Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f66.google.com ([209.85.192.66]:33122 "EHLO
	mail-qg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756202AbcEQQ3H (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 May 2016 12:29:07 -0400
Received: by mail-qg0-f66.google.com with SMTP id 90so1830913qgz.0
        for <linux-nfs@vger.kernel.org>; Tue, 17 May 2016 09:29:06 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: Trond Myklebust <trondmy@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Thomas Haynes <loghyr@primarydata.com>, linux-nfs@vger.kernel.org,
        hch@lst.de
Subject: [PATCH v4 10/13] pnfs: fix bad error handling in send_layoutget
Date: Tue, 17 May 2016 12:28:45 -0400
Message-Id: <1463502528-11519-11-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1463502528-11519-1-git-send-email-jeff.layton@primarydata.com>
References: <1463502528-11519-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, the code will clear the fail bit if we get back a fatal
error. I don't think that's correct -- we want to clear that bit
if we do not get a fatal error.

Fixes: 0bcbf039f6 (nfs: handle request add failure properly)
Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfs/pnfs.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index e6cad5ee5d29..eb90b3af3446 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -876,11 +876,16 @@ send_layoutget(struct pnfs_layout_hdr *lo,
 		lseg = nfs4_proc_layoutget(lgp, gfp_flags);
 	} while (lseg == ERR_PTR(-EAGAIN));
 
-	if (IS_ERR(lseg) && !nfs_error_is_fatal(PTR_ERR(lseg)))
-		lseg = NULL;
-	else
+	if (IS_ERR(lseg)) {
+		if (!nfs_error_is_fatal(PTR_ERR(lseg))) {
+			pnfs_layout_clear_fail_bit(lo,
+					pnfs_iomode_to_fail_bit(range->iomode));
+			lseg = NULL;
+		}
+	} else {
 		pnfs_layout_clear_fail_bit(lo,
 				pnfs_iomode_to_fail_bit(range->iomode));
+	}
 
 	return lseg;
 }
-- 
2.5.5

