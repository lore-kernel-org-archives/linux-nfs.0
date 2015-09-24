Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34714 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753148AbbIXM5P (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Sep 2015 08:57:15 -0400
Received: by padhy16 with SMTP id hy16so72836384pad.1
        for <linux-nfs@vger.kernel.org>; Thu, 24 Sep 2015 05:57:15 -0700 (PDT)
Subject: [PATCH 4/8] NFS: Remove unneeded NFS_DEBUG checking before define
 NFSDBG_FACILITY
To: Trond Myklebust <trond.myklebust@primarydata.com>
References: <5603F269.9060102@gmail.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <5603F31F.5060007@gmail.com>
Date: Thu, 24 Sep 2015 20:57:03 +0800
MIME-Version: 1.0
In-Reply-To: <5603F269.9060102@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It's not needed to checking NFS_DEBUG before define NFSDBG_FACILITY, remove it.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/callback_proc.c | 2 --
 fs/nfs/mount_clnt.c    | 4 +---
 2 files changed, 1 insertion(+), 5 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index b85cf7a..807eb6e 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -17,9 +17,7 @@
 #include "nfs4session.h"
 #include "nfs4trace.h"
 
-#ifdef NFS_DEBUG
 #define NFSDBG_FACILITY NFSDBG_CALLBACK
-#endif
 
 __be32 nfs4_callback_getattr(struct cb_getattrargs *args,
 			     struct cb_getattrres *res,
diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index 99a4528..09b1900 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -16,9 +16,7 @@
 #include <linux/nfs_fs.h>
 #include "internal.h"
 
-#ifdef NFS_DEBUG
-# define NFSDBG_FACILITY	NFSDBG_MOUNT
-#endif
+#define NFSDBG_FACILITY	NFSDBG_MOUNT
 
 /*
  * Defined by RFC 1094, section A.3; and RFC 1813, section 5.1.4
-- 
2.5.0

