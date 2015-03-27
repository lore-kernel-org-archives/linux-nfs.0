Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:33358 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751952AbbC0RH4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Mar 2015 13:07:56 -0400
Received: by iecvj10 with SMTP id vj10so75602078iec.0
        for <linux-nfs@vger.kernel.org>; Fri, 27 Mar 2015 10:07:56 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] NFSv4.1/pnfs: Ensure we send layoutcommit before return-on-close
Date: Fri, 27 Mar 2015 13:07:53 -0400
Message-Id: <1427476074-14736-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We must not send a close or delegreturn that would result in a
return-on-close of the layout without ensuring that we've also
sent the necessary layoutcommit.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index ea83f3c03c65..c2ce2db771b7 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1090,6 +1090,7 @@ bool pnfs_roc(struct inode *ino)
 	pnfs_get_layout_hdr(lo); /* matched in pnfs_roc_release */
 	spin_unlock(&ino->i_lock);
 	pnfs_free_lseg_list(&tmp_list);
+	pnfs_layoutcommit_inode(ino, true);
 	return true;
 
 out_noroc:
@@ -1104,8 +1105,10 @@ out_noroc:
 		}
 	}
 	spin_unlock(&ino->i_lock);
-	if (layoutreturn)
+	if (layoutreturn) {
+		pnfs_layoutcommit_inode(ino, true);
 		pnfs_send_layoutreturn(lo, stateid, IOMODE_ANY, true);
+	}
 	return false;
 }
 
-- 
2.1.0

