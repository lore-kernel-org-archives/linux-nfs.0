Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:36091 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751281AbbGLX53 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 12 Jul 2015 19:57:29 -0400
Received: by pdjr16 with SMTP id r16so52249411pdj.3
        for <linux-nfs@vger.kernel.org>; Sun, 12 Jul 2015 16:57:29 -0700 (PDT)
Message-ID: <55A2FEE4.6030201@gmail.com>
Date: Mon, 13 Jul 2015 07:57:24 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Steve Dickson <SteveD@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: Christoph Hellwig <hch@infradead.org>, kinglongmee@gmail.com
Subject: [PATCH] blkmapd: Skip the SCSI ID if the data length is zero
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In vmware linux, the iscsi device contains more than one SCSI ID,
and, the second one's data length is zero.

blkmapd must skip it, otherwise, some device will be treat as the above one.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 utils/blkmapd/device-inq.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/utils/blkmapd/device-inq.c b/utils/blkmapd/device-inq.c
index 6b56b67..57fe7a3 100644
--- a/utils/blkmapd/device-inq.c
+++ b/utils/blkmapd/device-inq.c
@@ -198,7 +198,7 @@ struct bl_serial *bldev_read_serial(int fd, const char *filename)
 		dev_id = (struct bl_dev_id *)&(dev_root->data[pos]);
 		pos += (dev_id->len + devid_len);
 
-		if ((dev_id->ids & 0xf) < current_id)
+		if ((dev_id->ids & 0xf) < current_id || !dev_id->len)
 			continue;
 		switch (dev_id->ids & 0xf) {
 			/* We process SCSI ID with four ID cases: 0, 1, 2 and 3.
-- 
2.4.3

