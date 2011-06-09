From: Dan Carpenter <error27@gmail.com>
Subject: [patch v2] NFS: fix debug message
Date: Thu, 9 Jun 2011 21:07:33 +0300
Message-ID: <20110609180733.GJ4069@shale.localdomain>
References: <4E3994E6-9DBF-439B-808E-F134EB5DD923@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "open list:NFS, SUNRPC, AND..." <linux-nfs@vger.kernel.org>,
	kernel-janitors@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:42801 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751353Ab1FISIK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jun 2011 14:08:10 -0400
In-Reply-To: <4E3994E6-9DBF-439B-808E-F134EB5DD923@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

"tmp_ds" was intended here instead of "ds".  Also "ds" was already
freed.

Signed-off-by: Dan Carpenter <error27@gmail.com>
---
v1 fixed the user-after-free but left the message incorrect.

diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index 77c171e..ed388aa 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -365,7 +365,7 @@ nfs4_pnfs_ds_add(struct list_head *dsaddrs, gfp_t gfp_flags)
 		kfree(ds);
 		atomic_inc(&tmp_ds->ds_count);
 		dprintk("%s data server %s found, inc'ed ds_count to %d\n",
-			__func__, ds->ds_remotestr,
+			__func__, tmp_ds->ds_remotestr,
 			atomic_read(&tmp_ds->ds_count));
 		ds = tmp_ds;
 	}
