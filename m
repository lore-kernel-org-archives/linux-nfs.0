Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:32963 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754032AbbHJIsR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Aug 2015 04:48:17 -0400
Received: by pdrh1 with SMTP id h1so51168862pdr.0
        for <linux-nfs@vger.kernel.org>; Mon, 10 Aug 2015 01:48:17 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Peng Tao <tao.peng@primarydata.com>,
        Tom Haynes <thomas.haynes@primarydata.com>
Subject: [PATCH] pnfs/flexfiles: LAYOUTSTATS ii_count should be ops instead of bytes
Date: Mon, 10 Aug 2015 16:47:32 +0800
Message-Id: <1439196452-44553-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Turned out I misinterpreted the spec...

Cc: Tom Haynes <thomas.haynes@primarydata.com>
Reported-by: Jean Spector <jean@primarydata.com>
Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index e69860c..ba388e9 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1866,10 +1866,9 @@ ff_layout_mirror_prepare_stats(struct nfs42_layoutstat_args *args,
 		memcpy(&devinfo->dev_id, &dev->deviceid, NFS4_DEVICEID4_SIZE);
 		devinfo->offset = pls->pls_range.offset;
 		devinfo->length = pls->pls_range.length;
-		/* well, we don't really know if IO is continuous or not! */
-		devinfo->read_count = mirror->read_stat.io_stat.bytes_completed;
+		devinfo->read_count = mirror->read_stat.io_stat.ops_completed;
 		devinfo->read_bytes = mirror->read_stat.io_stat.bytes_completed;
-		devinfo->write_count = mirror->write_stat.io_stat.bytes_completed;
+		devinfo->write_count = mirror->write_stat.io_stat.ops_completed;
 		devinfo->write_bytes = mirror->write_stat.io_stat.bytes_completed;
 		devinfo->layout_type = LAYOUT_FLEX_FILES;
 		devinfo->layoutstats_encode = ff_layout_encode_layoutstats;
-- 
1.8.3.1

