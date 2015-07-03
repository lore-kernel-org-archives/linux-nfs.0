Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:35546 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754792AbbGCLgr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Jul 2015 07:36:47 -0400
Received: by pdbci14 with SMTP id ci14so62459919pdb.2
        for <linux-nfs@vger.kernel.org>; Fri, 03 Jul 2015 04:36:47 -0700 (PDT)
Message-ID: <559673AE.5020308@gmail.com>
Date: Fri, 03 Jul 2015 19:36:14 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: kinglongmee@gmail.com
Subject: [PATCH 3/5] nfsd: Remove duplicate define of IDMAP_NAMESZ/IDMAP_TYPE_xx
References: <559672B7.4010802@gmail.com>
In-Reply-To: <559672B7.4010802@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Just using the macro defined in nfs_idmap.h.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/idmap.h     | 4 +---
 fs/nfsd/nfs4idmap.c | 3 ---
 2 files changed, 1 insertion(+), 6 deletions(-)

diff --git a/fs/nfsd/idmap.h b/fs/nfsd/idmap.h
index a3f3490..23cc85d 100644
--- a/fs/nfsd/idmap.h
+++ b/fs/nfsd/idmap.h
@@ -37,9 +37,7 @@
 
 #include <linux/in.h>
 #include <linux/sunrpc/svc.h>
-
-/* XXX from linux/nfs_idmap.h */
-#define IDMAP_NAMESZ 128
+#include <linux/nfs_idmap.h>
 
 #ifdef CONFIG_NFSD_V4
 int nfsd_idmap_init(struct net *);
diff --git a/fs/nfsd/nfs4idmap.c b/fs/nfsd/nfs4idmap.c
index e1b3d3d..5b20577 100644
--- a/fs/nfsd/nfs4idmap.c
+++ b/fs/nfsd/nfs4idmap.c
@@ -59,9 +59,6 @@ MODULE_PARM_DESC(nfs4_disable_idmapping,
  * that.
  */
 
-#define IDMAP_TYPE_USER  0
-#define IDMAP_TYPE_GROUP 1
-
 struct ent {
 	struct cache_head h;
 	int               type;		       /* User / Group */
-- 
2.4.3

