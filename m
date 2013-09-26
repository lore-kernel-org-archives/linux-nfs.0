Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:51917 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752987Ab3IZOpk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Sep 2013 10:45:40 -0400
Subject: [PATCH 4/4] SunRPC: Kill RPC_IFDEBUG() and NFS_IFDEBUG()
To: bfields@fieldses.org, Trond.Myklebust@netapp.com
From: David Howells <dhowells@redhat.com>
Cc: olof@lixom.net, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Thu, 26 Sep 2013 15:45:32 +0100
Message-ID: <20130926144532.29424.54343.stgit@warthog.procyon.org.uk>
In-Reply-To: <20130926144502.29424.21633.stgit@warthog.procyon.org.uk>
References: <20130926144502.29424.21633.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Kill RPC_IFDEBUG() and NFS_IFDEBUG() as they're no longer used.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/linux/nfs_fs.h       |    2 --
 include/linux/sunrpc/debug.h |    2 --
 2 files changed, 4 deletions(-)

diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 3ea4cde..e0e95e2 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -623,9 +623,7 @@ nfs_fileid_to_ino_t(u64 fileid)
 # undef ifdebug
 # ifdef NFS_DEBUG
 #  define ifdebug(fac)		if (unlikely(nfs_debug & NFSDBG_##fac))
-#  define NFS_IFDEBUG(x)	x
 # else
 #  define ifdebug(fac)		if (0)
-#  define NFS_IFDEBUG(x)
 # endif
 #endif
diff --git a/include/linux/sunrpc/debug.h b/include/linux/sunrpc/debug.h
index 60116cb..fd79089 100644
--- a/include/linux/sunrpc/debug.h
+++ b/include/linux/sunrpc/debug.h
@@ -39,11 +39,9 @@ extern unsigned int		nlm_debug;
 #ifdef RPC_DEBUG			
 # define ifdebug(fac)		if (unlikely(rpc_debug & RPCDBG_##fac))
 # define __dprintk(fmt, ...)	printk(KERN_DEFAULT fmt, ##__VA_ARGS__);
-# define RPC_IFDEBUG(x)		x
 #else
 # define ifdebug(fac)		if (0)
 # define __dprintk(fmt, ...)	no_printk(KERN_DEFAULT fmt, ##__VA_ARGS__);
-# define RPC_IFDEBUG(x)
 #endif
 
 #define dfprintk(fac, fmt, ...)				\

