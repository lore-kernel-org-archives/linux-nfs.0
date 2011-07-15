From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] pnfs: simplify pnfs files module autoloading
Date: Fri, 15 Jul 2011 19:15:14 -0400
Message-ID: <20110715231514.GE28012@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: trond@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:44355 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753267Ab1GOXPP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Jul 2011 19:15:15 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@redhat.com>

Embed the necessary alias into the module rather than waiting for
someone to add it to /etc/modprobe.conf

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfs/nfs4filelayout.c      |    2 ++
 fs/nfs/objlayout/objio_osd.c |    2 ++
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 0bafcc9..a288abc 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -903,5 +903,7 @@ static void __exit nfs4filelayout_exit(void)
 	pnfs_unregister_layoutdriver(&filelayout_type);
 }
 
+MODULE_ALIAS("nfs-layouttype4-1");
+
 module_init(nfs4filelayout_init);
 module_exit(nfs4filelayout_exit);
diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 8ff2ea3..aba9577 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -1055,5 +1055,7 @@ objlayout_exit(void)
 	       __func__);
 }
 
+MODULE_ALIAS("nfs-layouttype4-2");
+
 module_init(objlayout_init);
 module_exit(objlayout_exit);
-- 
1.7.4.1

