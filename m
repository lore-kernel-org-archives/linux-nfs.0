Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:62013 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756960Ab2ARERg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Jan 2012 23:17:36 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 01/10] NFS: Remove unnecessary includes from linux/nfs_fs_i.h
Date: Tue, 17 Jan 2012 23:17:04 -0500
Message-Id: <1326860233-27947-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Also from linux/nfs_xdr.h.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/pagelist.c        |    1 +
 include/linux/nfs_fs_i.h |    4 ----
 include/linux/nfs_xdr.h  |    1 -
 3 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 5668f7c..77a184e 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -13,6 +13,7 @@
 #include <linux/file.h>
 #include <linux/sched.h>
 #include <linux/sunrpc/clnt.h>
+#include <linux/nfs.h>
 #include <linux/nfs3.h>
 #include <linux/nfs4.h>
 #include <linux/nfs_page.h>
diff --git a/include/linux/nfs_fs_i.h b/include/linux/nfs_fs_i.h
index 8617302..a5c50d9 100644
--- a/include/linux/nfs_fs_i.h
+++ b/include/linux/nfs_fs_i.h
@@ -1,10 +1,6 @@
 #ifndef _NFS_FS_I
 #define _NFS_FS_I
 
-#include <asm/types.h>
-#include <linux/list.h>
-#include <linux/nfs.h>
-
 struct nlm_lockowner;
 
 /*
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index a764cef..f5188e1 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -2,7 +2,6 @@
 #define _LINUX_NFS_XDR_H
 
 #include <linux/nfsacl.h>
-#include <linux/nfs3.h>
 #include <linux/sunrpc/gss_api.h>
 
 /*
-- 
1.7.7.5

