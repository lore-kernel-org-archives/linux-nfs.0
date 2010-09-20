Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:53685 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756779Ab0ITQdh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Sep 2010 12:33:37 -0400
Received: by gxk23 with SMTP id 23so1361533gxk.19
        for <linux-nfs@vger.kernel.org>; Mon, 20 Sep 2010 09:33:37 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 7/7] nfsd: Enable IPv6 support in rpc.nfsd again.
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 20 Sep 2010 12:33:34 -0400
Message-ID: <20100920163334.3170.34867.stgit@ellison.1015granger.net>
In-Reply-To: <20100920162616.3170.24625.stgit@ellison.1015granger.net>
References: <20100920162616.3170.24625.stgit@ellison.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Revert commit b2a3cd59 so that rpc.nfsd can create IPv6 listener
sockets for the kernel.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/nfsd/nfsd.c   |    9 ---------
 utils/nfsd/nfssvc.c |    9 ---------
 2 files changed, 0 insertions(+), 18 deletions(-)

diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
index 658b8fa..e7e1470 100644
--- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -27,15 +27,6 @@
 #include "nfssvc.h"
 #include "xlog.h"
 
-/*
- * IPv6 support for nfsd was finished before some of the other daemons (mountd
- * and statd in particular). That could be a problem in the future if someone
- * were to boot a kernel that supports IPv6 serving with  an older nfs-utils. For
- * now, hardcode the IPv6 switch into the off position until the other daemons
- * are functional.
- */
-#undef IPV6_SUPPORTED
-
 static void	usage(const char *);
 
 static struct option longopts[] =
diff --git a/utils/nfsd/nfssvc.c b/utils/nfsd/nfssvc.c
index 7693626..ea36399 100644
--- a/utils/nfsd/nfssvc.c
+++ b/utils/nfsd/nfssvc.c
@@ -24,15 +24,6 @@
 #include "nfslib.h"
 #include "xlog.h"
 
-/*
- * IPv6 support for nfsd was finished before some of the other daemons (mountd
- * and statd in particular). That could be a problem in the future if someone
- * were to boot a kernel that supports IPv6 serving with an older nfs-utils. For
- * now, hardcode the IPv6 switch into the off position until the other daemons
- * are functional.
- */
-#undef IPV6_SUPPORTED
-
 #ifndef NFSD_FS_DIR
 #define NFSD_FS_DIR	  "/proc/fs/nfsd"
 #endif

