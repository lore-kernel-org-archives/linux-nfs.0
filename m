Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f41.google.com ([209.85.220.41]:62149 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933002AbaEGPI3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 May 2014 11:08:29 -0400
Received: by mail-pa0-f41.google.com with SMTP id lj1so1298865pab.14
        for <linux-nfs@vger.kernel.org>; Wed, 07 May 2014 08:08:28 -0700 (PDT)
Message-ID: <536A4C54.5090401@gmail.com>
Date: Wed, 07 May 2014 23:08:04 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSD: cleanup unneeded including linux/export.h
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

commit 4ac7249ea5a0ceef9f8269f63f33cc873c3fac61 have remove all EXPORT_SYMBOL,
linux/export.h is not needed, just clean it.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4acl.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/nfsd/nfs4acl.c b/fs/nfsd/nfs4acl.c
index babcc3c..42925db 100644
--- a/fs/nfsd/nfs4acl.c
+++ b/fs/nfsd/nfs4acl.c
@@ -36,7 +36,6 @@
 
 #include <linux/slab.h>
 #include <linux/nfs_fs.h>
-#include <linux/export.h>
 #include "nfsfh.h"
 #include "nfsd.h"
 #include "acl.h"
-- 
1.9.0

