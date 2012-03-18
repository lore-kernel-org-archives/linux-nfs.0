Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.windriver.com ([147.11.1.11]:48412 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755991Ab2CRSNI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 18 Mar 2012 14:13:08 -0400
Date: Sun, 18 Mar 2012 14:13:05 -0400
From: Paul Gortmaker <paul.gortmaker@windriver.com>
To: <linux-nfs@vger.kernel.org>
CC: <Trond.Myklebust@netapp.com>
Subject: _nfs_display_fhandle_hash: undefined reference to `crc32_le'
Message-ID: <20120318181304.GA2095@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This started showing up in linux-next last week:

  LD      .tmp_vmlinux1
fs/built-in.o: In function `_nfs_display_fhandle_hash':
/scratch/kisskb/src/fs/nfs/inode.c:1063: undefined reference to `crc32_le'
make[1]: *** [.tmp_vmlinux1] Error 1

Target is an mpc8xx board:

http://kisskb.ellerman.id.au/kisskb/target/2679/

I tried to run an automated bisect on it, but there appears to
be build failures in the bisection range, in addition to the
above link error (i.e. points I'd use "skip" on if I wasn't
using "git bisect run ...")

# good: [b030fb0bb113316cc6f56779388b8572ab0699da] SUNRPC: use proper network namespace in rpcbind RPCBPROC_GETADDR procedure
git bisect good b030fb0bb113316cc6f56779388b8572ab0699da
# bad: [5247fab5c82779174d50590e0200bf532248a8a1] SUNRPC: pass network namespace to service registering routines
git bisect bad 5247fab5c82779174d50590e0200bf532248a8a1

Even without the concrete trigger commit, a suggested possible
fix (tested locally) is below.

Paul.
---

 From 21b77ae0373725bd2c60eca065e77c4d2f0fdbfa Mon Sep 17 00:00:00 2001
From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Sun, 18 Mar 2012 14:07:42 -0400
Subject: [PATCH] nfs: select CRC32 for when NFS is enabled for crc32_le

To avoid the following link errors:

  LD      .tmp_vmlinux1
fs/built-in.o: In function `_nfs_display_fhandle_hash':
fs/nfs/inode.c:1063: undefined reference to `crc32_le'
make[1]: *** [.tmp_vmlinux1] Error 1

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index 7bce64c..9acdfb0 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -3,6 +3,7 @@ config NFS_FS
 	depends on INET && FILE_LOCKING
 	select LOCKD
 	select SUNRPC
+	select CRC32
 	select NFS_ACL_SUPPORT if NFS_V3_ACL
 	help
 	  Choose Y here if you want to access files residing on other
-- 
1.7.9.1

