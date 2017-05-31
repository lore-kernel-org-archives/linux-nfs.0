Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from esa6.hgst.iphmx.com ([216.71.154.45]:6729 "EHLO
        esa6.hgst.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751075AbdEaVoE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 31 May 2017 17:44:04 -0400
From: Bart Van Assche <bart.vanassche@sandisk.com>
To: Jens Axboe <axboe@kernel.dk>
CC: <linux-block@vger.kernel.org>, Christoph Hellwig <hch@lst.de>,
        "Bart Van Assche" <bart.vanassche@sandisk.com>,
        "J . Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Omar Sandoval <osandov@fb.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 6/6] nfsd: Check queue type before submitting a SCSI request
Date: Wed, 31 May 2017 14:43:50 -0700
Message-ID: <20170531214350.31157-7-bart.vanassche@sandisk.com>
In-Reply-To: <20170531214350.31157-1-bart.vanassche@sandisk.com>
References: <20170531214350.31157-1-bart.vanassche@sandisk.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since using scsi_req() is only allowed against request queues for
which struct scsi_request is the first member of their private
request data, refuse to submit SCSI commands against a queue for
which this is not the case.

References: commit 82ed4db499b8 ("block: split scsi_request out of struct request")
Signed-off-by: Bart Van Assche <bart.vanassche@sandisk.com>
Reviewed-by: Hannes Reinecke <hare@suse.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Cc: J. Bruce Fields <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@poochiereds.net>
Cc: Omar Sandoval <osandov@fb.com>
Cc: linux-nfs@vger.kernel.org
---
 fs/nfsd/blocklayout.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfsd/blocklayout.c b/fs/nfsd/blocklayout.c
index fb5213afc854..47ed19c53f2e 100644
--- a/fs/nfsd/blocklayout.c
+++ b/fs/nfsd/blocklayout.c
@@ -219,6 +219,9 @@ static int nfsd4_scsi_identify_device(struct block_device *bdev,
 	u8 *buf, *d, type, assoc;
 	int error;
 
+	if (WARN_ON_ONCE(!blk_queue_scsi_passthrough(q)))
+		return -EINVAL;
+
 	buf = kzalloc(bufflen, GFP_KERNEL);
 	if (!buf)
 		return -ENOMEM;
-- 
2.12.2

