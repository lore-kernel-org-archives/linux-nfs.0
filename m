Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:15583 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751697Ab3FYXDO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Jun 2013 19:03:14 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 2/3] NFSv4.1 use pnfs_device maxcount for the blocklayout gdia_maxcount
Date: Tue, 25 Jun 2013 19:02:54 -0400
Message-Id: <1372201375-6686-3-git-send-email-andros@netapp.com>
In-Reply-To: <1372201375-6686-1-git-send-email-andros@netapp.com>
References: <1372201375-6686-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/blocklayout/blocklayout.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 1e5fdd3..e242bbf 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -1089,6 +1089,7 @@ nfs4_blk_get_deviceinfo(struct nfs_server *server, const struct nfs_fh *fh,
 	dev->pgbase = 0;
 	dev->pglen = PAGE_SIZE * max_pages;
 	dev->mincount = 0;
+	dev->maxcount = max_resp_sz - nfs41_maxgetdevinfo_overhead;
 
 	dprintk("%s: dev_id: %s\n", __func__, dev->dev_id.data);
 	rc = nfs4_proc_getdeviceinfo(server, dev, NULL);
-- 
1.7.11.7

