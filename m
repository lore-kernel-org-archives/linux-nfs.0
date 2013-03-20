Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cn.fujitsu.com ([222.73.24.84]:1565 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751685Ab3CTIAk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Mar 2013 04:00:40 -0400
Message-ID: <51496CC5.7040400@cn.fujitsu.com>
Date: Wed, 20 Mar 2013 16:01:09 +0800
From: fanchaoting <fanchaoting@cn.fujitsu.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH] pnfs-block: removing DM device maybe cause oops when call
 dev_remove
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

when pnfs block using device mapper,if umounting later,it maybe
cause oops. we apply "1 + sizeof(bl_umount_request)" memory for
msg->data, the memory maybe overflow when we do "memcpy(&dataptr
[sizeof(bl_msg)], &bl_umount_request, sizeof(bl_umount_request))",
because the size of bl_msg is more than 1 byte.

   Signed-off-by: fanchaoting<fanchaoting@cn.fujitsu.com>

---
 fs/nfs/blocklayout/blocklayoutdm.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayoutdm.c b/fs/nfs/blocklayout/blocklayoutdm.c
index 737d839..8df9afa 100644
--- a/fs/nfs/blocklayout/blocklayoutdm.c
+++ b/fs/nfs/blocklayout/blocklayoutdm.c
@@ -55,7 +55,7 @@ static void dev_remove(struct net *net, dev_t dev)

        bl_pipe_msg.bl_wq = &nn->bl_wq;
        memset(msg, 0, sizeof(*msg));
-       msg->data = kzalloc(1 + sizeof(bl_umount_request), GFP_NOFS);
+       msg->data = kzalloc(sizeof(bl_msg) + sizeof(bl_umount_request), GFP_NOFS);
        if (!msg->data)
                goto out;

--
1.7.1

