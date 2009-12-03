From: Boaz Harrosh <bharrosh@panasas.com>
Subject: [PATCH 05/12] nfsd: Source files #include cleanups
Date: Thu,  3 Dec 2009 20:29:12 +0200
Message-ID: <1259864952-4773-1-git-send-email-bharrosh@panasas.com>
References: <4B1802D0.8060206@panasas.com>
To: "J. Bruce Fields" <bfields@citi.umich.edu>,
	NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:36746 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756110AbZLCS3J (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Dec 2009 13:29:09 -0500
In-Reply-To: <4B1802D0.8060206@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that the headers are fixed and carry their own wait, all fs/nfsd/
source files can include a minimal set of headers. and still compile just
fine.

This patch should improve the compilation speed of the nfsd module.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfsd/auth.c         |    4 ----
 fs/nfsd/export.c       |   15 ---------------
 fs/nfsd/lockd.c        |    5 -----
 fs/nfsd/nfs2acl.c      |    4 ----
 fs/nfsd/nfs3acl.c      |    3 ---
 fs/nfsd/nfs3proc.c     |   13 -------------
 fs/nfsd/nfs3xdr.c      |   11 -----------
 fs/nfsd/nfs4acl.c      |    8 --------
 fs/nfsd/nfs4callback.c |   13 -------------
 fs/nfsd/nfs4idmap.c    |   15 +--------------
 fs/nfsd/nfs4proc.c     |   10 ----------
 fs/nfsd/nfs4recover.c  |    8 --------
 fs/nfsd/nfs4state.c    |   15 ---------------
 fs/nfsd/nfs4xdr.c      |   12 +-----------
 fs/nfsd/nfscache.c     |    8 --------
 fs/nfsd/nfsctl.c       |   25 -------------------------
 fs/nfsd/nfsfh.c        |    9 ---------
 fs/nfsd/nfsproc.c      |   13 -------------
 fs/nfsd/nfssvc.c       |   15 ---------------
 fs/nfsd/nfsxdr.c       |    8 --------
 fs/nfsd/stats.c        |    5 -----
 fs/nfsd/vfs.c          |   20 --------------------
 22 files changed, 2 insertions(+), 237 deletions(-)

diff --git a/fs/nfsd/auth.c b/fs/nfsd/auth.c
index 36fcabb..ad354d2 100644
--- a/fs/nfsd/auth.c
+++ b/fs/nfsd/auth.c
@@ -4,12 +4,8 @@
  * Copyright (C) 1995, 1996 Olaf Kirch <okir-pn4DOG8n3UYbFoVRYvo4fw@public.gmane.org>
  */
 
-#include <linux/types.h>
 #include <linux/sched.h>
-#include <linux/sunrpc/svc.h>
-#include <linux/sunrpc/svcauth.h>
 #include <linux/nfsd/nfsd.h>
-#include <linux/nfsd/export.h>
 #include "auth.h"
 
 int nfsexp_flags(struct svc_rqst *rqstp, struct svc_export *exp)
diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index b73baba..68e63f4 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -14,27 +14,12 @@
  * Copyright (C) 1995, 1996 Olaf Kirch, <okir-pn4DOG8n3UYbFoVRYvo4fw@public.gmane.org>
  */
 
-#include <linux/unistd.h>
-#include <linux/slab.h>
-#include <linux/stat.h>
-#include <linux/in.h>
-#include <linux/seq_file.h>
-#include <linux/syscalls.h>
-#include <linux/rwsem.h>
-#include <linux/dcache.h>
 #include <linux/namei.h>
-#include <linux/mount.h>
-#include <linux/hash.h>
 #include <linux/module.h>
 #include <linux/exportfs.h>
 
-#include <linux/sunrpc/svc.h>
 #include <linux/nfsd/nfsd.h>
-#include <linux/nfsd/nfsfh.h>
 #include <linux/nfsd/syscall.h>
-#include <linux/lockd/bind.h>
-#include <linux/sunrpc/msg_prot.h>
-#include <linux/sunrpc/gss_api.h>
 #include <net/ipv6.h>
 
 #define NFSDDBG_FACILITY	NFSDDBG_EXPORT
diff --git a/fs/nfsd/lockd.c b/fs/nfsd/lockd.c
index 812bc64..801ef71 100644
--- a/fs/nfsd/lockd.c
+++ b/fs/nfsd/lockd.c
@@ -8,12 +8,7 @@
  * Copyright (C) 1996, Olaf Kirch <okir-pn4DOG8n3UYbFoVRYvo4fw@public.gmane.org>
  */
 
-#include <linux/types.h>
-#include <linux/fs.h>
 #include <linux/file.h>
-#include <linux/mount.h>
-#include <linux/sunrpc/clnt.h>
-#include <linux/sunrpc/svc.h>
 #include <linux/nfsd/nfsd.h>
 #include <linux/lockd/bind.h>
 #include "vfs.h"
diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
index 38c883d..a54628d 100644
--- a/fs/nfsd/nfs2acl.c
+++ b/fs/nfsd/nfs2acl.c
@@ -6,13 +6,9 @@
  * Copyright (C) 2002-2003 Andreas Gruenbacher <agruen@suse.de>
  */
 
-#include <linux/sunrpc/svc.h>
-#include <linux/nfs.h>
 #include <linux/nfsd/nfsd.h>
 #include <linux/nfsd/cache.h>
-#include <linux/nfsd/xdr.h>
 #include <linux/nfsd/xdr3.h>
-#include <linux/posix_acl.h>
 #include <linux/nfsacl.h>
 #include "vfs.h"
 
diff --git a/fs/nfsd/nfs3acl.c b/fs/nfsd/nfs3acl.c
index 526d85a..2f5c61b 100644
--- a/fs/nfsd/nfs3acl.c
+++ b/fs/nfsd/nfs3acl.c
@@ -6,12 +6,9 @@
  * Copyright (C) 2002-2003 Andreas Gruenbacher <agruen@suse.de>
  */
 
-#include <linux/sunrpc/svc.h>
-#include <linux/nfs3.h>
 #include <linux/nfsd/nfsd.h>
 #include <linux/nfsd/cache.h>
 #include <linux/nfsd/xdr3.h>
-#include <linux/posix_acl.h>
 #include <linux/nfsacl.h>
 #include "vfs.h"
 
diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 1a259d3..b694b43 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -6,25 +6,12 @@
  * Copyright (C) 1996, 1997, 1998 Olaf Kirch <okir-pn4DOG8n3UYbFoVRYvo4fw@public.gmane.org>
  */
 
-#include <linux/linkage.h>
-#include <linux/time.h>
-#include <linux/errno.h>
 #include <linux/fs.h>
 #include <linux/ext2_fs.h>
-#include <linux/stat.h>
-#include <linux/fcntl.h>
-#include <linux/net.h>
-#include <linux/in.h>
-#include <linux/unistd.h>
-#include <linux/slab.h>
-#include <linux/major.h>
 #include <linux/magic.h>
 
-#include <linux/sunrpc/svc.h>
-#include <linux/nfsd/nfsd.h>
 #include <linux/nfsd/cache.h>
 #include <linux/nfsd/xdr3.h>
-#include <linux/nfs3.h>
 #include "vfs.h"
 
 #define NFSDDBG_FACILITY		NFSDDBG_PROC
diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index d0a2ce1..623e13a 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -8,18 +8,7 @@
  * 2003-08-09 Jamie Lokier: Use htonl() for nanoseconds, not htons()!
  */
 
-#include <linux/types.h>
-#include <linux/time.h>
-#include <linux/nfs3.h>
-#include <linux/list.h>
-#include <linux/spinlock.h>
-#include <linux/dcache.h>
 #include <linux/namei.h>
-#include <linux/mm.h>
-#include <linux/vfs.h>
-#include <linux/sunrpc/xdr.h>
-#include <linux/sunrpc/svc.h>
-#include <linux/nfsd/nfsd.h>
 #include <linux/nfsd/xdr3.h>
 #include "auth.h"
 
diff --git a/fs/nfsd/nfs4acl.c b/fs/nfsd/nfs4acl.c
index 6d9c6aa..d6f0cea 100644
--- a/fs/nfsd/nfs4acl.c
+++ b/fs/nfsd/nfs4acl.c
@@ -36,15 +36,7 @@
  *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  */
 
-#include <linux/string.h>
-#include <linux/slab.h>
-#include <linux/list.h>
-#include <linux/types.h>
-#include <linux/fs.h>
-#include <linux/module.h>
 #include <linux/nfs_fs.h>
-#include <linux/posix_acl.h>
-#include <linux/nfs4.h>
 #include <linux/nfs4_acl.h>
 
 
diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 24e8d78..4fe3960 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -33,22 +33,9 @@
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
 #include <linux/sunrpc/clnt.h>
-#include <linux/sunrpc/svcsock.h>
 #include <linux/nfsd/nfsd.h>
 #include <linux/nfsd/state.h>
-#include <linux/sunrpc/sched.h>
-#include <linux/nfs4.h>
-#include <linux/sunrpc/xprtsock.h>
 
 #define NFSDDBG_FACILITY                NFSDDBG_PROC
 
diff --git a/fs/nfsd/nfs4idmap.c b/fs/nfsd/nfs4idmap.c
index ba2c199..8e518cd 100644
--- a/fs/nfsd/nfs4idmap.c
+++ b/fs/nfsd/nfs4idmap.c
@@ -35,22 +35,9 @@
  */
 
 #include <linux/module.h>
-#include <linux/init.h>
-
-#include <linux/mm.h>
-#include <linux/errno.h>
-#include <linux/string.h>
-#include <linux/sunrpc/clnt.h>
-#include <linux/nfs.h>
-#include <linux/nfs4.h>
-#include <linux/nfs_fs.h>
-#include <linux/nfs_page.h>
-#include <linux/sunrpc/cache.h>
 #include <linux/nfsd_idmap.h>
-#include <linux/list.h>
-#include <linux/time.h>
 #include <linux/seq_file.h>
-#include <linux/sunrpc/svcauth.h>
+#include <linux/sched.h>
 
 /*
  * Cache entry
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 60a93cd..d0e04cb 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -34,20 +34,10 @@
  *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  */
-
-#include <linux/param.h>
-#include <linux/major.h>
-#include <linux/slab.h>
 #include <linux/file.h>
 
-#include <linux/sunrpc/svc.h>
-#include <linux/nfsd/nfsd.h>
 #include <linux/nfsd/cache.h>
-#include <linux/nfs4.h>
-#include <linux/nfsd/state.h>
 #include <linux/nfsd/xdr4.h>
-#include <linux/nfs4_acl.h>
-#include <linux/sunrpc/gss_api.h>
 #include "vfs.h"
 
 #define NFSDDBG_FACILITY		NFSDDBG_PROC
diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index c7a6b24..48742f2 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -33,20 +33,12 @@
 *
 */
 
-#include <linux/err.h>
-#include <linux/sunrpc/svc.h>
 #include <linux/nfsd/nfsd.h>
-#include <linux/nfs4.h>
 #include <linux/nfsd/state.h>
-#include <linux/nfsd/xdr4.h>
-#include <linux/param.h>
 #include <linux/file.h>
 #include <linux/namei.h>
-#include <asm/uaccess.h>
-#include <linux/scatterlist.h>
 #include <linux/crypto.h>
 #include <linux/sched.h>
-#include <linux/mount.h>
 #include "vfs.h"
 
 #define NFSDDBG_FACILITY                NFSDDBG_PROC
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 850960e..1fe6e29 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -34,26 +34,11 @@
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
-#include <linux/nfsd/state.h>
 #include <linux/nfsd/xdr4.h>
 #include <linux/namei.h>
 #include <linux/swap.h>
-#include <linux/mutex.h>
-#include <linux/lockd/bind.h>
-#include <linux/module.h>
 #include <linux/sunrpc/svcauth_gss.h>
 #include <linux/sunrpc/clnt.h>
 #include "vfs.h"
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index db0fc55..2fa9682 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -40,22 +40,12 @@
  * at the end of nfs4svc_decode_compoundargs.
  */
 
-#include <linux/param.h>
-#include <linux/smp.h>
-#include <linux/fs.h>
 #include <linux/namei.h>
-#include <linux/vfs.h>
+#include <linux/statfs.h>
 #include <linux/utsname.h>
-#include <linux/sunrpc/xdr.h>
-#include <linux/sunrpc/svc.h>
-#include <linux/sunrpc/clnt.h>
-#include <linux/nfsd/nfsd.h>
-#include <linux/nfsd/state.h>
 #include <linux/nfsd/xdr4.h>
 #include <linux/nfsd_idmap.h>
-#include <linux/nfs4.h>
 #include <linux/nfs4_acl.h>
-#include <linux/sunrpc/gss_api.h>
 #include <linux/sunrpc/svcauth_gss.h>
 #include "vfs.h"
 
diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 4638635..96694b8 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -10,14 +10,6 @@
  * Copyright (C) 1995, 1996 Olaf Kirch <okir-pn4DOG8n3UYbFoVRYvo4fw@public.gmane.org>
  */
 
-#include <linux/kernel.h>
-#include <linux/time.h>
-#include <linux/slab.h>
-#include <linux/string.h>
-#include <linux/spinlock.h>
-#include <linux/list.h>
-
-#include <linux/sunrpc/svc.h>
 #include <linux/nfsd/nfsd.h>
 #include <linux/nfsd/cache.h>
 
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 5c01fc1..e4f49fd 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -6,42 +6,17 @@
  * Copyright (C) 1995, 1996 Olaf Kirch <okir-pn4DOG8n3UYbFoVRYvo4fw@public.gmane.org>
  */
 
-#include <linux/module.h>
-
-#include <linux/linkage.h>
-#include <linux/time.h>
-#include <linux/errno.h>
-#include <linux/fs.h>
 #include <linux/namei.h>
-#include <linux/fcntl.h>
-#include <linux/net.h>
-#include <linux/in.h>
-#include <linux/syscalls.h>
-#include <linux/unistd.h>
-#include <linux/slab.h>
-#include <linux/proc_fs.h>
-#include <linux/seq_file.h>
-#include <linux/pagemap.h>
-#include <linux/init.h>
-#include <linux/inet.h>
-#include <linux/string.h>
 #include <linux/ctype.h>
 
-#include <linux/nfs.h>
 #include <linux/nfsd_idmap.h>
-#include <linux/lockd/bind.h>
-#include <linux/sunrpc/svc.h>
 #include <linux/sunrpc/svcsock.h>
 #include <linux/nfsd/nfsd.h>
 #include <linux/nfsd/cache.h>
-#include <linux/nfsd/xdr.h>
 #include <linux/nfsd/syscall.h>
 #include <linux/lockd/lockd.h>
 #include <linux/sunrpc/clnt.h>
 
-#include <asm/uaccess.h>
-#include <net/ipv6.h>
-
 /*
  *	We have a single directory with 9 nodes in it.
  */
diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index d0d8a21..4ef4601 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -9,17 +9,8 @@
  * ... and again Southern-Winter 2001 to support export_operations
  */
 
-#include <linux/slab.h>
-#include <linux/fs.h>
-#include <linux/unistd.h>
-#include <linux/string.h>
-#include <linux/stat.h>
-#include <linux/dcache.h>
 #include <linux/exportfs.h>
-#include <linux/mount.h>
 
-#include <linux/sunrpc/clnt.h>
-#include <linux/sunrpc/svc.h>
 #include <linux/sunrpc/svcauth_gss.h>
 #include <linux/nfsd/nfsd.h>
 #include "vfs.h"
diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index 6c967e1..b6bd9e0 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -7,21 +7,8 @@
  * Copyright (C) 1995-1997 Olaf Kirch <okir-pn4DOG8n3UYbFoVRYvo4fw@public.gmane.org>
  */
 
-#include <linux/linkage.h>
-#include <linux/time.h>
-#include <linux/errno.h>
-#include <linux/fs.h>
-#include <linux/stat.h>
-#include <linux/fcntl.h>
-#include <linux/net.h>
-#include <linux/in.h>
 #include <linux/namei.h>
-#include <linux/unistd.h>
-#include <linux/slab.h>
 
-#include <linux/sunrpc/clnt.h>
-#include <linux/sunrpc/svc.h>
-#include <linux/nfsd/nfsd.h>
 #include <linux/nfsd/cache.h>
 #include <linux/nfsd/xdr.h>
 #include "vfs.h"
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 2944b31..b2d7ffa 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -8,30 +8,15 @@
  * Copyright (C) 1995, 1996, 1997 Olaf Kirch <okir-pn4DOG8n3UYbFoVRYvo4fw@public.gmane.org>
  */
 
-#include <linux/module.h>
 #include <linux/sched.h>
-#include <linux/time.h>
-#include <linux/errno.h>
-#include <linux/nfs.h>
-#include <linux/in.h>
-#include <linux/uio.h>
-#include <linux/unistd.h>
-#include <linux/slab.h>
-#include <linux/smp.h>
 #include <linux/freezer.h>
 #include <linux/fs_struct.h>
-#include <linux/kthread.h>
 #include <linux/swap.h>
 
-#include <linux/sunrpc/types.h>
 #include <linux/sunrpc/stats.h>
-#include <linux/sunrpc/svc.h>
 #include <linux/sunrpc/svcsock.h>
-#include <linux/sunrpc/cache.h>
 #include <linux/nfsd/nfsd.h>
-#include <linux/nfsd/stats.h>
 #include <linux/nfsd/cache.h>
-#include <linux/nfsd/syscall.h>
 #include <linux/lockd/bind.h>
 #include <linux/nfsacl.h>
 #include <linux/seq_file.h>
diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
index afd08e2..5e0603d 100644
--- a/fs/nfsd/nfsxdr.c
+++ b/fs/nfsd/nfsxdr.c
@@ -6,15 +6,7 @@
  * Copyright (C) 1995, 1996 Olaf Kirch <okir-pn4DOG8n3UYbFoVRYvo4fw@public.gmane.org>
  */
 
-#include <linux/types.h>
-#include <linux/time.h>
-#include <linux/nfs.h>
-#include <linux/vfs.h>
-#include <linux/sunrpc/xdr.h>
-#include <linux/sunrpc/svc.h>
-#include <linux/nfsd/nfsd.h>
 #include <linux/nfsd/xdr.h>
-#include <linux/mm.h>
 #include "auth.h"
 
 #define NFSDDBG_FACILITY		NFSDDBG_XDR
diff --git a/fs/nfsd/stats.c b/fs/nfsd/stats.c
index 71944cd..e3e411e 100644
--- a/fs/nfsd/stats.c
+++ b/fs/nfsd/stats.c
@@ -23,14 +23,9 @@
  * Copyright (C) 1995, 1996, 1997 Olaf Kirch <okir-pn4DOG8n3UYbFoVRYvo4fw@public.gmane.org>
  */
 
-#include <linux/kernel.h>
-#include <linux/time.h>
-#include <linux/proc_fs.h>
 #include <linux/seq_file.h>
-#include <linux/stat.h>
 #include <linux/module.h>
 
-#include <linux/sunrpc/svc.h>
 #include <linux/sunrpc/stats.h>
 #include <linux/nfsd/nfsd.h>
 #include <linux/nfsd/stats.h>
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index a7038ed..81ce108 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -16,43 +16,23 @@
  * Zerocpy NFS support (C) 2002 Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
  */
 
-#include <linux/string.h>
-#include <linux/time.h>
-#include <linux/errno.h>
 #include <linux/fs.h>
 #include <linux/file.h>
-#include <linux/mount.h>
-#include <linux/major.h>
 #include <linux/splice.h>
-#include <linux/proc_fs.h>
-#include <linux/stat.h>
 #include <linux/fcntl.h>
-#include <linux/net.h>
-#include <linux/unistd.h>
-#include <linux/slab.h>
-#include <linux/pagemap.h>
-#include <linux/in.h>
-#include <linux/module.h>
 #include <linux/namei.h>
-#include <linux/vfs.h>
 #include <linux/delay.h>
-#include <linux/sunrpc/svc.h>
 #include <linux/nfsd/nfsd.h>
 #ifdef CONFIG_NFSD_V3
-#include <linux/nfs3.h>
 #include <linux/nfsd/xdr3.h>
 #endif /* CONFIG_NFSD_V3 */
-#include <linux/nfsd/nfsfh.h>
 #include <linux/quotaops.h>
 #include <linux/fsnotify.h>
-#include <linux/posix_acl.h>
 #include <linux/posix_acl_xattr.h>
 #include <linux/xattr.h>
 #ifdef CONFIG_NFSD_V4
-#include <linux/nfs4.h>
 #include <linux/nfs4_acl.h>
 #include <linux/nfsd_idmap.h>
-#include <linux/security.h>
 #endif /* CONFIG_NFSD_V4 */
 #include <linux/jhash.h>
 #include <linux/ima.h>
-- 
1.6.5.2

