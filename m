Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f182.google.com ([209.85.216.182]:35098 "EHLO
	mail-qc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753232AbaEWMx1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 May 2014 08:53:27 -0400
Received: by mail-qc0-f182.google.com with SMTP id e16so7900228qcx.41
        for <linux-nfs@vger.kernel.org>; Fri, 23 May 2014 05:53:26 -0700 (PDT)
Message-ID: <537F44B1.6080507@gmail.com>
Date: Fri, 23 May 2014 20:53:05 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>, kinglongmee@gmail.com
Subject: [PATCH 1/5] NFSD: Cleanup unneeded including linux/user_namespace.h
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

commit 4c1e1b34d5c800ad3ac9a7e2805b0bea70ad2278 using kuid/kgid for
ex_anon_uid/ex_anon_gid, user_namespace.h is not needed now, clean it.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/auth.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/nfsd/auth.c b/fs/nfsd/auth.c
index 2645be4..1042325 100644
--- a/fs/nfsd/auth.c
+++ b/fs/nfsd/auth.c
@@ -1,7 +1,6 @@
 /* Copyright (C) 1995, 1996 Olaf Kirch <okir@monad.swb.de> */
 
 #include <linux/sched.h>
-#include <linux/user_namespace.h>
 #include "nfsd.h"
 #include "auth.h"
 
-- 
1.9.3

