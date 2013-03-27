Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cn.fujitsu.com ([222.73.24.84]:46195 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752740Ab3C0Iav (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Mar 2013 04:30:51 -0400
Message-ID: <5152AE56.5010306@cn.fujitsu.com>
Date: Wed, 27 Mar 2013 16:31:18 +0800
From: fanchaoting <fanchaoting@cn.fujitsu.com>
MIME-Version: 1.0
To: "bfields@fieldses.org" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/2] nfsd: remove /proc/fs/nfs when create /proc/fs/nfs/exports
 error
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

when create /proc/fs/nfs/exports error, we should remove /proc/fs/nfs,
if don't do it, it maybe cause Memory leak.

 Signed-off-by: fanchaoting <fanchaoting@cn.fujitsu.com>
 Reviewed-by: chendt.fnst <chendt.fnst@cn.fujitsu.com>

---
 fs/nfsd/nfsctl.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index f33455b..58e4db4 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1102,8 +1102,10 @@ static int create_proc_exports_entry(void)
 		return -ENOMEM;
 	entry = proc_create("exports", 0, entry,
 				 &exports_proc_operations);
-	if (!entry)
+	if (!entry) {
+		remove_proc_entry("fs/nfs", NULL);
 		return -ENOMEM;
+	}
 	return 0;
 }
 #else /* CONFIG_PROC_FS */
-- 
1.7.1


