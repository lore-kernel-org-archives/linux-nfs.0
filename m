Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:16252 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752970Ab1FQUZv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Jun 2011 16:25:51 -0400
Message-ID: <4DFBB84F.2040708@panasas.com>
Date: Fri, 17 Jun 2011 16:25:51 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH] pnfs-obj: No longer needed to take an extra ref at add_device
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Andy's last device_cache patches, already take an extra
reference on the newly inserted device_id. So we can remove it
from obj-io.

Without this patch the device_ids are leaked. 

Andy's patches are not in Linus tree yet. So I'm not sure if they are
scheduled for this Kernel or the next. This patch should be added as
part of these.

CC: Andy Adamson <andros@netapp.com>
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/objlayout/objio_osd.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index f014038..70272d5 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -108,7 +108,6 @@ _dev_list_add(const struct nfs_server *nfss,
 		de = n;
 	}
 
-	atomic_inc(&de->id_node.ref);
 	return de;
 }
 
-- 
1.7.3.4

