Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:33084 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752517AbdAZU51 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jan 2017 15:57:27 -0500
Received: by mail-it0-f65.google.com with SMTP id e137so6348198itc.0
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jan 2017 12:57:05 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] pNFS: Fix a reference leak in _pnfs_return_layout
Date: Thu, 26 Jan 2017 15:57:02 -0500
Message-Id: <20170126205702.7263-1-trond.myklebust@primarydata.com>
In-Reply-To: <CAN-5tyEo-VS6y1-WVJMDXSzN2vxDtJOSckiYK=HmqLyPvBpWFQ@mail.gmail.com>
References: <CAN-5tyEo-VS6y1-WVJMDXSzN2vxDtJOSckiYK=HmqLyPvBpWFQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

IF NFS_LAYOUT_RETURN_REQUESTED is not set, then we currently exit
without freeing the list of invalidated layout segments, leading
to a reference leak.

Reported-by: Olga Kornievskaia <aglo@umich.edu>
Fixes: 24408f5282 ("pNFS: Fix bugs in _pnfs_return_layout")
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 59554f3adf29..dd042498ce7c 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1200,10 +1200,10 @@ _pnfs_return_layout(struct inode *ino)
 
 	send = pnfs_prepare_layoutreturn(lo, &stateid, NULL);
 	spin_unlock(&ino->i_lock);
-	pnfs_free_lseg_list(&tmp_list);
 	if (send)
 		status = pnfs_send_layoutreturn(lo, &stateid, IOMODE_ANY, true);
 out_put_layout_hdr:
+	pnfs_free_lseg_list(&tmp_list);
 	pnfs_put_layout_hdr(lo);
 out:
 	dprintk("<-- %s status: %d\n", __func__, status);
-- 
2.9.3

