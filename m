Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:51664 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755051Ab2FHMOm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Jun 2012 08:14:42 -0400
Message-ID: <4FD1ECA3.8000609@panasas.com>
Date: Fri, 8 Jun 2012 15:14:27 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
CC: Benny Halevy <bhalevy@tonian.com>, Peng Tao <bergwolf@gmail.com>
Subject: [PATCH 4/6] pnfs-obj: don't leak objio_state if ore_write/read fails
References: <4FD1CEA8.3090105@panasas.com>
In-Reply-To: <4FD1CEA8.3090105@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


[Bug since 3.2 Kernel]
CC: Stable Tree <stable@kernel.org>
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/objlayout/objio_osd.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 0e7c833..422bdef 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -454,7 +454,10 @@ int objio_read_pagelist(struct nfs_read_data *rdata)
 	objios->ios->done = _read_done;
 	dprintk("%s: offset=0x%llx length=0x%x\n", __func__,
 		rdata->args.offset, rdata->args.count);
-	return ore_read(objios->ios);
+	ret = ore_read(objios->ios);
+	if (unlikely(ret))
+		objio_free_result(&objios->oir);
+	return ret;
 }
 
 /*
@@ -555,8 +558,10 @@ int objio_write_pagelist(struct nfs_write_data *wdata, int how)
 	dprintk("%s: offset=0x%llx length=0x%x\n", __func__,
 		wdata->args.offset, wdata->args.count);
 	ret = ore_write(objios->ios);
-	if (unlikely(ret))
+	if (unlikely(ret)) {
+		objio_free_result(&objios->oir);
 		return ret;
+	}
 
 	if (objios->sync)
 		_write_done(objios->ios, objios);
-- 
1.7.10.2.677.gb6bc67f


