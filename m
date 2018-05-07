Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:43384 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751848AbeEGNBb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 7 May 2018 09:01:31 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: bfields@fieldses.org, jlayton@kernel.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: make nfsd4_scsi_identify_device retry with a larger buffer
Date: Mon,  7 May 2018 09:01:31 -0400
Message-Id: <20180507130131.7221-1-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfsd4_scsi_identify_device() performs a single IDENTIFY command for the
device identification VPD page using a small buffer.  If the reply is
too large to fit in this buffer then the GETDEVICEINFO reply will not
contain any info for the SCSI volume aside from the registration key.
This can happen for example if the device has descriptors using long
SCSI name strings.

When the initial reply from the device indicates a larger buffer is
needed, retry once using the page length from that reply.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 fs/nfsd/blocklayout.c | 18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/blocklayout.c b/fs/nfsd/blocklayout.c
index 70b8bf7..0cd9249 100644
--- a/fs/nfsd/blocklayout.c
+++ b/fs/nfsd/blocklayout.c
@@ -216,13 +216,14 @@ static int nfsd4_scsi_identify_device(struct block_device *bdev,
 	struct request_queue *q = bdev->bd_disk->queue;
 	struct request *rq;
 	struct scsi_request *req;
-	size_t bufflen = 252, len, id_len;
+	size_t bufflen = 252, maxlen = 65532, len, id_len;
 	u8 *buf, *d, type, assoc;
-	int error;
+	int retries = 1, error;
 
 	if (WARN_ON_ONCE(!blk_queue_scsi_passthrough(q)))
 		return -EINVAL;
 
+again:
 	buf = kzalloc(bufflen, GFP_KERNEL);
 	if (!buf)
 		return -ENOMEM;
@@ -255,9 +256,16 @@ static int nfsd4_scsi_identify_device(struct block_device *bdev,
 
 	len = (buf[2] << 8) + buf[3] + 4;
 	if (len > bufflen) {
-		pr_err("pNFS: INQUIRY 0x83 response invalid (len = %zd)\n",
-			len);
-		goto out_put_request;
+		if (len < maxlen && retries--) {
+			blk_put_request(rq);
+			kfree(buf);
+			bufflen = len;
+			goto again;
+		} else {
+			pr_err("pNFS: INQUIRY 0x83 response invalid (len = %zd)\n",
+				len);
+			goto out_put_request;
+		}
 	}
 
 	d = buf + 4;
-- 
2.9.5

