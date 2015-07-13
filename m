Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34504 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753050AbbGMKAD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2015 06:00:03 -0400
Received: by pacan13 with SMTP id an13so13450099pac.1
        for <linux-nfs@vger.kernel.org>; Mon, 13 Jul 2015 03:00:02 -0700 (PDT)
Message-ID: <55A38C1C.3030600@gmail.com>
Date: Mon, 13 Jul 2015 17:59:56 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Steve Dickson <SteveD@redhat.com>
CC: Christoph Hellwig <hch@infradead.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
Subject: [PATCH v3] blkmapd: Skip the SCSI ID if data length is zero
References: <55A2FEE4.6030201@gmail.com> <20150713064216.GA31842@infradead.org> <55A375A1.4000800@gmail.com> <20150713090142.GA28557@infradead.org> <55A380A5.20009@gmail.com>
In-Reply-To: <55A380A5.20009@gmail.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In vmware linux, the iscsi device contains more than one SCSI ID, 
and the second one's data length is zero.

If there are two iSCSI devices with the second SCSI ID's data length
is zero, the first iSCSI device will record with an invalid SCSI ID
as zero length, the second one will be treat as the first one for
the SCSI ID is zero length too.

It means the only the first iSCSI device is exist in blkmapd's cache,
the request for the second iSCSI device will failed as,

"blkmapd: Could not find disk for device" and,
"bl_resolve_deviceid failed to decode device: 2".

v2, update commit log
v3, add a comment in the code

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 utils/blkmapd/device-inq.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/utils/blkmapd/device-inq.c b/utils/blkmapd/device-inq.c
index 6b56b67..60fe2d3 100644
--- a/utils/blkmapd/device-inq.c
+++ b/utils/blkmapd/device-inq.c
@@ -198,6 +198,10 @@ struct bl_serial *bldev_read_serial(int fd, const char *filename)
 		dev_id = (struct bl_dev_id *)&(dev_root->data[pos]);
 		pos += (dev_id->len + devid_len);
 
+		/* Needs an SCSI ID with unique date not zero length */
+		if (!dev_id->len)
+			continue;
+
 		if ((dev_id->ids & 0xf) < current_id)
 			continue;
 		switch (dev_id->ids & 0xf) {
-- 
2.4.3

