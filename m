Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:31993 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751065AbbBKKVw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Feb 2015 05:21:52 -0500
Date: Wed, 11 Feb 2015 13:22:40 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        Tao Peng <bergwolf@primarydata.com>,
        Weston Andros Adamson <dros@primarydata.com>,
        Tom Haynes <loghyr@primarydata.com>, linux-nfs@vger.kernel.org,
        kernel-janitors@vger.kernel.org
Subject: [patch] pnfs/flexfiles: move kfree() after the deference
Message-ID: <20150211102240.GA18515@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We dereference "err" in the the debug printk so we have to move the
kfree() down a couple lines.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index 3bbb16b..e2c01f2 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -515,10 +515,10 @@ int ff_layout_encode_ds_ioerr(struct nfs4_flexfile_layout *flo,
 		*p++ = cpu_to_be32(err->opnum);
 		*count += 1;
 		list_del(&err->list);
-		kfree(err);
 		dprintk("%s: offset %llu length %llu status %d op %d count %d\n",
 			__func__, err->offset, err->length, err->status,
 			err->opnum, *count);
+		kfree(err);
 	}
 
 	return 0;
