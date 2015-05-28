Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:35486 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751169AbbE1EEO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 May 2015 00:04:14 -0400
Received: by pacwv17 with SMTP id wv17so13559633pac.2
        for <linux-nfs@vger.kernel.org>; Wed, 27 May 2015 21:04:13 -0700 (PDT)
Message-ID: <556693B7.6040501@gmail.com>
Date: Thu, 28 May 2015 12:04:07 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Steve Dickson <SteveD@redhat.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@infradead.org>, kinglongmee@gmail.com
Subject: [PATCH] blkmapd: Fix infinite loop when reading serial
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If (dev_id->ids & 0xf) < current_id, must updates pos when continue.
Otherwise an infinite loop.

No other places use the pos value, just move to the top of while.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 utils/blkmapd/device-inq.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/utils/blkmapd/device-inq.c b/utils/blkmapd/device-inq.c
index c5bf71f..6b56b67 100644
--- a/utils/blkmapd/device-inq.c
+++ b/utils/blkmapd/device-inq.c
@@ -196,6 +196,8 @@ struct bl_serial *bldev_read_serial(int fd, const char *filename)
 
 	while (pos < (len - devid_len)) {
 		dev_id = (struct bl_dev_id *)&(dev_root->data[pos]);
+		pos += (dev_id->len + devid_len);
+
 		if ((dev_id->ids & 0xf) < current_id)
 			continue;
 		switch (dev_id->ids & 0xf) {
@@ -226,7 +228,6 @@ struct bl_serial *bldev_read_serial(int fd, const char *filename)
 		}
 		if (current_id == 3)
 			break;
-		pos += (dev_id->len + devid_len);
 	}
  out:
 	if (!serial_out)
-- 
2.4.1

