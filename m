Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:33173 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751685AbbCVNXJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 22 Mar 2015 09:23:09 -0400
Received: by pdnc3 with SMTP id c3so158875777pdn.0
        for <linux-nfs@vger.kernel.org>; Sun, 22 Mar 2015 06:23:09 -0700 (PDT)
Message-ID: <550EC233.9090908@gmail.com>
Date: Sun, 22 Mar 2015 21:22:59 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Steve Dickson <SteveD@redhat.com>
CC: rees@umich.edu, Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH] blkmapd: Make sure device root contains valid device id
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When testing pnfs in virtual linux based on VirtualBox,
blkmapd gets dev_root->len == 0, which causes it Segmentation fault.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 utils/blkmapd/device-inq.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/utils/blkmapd/device-inq.c b/utils/blkmapd/device-inq.c
index eabc70c..c5bf71f 100644
--- a/utils/blkmapd/device-inq.c
+++ b/utils/blkmapd/device-inq.c
@@ -179,6 +179,7 @@ struct bl_serial *bldev_read_serial(int fd, const char *filename)
 	char *buffer;
 	struct bl_dev_id *dev_root, *dev_id;
 	unsigned int pos, len, current_id = 0;
+	size_t devid_len = sizeof(struct bl_dev_id) - sizeof(unsigned char);
 
 	status = bldev_inquire_pages(fd, 0x83, &buffer);
 	if (status)
@@ -189,7 +190,11 @@ struct bl_serial *bldev_read_serial(int fd, const char *filename)
 	pos = 0;
 	current_id = 0;
 	len = dev_root->len;
-	while (pos < (len - sizeof(struct bl_dev_id) + sizeof(unsigned char))) {
+
+	if (len < devid_len)
+		goto out;
+
+	while (pos < (len - devid_len)) {
 		dev_id = (struct bl_dev_id *)&(dev_root->data[pos]);
 		if ((dev_id->ids & 0xf) < current_id)
 			continue;
@@ -221,8 +226,7 @@ struct bl_serial *bldev_read_serial(int fd, const char *filename)
 		}
 		if (current_id == 3)
 			break;
-		pos += (dev_id->len + sizeof(struct bl_dev_id) -
-			sizeof(unsigned char));
+		pos += (dev_id->len + devid_len);
 	}
  out:
 	if (!serial_out)
-- 
2.3.3

