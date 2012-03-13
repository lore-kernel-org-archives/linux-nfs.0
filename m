Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:18172 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757623Ab2CMRTM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Mar 2012 13:19:12 -0400
Date: Tue, 13 Mar 2012 20:18:48 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Stanislav Kinsbursky <skinsbursky@parallels.com>,
        Benny Halevy <bhalevy@panasas.com>,
        Weston Andros Adamson <dros@netapp.com>, Peng Tao <peng_tao@emc.com>,
        linux-nfs@vger.kernel.org, kernel-janitors@vger.kernel.org
Subject: [patch] NFS: null dereference in dev_remove()
Message-ID: <20120313171848.GA31808@elgon.mountain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In commit 5ffaf85541 "NFS: replace global bl_wq with per-net one" we
made "msg" a pointer instead of a struct stored in stack memory.  But we
forgot to change the memset() here so we're still clearing stack memory
instead clearing the struct like we intended.  It will lead to a kernel
crash.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/fs/nfs/blocklayout/blocklayoutdm.c b/fs/nfs/blocklayout/blocklayoutdm.c
index 30fc22a..737d839 100644
--- a/fs/nfs/blocklayout/blocklayoutdm.c
+++ b/fs/nfs/blocklayout/blocklayoutdm.c
@@ -54,7 +54,7 @@ static void dev_remove(struct net *net, dev_t dev)
 	dprintk("Entering %s\n", __func__);
 
 	bl_pipe_msg.bl_wq = &nn->bl_wq;
-	memset(&msg, 0, sizeof(*msg));
+	memset(msg, 0, sizeof(*msg));
 	msg->data = kzalloc(1 + sizeof(bl_umount_request), GFP_NOFS);
 	if (!msg->data)
 		goto out;
