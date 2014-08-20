Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx3-phx2.redhat.com ([209.132.183.24]:47908 "EHLO
	mx3-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750979AbaHTDGr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Aug 2014 23:06:47 -0400
Date: Tue, 19 Aug 2014 23:06:40 -0400 (EDT)
From: Xiong Zhou <xzhou@redhat.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, ben@decadent.org.uk,
        linux-kernel@vger.kernel.org
Message-ID: <1927160445.21851828.1408504000719.JavaMail.zimbra@redhat.com>
In-Reply-To: <600788954.21849581.1408502615727.JavaMail.zimbra@redhat.com>
Subject: [PATCH] nfs: use canonical path in nfs_show_devname
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


When export root dir(/) via nfs, and mount a particular dir under root, eg
/nfsexport, there will be defect double slash output in /proc/mounts, like
localhost://nfsexport.

Signed-off-by: Xiong Zhou <xzhou@redhat.com>
---
 fs/nfs/super.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index e4499d5..62b1cab 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -780,7 +780,7 @@ int nfs_show_devname(struct seq_file *m, struct dentry *root)
 	int err = 0;
 	if (!page)
 		return -ENOMEM;
-	devname = nfs_path(&dummy, root, page, PAGE_SIZE, 0);
+	devname = nfs_path(&dummy, root, page, PAGE_SIZE, 1);
 	if (IS_ERR(devname))
 		err = PTR_ERR(devname);
 	else
-- 
1.8.3.1

