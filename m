Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:33538 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756554AbbFPOtQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Jun 2015 10:49:16 -0400
Received: by pdjn11 with SMTP id n11so16063792pdj.0
        for <linux-nfs@vger.kernel.org>; Tue, 16 Jun 2015 07:49:15 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-nfs <linux-nfs@vger.kernel.org>
Cc: Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH 09/11] pnfs/flexfiles: reset IO statistics upon LAYOUTSTATS success
Date: Tue, 16 Jun 2015 22:47:30 +0800
Message-Id: <1434466052-10491-10-git-send-email-tao.peng@primarydata.com>
In-Reply-To: <1434466052-10491-1-git-send-email-tao.peng@primarydata.com>
References: <1434466052-10491-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Per RFC NFSv42 draft, client MUST reset the statistics after getting
a successfully reply from the metadata server.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 64beedd..4b79c74 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1881,6 +1881,14 @@ ff_layout_cleanup_layoutstats(struct nfs42_layoutstat_data *data)
 	for (i = 0; i < data->args.num_dev; i++) {
 		mirror = data->args.devinfo[i].layout_private;
 		data->args.devinfo[i].layout_private = NULL;
+		if (data->res.rpc_status == NFS4_OK) {
+			spin_lock(&mirror->lock);
+			memset(&mirror->read_stat.io_stat, 0,
+				sizeof(mirror->read_stat.io_stat));
+			memset(&mirror->write_stat.io_stat, 0,
+				sizeof(mirror->write_stat.io_stat));
+			spin_unlock(&mirror->lock);
+		}
 		pnfs_put_lseg(mirror->lseg);
 	}
 }
-- 
1.8.3.1

