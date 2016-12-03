Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:34566 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751190AbcLCU6I (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 3 Dec 2016 15:58:08 -0500
Received: by mail-io0-f193.google.com with SMTP id r94so14855151ioe.1
        for <linux-nfs@vger.kernel.org>; Sat, 03 Dec 2016 12:57:29 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 01/10] pNFS/flexfiles: Don't attempt to send layoutstats if there are no entries
Date: Sat,  3 Dec 2016 15:57:16 -0500
Message-Id: <20161203205725.12961-2-trond.myklebust@primarydata.com>
In-Reply-To: <20161203205725.12961-1-trond.myklebust@primarydata.com>
References: <20161203205725.12961-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the list of mirrors is empty, then don't send an RPC call.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 90462a2a9237..a6264d6836dc 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -2250,6 +2250,11 @@ ff_layout_prepare_layoutstats(struct nfs42_layoutstat_args *args)
 	args->num_dev = ff_layout_mirror_prepare_stats(args,
 			&ff_layout->generic_hdr, dev_count);
 	spin_unlock(&args->inode->i_lock);
+	if (!args->num_dev) {
+		kfree(args->devinfo);
+		args->devinfo = NULL;
+		return -ENOENT;
+	}
 
 	return 0;
 }
-- 
2.9.3

