From: Boaz Harrosh <bharrosh@panasas.com>
Subject: [PATCH 5/5] nfsd: Remove lots of un-needed includes
Date: Wed, 21 Oct 2009 10:16:03 +0200
Message-ID: <1256112963-3885-1-git-send-email-bharrosh@panasas.com>
References: <4ADEC1EF.8040107@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	NFS list <linux-nfs@vger.kernel.org>,
	Trond Myklebust <Trond.M
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from dip-colo-pa.panasas.com ([67.152.220.67]:53215 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751163AbZJUIQD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Oct 2009 04:16:03 -0400
In-Reply-To: <4ADEC1EF.8040107@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Once a few headers where fixed lots of includes are
not needed any more. (OK probably a few where so even
before)

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/exportfs/nfs4filelayoutxdr.c |    8 --------
 fs/nfsd/export.c                |   16 ----------------
 fs/nfsd/nfs4callback.c          |   14 --------------
 fs/nfsd/nfs4pnfsd.c             |    9 ---------
 fs/nfsd/nfs4proc.c              |    9 ---------
 fs/nfsd/nfs4state.c             |   18 ------------------
 fs/nfsd/pnfsd_lexp.c            |    5 -----
 fs/nfsd/spnfs_com.c             |   13 -------------
 8 files changed, 0 insertions(+), 92 deletions(-)

diff --git a/fs/exportfs/nfs4filelayoutxdr.c b/fs/exportfs/nfs4filelayoutxdr.c
index 9ce2a9d..d07685d 100644
--- a/fs/exportfs/nfs4filelayoutxdr.c
+++ b/fs/exportfs/nfs4filelayoutxdr.c
@@ -35,15 +35,7 @@
 */
 #if defined(CONFIG_EXPORTFS_FILE_LAYOUT)
 
-#include <linux/module.h>
-#include <linux/sunrpc/svc.h>
-#include <linux/nfsd/nfsd.h>
-#include <linux/nfsd/cache.h>
-#include <linux/nfs4.h>
-#include <linux/nfsd/state.h>
-#include <linux/nfsd/xdr4.h>
 #include <linux/nfsd/nfs4layoutxdr.h>
-#include <linux/nfsd/nfsd4_pnfs.h>
 
 /* We do our-own dprintk so filesystems are not dependent on sunrpc */
 #ifdef dprintk
diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index f51c413..616980c 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -14,23 +14,11 @@
  * Copyright (C) 1995, 1996 Olaf Kirch, <okir-pn4DOG8n3UYbFoVRYvo4fw@public.gmane.org>
  */
 
-#include <linux/unistd.h>
-#include <linux/slab.h>
-#include <linux/stat.h>
-#include <linux/in.h>
-#include <linux/seq_file.h>
 #include <linux/syscalls.h>
-#include <linux/rwsem.h>
-#include <linux/dcache.h>
 #include <linux/namei.h>
-#include <linux/mount.h>
-#include <linux/hash.h>
-#include <linux/module.h>
 #include <linux/exportfs.h>
 
-#include <linux/sunrpc/svc.h>
 #include <linux/nfsd/nfsd.h>
-#include <linux/nfsd/nfsfh.h>
 #include <linux/nfsd/pnfsd.h>
 #include "nfsd_priv.h"
 #if defined(CONFIG_SPNFS)
@@ -40,10 +28,6 @@
 #endif
 #endif
 #include <linux/nfsd/syscall.h>
-#include <linux/lockd/bind.h>
-#include <linux/sunrpc/msg_prot.h>
-#include <linux/sunrpc/gss_api.h>
-#include <net/ipv6.h>
 
 #define NFSDDBG_FACILITY	NFSDDBG_EXPORT
 
diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 3347749..caf84a6 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -33,22 +33,8 @@
  *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  */
 
-#include <linux/module.h>
-#include <linux/list.h>
-#include <linux/inet.h>
-#include <linux/errno.h>
-#include <linux/delay.h>
-#include <linux/sched.h>
-#include <linux/kthread.h>
-#include <linux/sunrpc/xdr.h>
-#include <linux/sunrpc/svc.h>
-#include <linux/sunrpc/clnt.h>
-#include <linux/sunrpc/svcsock.h>
 #include <linux/nfsd/nfsd.h>
 #include <linux/nfsd/state.h>
-#include <linux/sunrpc/sched.h>
-#include <linux/nfs4.h>
-#include <linux/sunrpc/xprtsock.h>
 
 #define NFSDDBG_FACILITY                NFSDDBG_PROC
 
diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index fdbc447..cfffead 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -23,16 +23,7 @@
 
 #if defined(CONFIG_PNFSD)
 
-#include <linux/param.h>
-#include <linux/slab.h>
-#include <linux/sunrpc/svc.h>
-#include <linux/sunrpc/debug.h>
 #include <linux/nfsd/nfsd.h>
-#include <linux/nfs4.h>
-#include <linux/nfsd/state.h>
-#include <linux/nfsd/xdr4.h>
-#include <linux/exportfs.h>
-#include <linux/nfsd/pnfsd.h>
 #include "nfsd_priv.h"
 
 #define NFSDDBG_FACILITY                NFSDDBG_PROC
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index dd1da22..e22a9e6 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -35,23 +35,14 @@
  *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  */
 
-#include <linux/param.h>
-#include <linux/major.h>
-#include <linux/slab.h>
 #include <linux/file.h>
 
-#include <linux/sunrpc/svc.h>
 #include <linux/nfsd/nfsd.h>
 #include <linux/nfsd/cache.h>
-#include <linux/nfs4.h>
 #include <linux/nfsd/state.h>
 #include <linux/nfsd/xdr4.h>
-#include <linux/nfs4_acl.h>
-#include <linux/sunrpc/gss_api.h>
 #if defined(CONFIG_PNFSD)
 #include <linux/nfsd/pnfsd.h>
-#include <linux/exportfs.h>
-#include <linux/nfsd/nfs4layoutxdr.h>
 #include "nfsd_priv.h"
 #if defined(CONFIG_SPNFS)
 #include <linux/nfsd4_spnfs.h>
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 018292e..b635ed0 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -34,31 +34,13 @@
 *
 */
 
-#include <linux/param.h>
-#include <linux/major.h>
-#include <linux/slab.h>
-
-#include <linux/sunrpc/svc.h>
-#include <linux/nfsd/nfsd.h>
-#include <linux/nfsd/cache.h>
 #include <linux/file.h>
-#include <linux/mount.h>
-#include <linux/workqueue.h>
 #include <linux/smp_lock.h>
-#include <linux/kthread.h>
-#include <linux/nfs4.h>
 #include <linux/nfsd/state.h>
 #include <linux/nfsd/xdr4.h>
 #include <linux/namei.h>
 #include <linux/swap.h>
-#include <linux/mutex.h>
-#include <linux/lockd/bind.h>
-#include <linux/module.h>
 #include <linux/sunrpc/svcauth_gss.h>
-#include <linux/sunrpc/clnt.h>
-#if defined(CONFIG_PNFSD)
-#include <linux/nfsd/pnfsd.h>
-#endif /* CONFIG_PNFSD */
 #include "nfsd_priv.h"
 
 #define NFSDDBG_FACILITY                NFSDDBG_PROC
diff --git a/fs/nfsd/pnfsd_lexp.c b/fs/nfsd/pnfsd_lexp.c
index 2bcb6b5..a09e3c1 100644
--- a/fs/nfsd/pnfsd_lexp.c
+++ b/fs/nfsd/pnfsd_lexp.c
@@ -20,12 +20,7 @@
 
 #if defined(CONFIG_PNFSD_LOCAL_EXPORT)
 
-#include <linux/nfs_fs.h>
-#include <linux/sunrpc/svc.h>
 #include <linux/sunrpc/svc_xprt.h>
-#include <linux/nfsd/nfsfh.h>
-#include <linux/nfsd/state.h>
-#include <linux/nfsd/pnfsd.h>
 #include <linux/nfsd/nfs4layoutxdr.h>
 #include <linux/nfsd/debug.h>
  
diff --git a/fs/nfsd/spnfs_com.c b/fs/nfsd/spnfs_com.c
index 7c7d48d..deab09b 100644
--- a/fs/nfsd/spnfs_com.c
+++ b/fs/nfsd/spnfs_com.c
@@ -39,23 +39,10 @@
  */
 #if defined(CONFIG_SPNFS)
 
-#include <linux/module.h>
-#include <linux/mutex.h>
-#include <linux/init.h>
-#include <linux/types.h>
-#include <linux/slab.h>
-#include <linux/socket.h>
-#include <linux/in.h>
-#include <linux/sched.h>
 #include <linux/namei.h>
 #include <linux/mount.h>
-#include <linux/path.h>
 #include <linux/sunrpc/clnt.h>
-#include <linux/workqueue.h>
 #include <linux/sunrpc/rpc_pipe_fs.h>
-#include <linux/proc_fs.h>
-
-#include <linux/nfs_fs.h>
 
 #include <linux/nfsd4_spnfs.h>
 #include <linux/nfsd/debug.h>
-- 
1.6.2.1

