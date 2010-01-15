From: H Hartley Sweeten <hartleys-3FF4nKcrg1dE2c76skzGb0EOCMrvLtNR@public.gmane.org>
Subject: [PATCH] fs/nfs/write.c: make local symbol static
Date: Thu, 14 Jan 2010 20:16:57 -0700
Message-ID: <201001142016.57297.hartleys@visionengravers.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Cc: Trond.Myklebust@netapp.com
To: Linux Kernel <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from [206.15.93.42] ([206.15.93.42]:15485 "EHLO
	visionfs1.visionengravers.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751674Ab0AODQv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Jan 2010 22:16:51 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

fs/nfs/write.c: make local symbol static

The symbol nfs_commitdata_release is only used locally
in this file. Make it static to prevent the following sparse warning:

warning: symbol 'nfs_commitdata_release' was not declared. Should it be static?

Signed-off-by: H Hartley Sweeten <hsweeten-3FF4nKcrg1dE2c76skzGb0EOCMrvLtNR@public.gmane.org>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>

---

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index d171696..78b5c56 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1233,7 +1233,7 @@ int nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 
 
 #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
-void nfs_commitdata_release(void *data)
+static void nfs_commitdata_release(void *data)
 {
 	struct nfs_write_data *wdata = data;
 
