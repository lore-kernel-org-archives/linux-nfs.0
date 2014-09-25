Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f170.google.com ([209.85.213.170]:56466 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751474AbaIYUz4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Sep 2014 16:55:56 -0400
Received: by mail-ig0-f170.google.com with SMTP id a13so9088376igq.1
        for <linux-nfs@vger.kernel.org>; Thu, 25 Sep 2014 13:55:55 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv3: Fix missing includes of nfs3_fs.h
Date: Thu, 25 Sep 2014 16:55:44 -0400
Message-Id: <1411678544-47748-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Silence a few warnings about missing symbols that are due to missing
includes of nfs3_fs.h.

Fixes: 00a36a1090350 (NFS: Move v3 declarations out of internal.h)
Fixes: cb8c20fa53ec2 (NFS: Move NFS v3 acl functions to nfs3_fs.h)
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs3acl.c    | 1 +
 fs/nfs/nfs3client.c | 1 +
 2 files changed, 2 insertions(+)

diff --git a/fs/nfs/nfs3acl.c b/fs/nfs/nfs3acl.c
index 24c6898159cc..658e586ca438 100644
--- a/fs/nfs/nfs3acl.c
+++ b/fs/nfs/nfs3acl.c
@@ -7,6 +7,7 @@
 #include <linux/nfsacl.h>
 
 #include "internal.h"
+#include "nfs3_fs.h"
 
 #define NFSDBG_FACILITY	NFSDBG_PROC
 
diff --git a/fs/nfs/nfs3client.c b/fs/nfs/nfs3client.c
index b3fc65ef39ca..8c1b437c5403 100644
--- a/fs/nfs/nfs3client.c
+++ b/fs/nfs/nfs3client.c
@@ -1,6 +1,7 @@
 #include <linux/nfs_fs.h>
 #include <linux/nfs_mount.h>
 #include "internal.h"
+#include "nfs3_fs.h"
 
 #ifdef CONFIG_NFS_V3_ACL
 static struct rpc_stat		nfsacl_rpcstat = { &nfsacl_program };
-- 
1.9.3

