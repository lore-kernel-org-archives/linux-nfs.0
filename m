Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:34614 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751317AbcLCU6I (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 3 Dec 2016 15:58:08 -0500
Received: by mail-io0-f193.google.com with SMTP id r94so14855529ioe.1
        for <linux-nfs@vger.kernel.org>; Sat, 03 Dec 2016 12:57:36 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 08/10] NFS: Fix up read of mirror stats
Date: Sat,  3 Dec 2016 15:57:23 -0500
Message-Id: <20161203205725.12961-9-trond.myklebust@primarydata.com>
In-Reply-To: <20161203205725.12961-8-trond.myklebust@primarydata.com>
References: <20161203205725.12961-1-trond.myklebust@primarydata.com>
 <20161203205725.12961-2-trond.myklebust@primarydata.com>
 <20161203205725.12961-3-trond.myklebust@primarydata.com>
 <20161203205725.12961-4-trond.myklebust@primarydata.com>
 <20161203205725.12961-5-trond.myklebust@primarydata.com>
 <20161203205725.12961-6-trond.myklebust@primarydata.com>
 <20161203205725.12961-7-trond.myklebust@primarydata.com>
 <20161203205725.12961-8-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Need to lock while reading in order to ensure 64-bit reads are correct.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index f61df1641567..c18afd5cc0bb 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -2250,10 +2250,12 @@ ff_layout_mirror_prepare_stats(struct pnfs_layout_hdr *lo,
 		memcpy(&devinfo->dev_id, &dev->deviceid, NFS4_DEVICEID4_SIZE);
 		devinfo->offset = 0;
 		devinfo->length = NFS4_MAX_UINT64;
+		spin_lock(&mirror->lock);
 		devinfo->read_count = mirror->read_stat.io_stat.ops_completed;
 		devinfo->read_bytes = mirror->read_stat.io_stat.bytes_completed;
 		devinfo->write_count = mirror->write_stat.io_stat.ops_completed;
 		devinfo->write_bytes = mirror->write_stat.io_stat.bytes_completed;
+		spin_unlock(&mirror->lock);
 		devinfo->layout_type = LAYOUT_FLEX_FILES;
 		devinfo->layoutstats_encode = ff_layout_encode_layoutstats;
 		devinfo->layout_private = mirror;
-- 
2.9.3

