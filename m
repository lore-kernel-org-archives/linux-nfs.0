Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57222 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752105AbdLHRws (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 8 Dec 2017 12:52:48 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] pnfs/blocklayout: Add module alias for LAYOUT4_SCSI
Date: Fri,  8 Dec 2017 12:52:47 -0500
Message-Id: <a33fde58b8e3c74e5578054afaef0e37e53764f6.1512749707.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The blocklayout module contains the client support for both block and SCSI
layouts.  Add a module alias for the SCSI layout type so that the module
will be loaded for SCSI layouts.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/blocklayout/blocklayout.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index f2e9cbfa3432..80cb7a924954 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -1041,6 +1041,7 @@ static void __exit nfs4blocklayout_exit(void)
 }
 
 MODULE_ALIAS("nfs-layouttype4-3");
+MODULE_ALIAS("nfs-layouttype4-5");
 
 module_init(nfs4blocklayout_init);
 module_exit(nfs4blocklayout_exit);
-- 
2.9.3

