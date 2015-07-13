Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:36285 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751139AbbGMIYz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2015 04:24:55 -0400
Received: by pachj5 with SMTP id hj5so28299017pac.3
        for <linux-nfs@vger.kernel.org>; Mon, 13 Jul 2015 01:24:55 -0700 (PDT)
Message-ID: <55A375A1.4000800@gmail.com>
Date: Mon, 13 Jul 2015 16:24:01 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Steve Dickson <SteveD@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: Christoph Hellwig <hch@infradead.org>, kinglongmee@gmail.com
Subject: [PATCH v2] blkmapd: Skip the SCSI ID if data length is zero
References: <55A2FEE4.6030201@gmail.com> <20150713064216.GA31842@infradead.org>
In-Reply-To: <20150713064216.GA31842@infradead.org>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In vmware linux, the iscsi device contains more than one SCSI ID,
and, the second one's data length is zero.

If there are two iSCSI devices with the second SCSI ID's data length
is zero, the first iSCSI device will record with an invalid SCSI ID
as zero length, the second one will be treat as the first one for
the SCSI ID is zero length too.

It means the only the first iSCSI device is exist in blkmapd's cache,
the request for the second iSCSI device will failed as,

"blkmapd: Could not find disk for device" and,
"bl_resolve_deviceid failed to decode device: 2".

v2, update comments

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

