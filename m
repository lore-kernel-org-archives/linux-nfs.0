Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:44448 "EHLO
        mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752504AbcISUTb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Sep 2016 16:19:31 -0400
From: Paul Gortmaker <paul.gortmaker@windriver.com>
To: <linux-kernel@vger.kernel.org>
CC: Paul Gortmaker <paul.gortmaker@windriver.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        <linux-nfs@vger.kernel.org>
Subject: [PATCH] NFS: audit and remove any unnecessary uses of module.h
Date: Mon, 19 Sep 2016 16:19:15 -0400
Message-ID: <20160919201915.28982-1-paul.gortmaker@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Historically a lot of these existed because we did not have
a distinction between what was modular code and what was providing
support to modules via EXPORT_SYMBOL and friends.  That changed
when we forked out support for the latter into the export.h file.
This means we should be able to reduce the usage of module.h
in code that is obj-y Makefile or bool Kconfig.

In the case of some code where it is modular, we can extend that to
also include files that are building basic support functionality but
not related to loading or registering the final module; such files
also have no need whatsoever for module.h

The advantage in removing such instances is that module.h itself
sources about 15 other headers; adding significantly to what we feed
cpp, and it can obscure what headers we are effectively using.

Since module.h might have been the implicit source for init.h
(for __init) and for export.h (for EXPORT_SYMBOL) we consider each
instance for the presence of either and replace as needed.

We also keep an eye out for module_param usage that doesn't have the
corresponding moduleparam.h and fix accordingly.

Cc: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@poochiereds.net>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---

[I've been building this on linux-next on a regular basis for
 allmodconfig for x86(32/64) ARM(32/64) ppc and mips so there
 shouldn't be any unseen fallout.]

 fs/nfs/cache_lib.c                        | 1 -
 fs/nfs/callback.c                         | 1 -
 fs/nfs/delegation.c                       | 2 +-
 fs/nfs/dir.c                              | 3 ++-
 fs/nfs/direct.c                           | 2 +-
 fs/nfs/file.c                             | 2 +-
 fs/nfs/filelayout/filelayoutdev.c         | 2 +-
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 2 +-
 fs/nfs/getroot.c                          | 2 --
 fs/nfs/inode.c                            | 1 +
 fs/nfs/namespace.c                        | 2 +-
 fs/nfs/nfs4client.c                       | 2 +-
 fs/nfs/nfs4idmap.c                        | 2 +-
 fs/nfs/nfs4proc.c                         | 2 +-
 fs/nfs/nfs4session.c                      | 2 +-
 fs/nfs/nfs4xdr.c                          | 2 +-
 fs/nfs/pnfs_nfs.c                         | 2 +-
 fs/nfs/read.c                             | 2 +-
 fs/nfs/super.c                            | 4 ++--
 fs/nfs/sysctl.c                           | 1 -
 fs/nfsd/export.c                          | 1 -
 fs/nfsd/fault_inject.c                    | 1 -
 fs/nfsd/nfs4idmap.c                       | 2 +-
 fs/nfsd/nfs4recover.c                     | 1 +
 fs/nfsd/stats.c                           | 1 -
 25 files changed, 20 insertions(+), 25 deletions(-)

diff --git a/fs/nfs/cache_lib.c b/fs/nfs/cache_lib.c
index 5f7b053720ee..3f8ebf4c4987 100644
--- a/fs/nfs/cache_lib.c
+++ b/fs/nfs/cache_lib.c
@@ -6,7 +6,6 @@
  * Copyright (c) 2009 Trond Myklebust <Trond.Myklebust@netapp.com>
  */
 #include <linux/kmod.h>
-#include <linux/module.h>
 #include <linux/moduleparam.h>
 #include <linux/mount.h>
 #include <linux/namei.h>
diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index a7f2e6e33305..908ea10d95f7 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -8,7 +8,6 @@
 
 #include <linux/completion.h>
 #include <linux/ip.h>
-#include <linux/module.h>
 #include <linux/sunrpc/svc.h>
 #include <linux/sunrpc/svcsock.h>
 #include <linux/nfs_fs.h>
diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 322c2585bc34..c05e3369f684 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -8,7 +8,7 @@
  */
 #include <linux/completion.h>
 #include <linux/kthread.h>
-#include <linux/module.h>
+#include <linux/export.h>
 #include <linux/sched.h>
 #include <linux/slab.h>
 #include <linux/spinlock.h>
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 177fefb26c18..7d547a147cdd 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -17,7 +17,8 @@
  *  6 Jun 1999	Cache readdir lookups in the page cache. -DaveM
  */
 
-#include <linux/module.h>
+#include <linux/moduleparam.h>
+#include <linux/export.h>
 #include <linux/time.h>
 #include <linux/errno.h>
 #include <linux/stat.h>
diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 72b7d13ee3c6..2eb8df0bb186 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -46,7 +46,7 @@
 #include <linux/kref.h>
 #include <linux/slab.h>
 #include <linux/task_io_accounting_ops.h>
-#include <linux/module.h>
+#include <linux/export.h>
 
 #include <linux/nfs_fs.h>
 #include <linux/nfs_page.h>
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 7d620970f2e1..47d51ef87f74 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -16,7 +16,7 @@
  *  nfs regular file handling functions
  */
 
-#include <linux/module.h>
+#include <linux/export.h>
 #include <linux/time.h>
 #include <linux/kernel.h>
 #include <linux/errno.h>
diff --git a/fs/nfs/filelayout/filelayoutdev.c b/fs/nfs/filelayout/filelayoutdev.c
index 4946ef40ba87..d77ce25041b6 100644
--- a/fs/nfs/filelayout/filelayoutdev.c
+++ b/fs/nfs/filelayout/filelayoutdev.c
@@ -30,7 +30,7 @@
 
 #include <linux/nfs_fs.h>
 #include <linux/vmalloc.h>
-#include <linux/module.h>
+#include <linux/moduleparam.h>
 
 #include "../internal.h"
 #include "../nfs4session.h"
diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index 0aa36be71fce..93e2893ed834 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -8,7 +8,7 @@
 
 #include <linux/nfs_fs.h>
 #include <linux/vmalloc.h>
-#include <linux/module.h>
+#include <linux/moduleparam.h>
 #include <linux/sunrpc/addr.h>
 
 #include "../internal.h"
diff --git a/fs/nfs/getroot.c b/fs/nfs/getroot.c
index a608ffd28acc..71e7bdd00ac3 100644
--- a/fs/nfs/getroot.c
+++ b/fs/nfs/getroot.c
@@ -9,9 +9,7 @@
  * 2 of the License, or (at your option) any later version.
  */
 
-#include <linux/module.h>
 #include <linux/init.h>
-
 #include <linux/time.h>
 #include <linux/kernel.h>
 #include <linux/mm.h>
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index bf4ec5ecc97e..3b669b0190d5 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -14,6 +14,7 @@
  */
 
 #include <linux/module.h>
+#include <linux/moduleparam.h>
 #include <linux/init.h>
 #include <linux/sched.h>
 #include <linux/time.h>
diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index c8162c660c44..274e323a4cab 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -7,7 +7,7 @@
  * NFS namespace
  */
 
-#include <linux/module.h>
+#include <linux/export.h>
 #include <linux/dcache.h>
 #include <linux/gfp.h>
 #include <linux/mount.h>
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 8d7d08d4f95f..f19fb30c57c2 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -2,7 +2,7 @@
  * Copyright (C) 2006 Red Hat, Inc. All Rights Reserved.
  * Written by David Howells (dhowells@redhat.com)
  */
-#include <linux/module.h>
+#include <linux/export.h>
 #include <linux/nfs_fs.h>
 #include <linux/nfs_mount.h>
 #include <linux/sunrpc/addr.h>
diff --git a/fs/nfs/nfs4idmap.c b/fs/nfs/nfs4idmap.c
index c444285bb1b1..3ae3003586ea 100644
--- a/fs/nfs/nfs4idmap.c
+++ b/fs/nfs/nfs4idmap.c
@@ -44,7 +44,7 @@
 #include <linux/keyctl.h>
 #include <linux/key-type.h>
 #include <keys/user-type.h>
-#include <linux/module.h>
+#include <linux/export.h>
 
 #include "internal.h"
 #include "netns.h"
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index a036e93bdf96..03e62a1d35a0 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -51,7 +51,7 @@
 #include <linux/nfs_mount.h>
 #include <linux/namei.h>
 #include <linux/mount.h>
-#include <linux/module.h>
+#include <linux/export.h>
 #include <linux/xattr.h>
 #include <linux/utsname.h>
 #include <linux/freezer.h>
diff --git a/fs/nfs/nfs4session.c b/fs/nfs/nfs4session.c
index 332d06e64fa9..631b7c795212 100644
--- a/fs/nfs/nfs4session.c
+++ b/fs/nfs/nfs4session.c
@@ -14,7 +14,7 @@
 #include <linux/nfs.h>
 #include <linux/nfs4.h>
 #include <linux/nfs_fs.h>
-#include <linux/module.h>
+#include <linux/export.h>
 
 #include "nfs4_fs.h"
 #include "internal.h"
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 7bd3a5c09d31..901b94e25af7 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -44,7 +44,7 @@
 #include <linux/pagemap.h>
 #include <linux/proc_fs.h>
 #include <linux/kdev_t.h>
-#include <linux/module.h>
+#include <linux/export.h>
 #include <linux/utsname.h>
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/msg_prot.h>
diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index f3468b57a32a..55270bcb735d 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -10,7 +10,7 @@
 #include <linux/nfs_fs.h>
 #include <linux/nfs_page.h>
 #include <linux/sunrpc/addr.h>
-#include <linux/module.h>
+#include <linux/export.h>
 
 #include "nfs4session.h"
 #include "internal.h"
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 572e5b3b06f1..701436dcca56 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -18,7 +18,7 @@
 #include <linux/sunrpc/clnt.h>
 #include <linux/nfs_fs.h>
 #include <linux/nfs_page.h>
-#include <linux/module.h>
+#include <linux/export.h>
 
 #include "nfs4_fs.h"
 #include "internal.h"
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 18d446e1a82b..6a10c88c105d 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -20,9 +20,9 @@
  *   of another (see nfs_lookup())
  */
 
-#include <linux/module.h>
 #include <linux/init.h>
-
+#include <linux/export.h>
+#include <linux/moduleparam.h>
 #include <linux/time.h>
 #include <linux/kernel.h>
 #include <linux/mm.h>
diff --git a/fs/nfs/sysctl.c b/fs/nfs/sysctl.c
index bb6ed810fa6f..5ee2ad532138 100644
--- a/fs/nfs/sysctl.c
+++ b/fs/nfs/sysctl.c
@@ -8,7 +8,6 @@
 #include <linux/ctype.h>
 #include <linux/fs.h>
 #include <linux/sysctl.h>
-#include <linux/module.h>
 #include <linux/nfs_fs.h>
 
 static struct ctl_table_header *nfs_callback_sysctl_table;
diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 43e109cc0ccc..2dfd81efc04e 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -13,7 +13,6 @@
 
 #include <linux/slab.h>
 #include <linux/namei.h>
-#include <linux/module.h>
 #include <linux/exportfs.h>
 #include <linux/sunrpc/svc_xprt.h>
 
diff --git a/fs/nfsd/fault_inject.c b/fs/nfsd/fault_inject.c
index c16bf5af6831..404bd11a9709 100644
--- a/fs/nfsd/fault_inject.c
+++ b/fs/nfsd/fault_inject.c
@@ -7,7 +7,6 @@
 #include <linux/types.h>
 #include <linux/fs.h>
 #include <linux/debugfs.h>
-#include <linux/module.h>
 #include <linux/nsproxy.h>
 #include <linux/sunrpc/addr.h>
 #include <asm/uaccess.h>
diff --git a/fs/nfsd/nfs4idmap.c b/fs/nfsd/nfs4idmap.c
index 5b20577dcdd2..2a329b5c453c 100644
--- a/fs/nfsd/nfs4idmap.c
+++ b/fs/nfsd/nfs4idmap.c
@@ -32,7 +32,7 @@
  *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  */
 
-#include <linux/module.h>
+#include <linux/moduleparam.h>
 #include <linux/seq_file.h>
 #include <linux/sched.h>
 #include <linux/slab.h>
diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 66eaeb1e8c2c..73d985af4ad8 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -39,6 +39,7 @@
 #include <linux/sched.h>
 #include <linux/fs.h>
 #include <linux/module.h>
+#include <linux/moduleparam.h>
 #include <net/net_namespace.h>
 #include <linux/sunrpc/rpc_pipe_fs.h>
 #include <linux/sunrpc/clnt.h>
diff --git a/fs/nfsd/stats.c b/fs/nfsd/stats.c
index d97338bb6a39..852ff9d31942 100644
--- a/fs/nfsd/stats.c
+++ b/fs/nfsd/stats.c
@@ -22,7 +22,6 @@
  */
 
 #include <linux/seq_file.h>
-#include <linux/module.h>
 #include <linux/sunrpc/stats.h>
 #include <net/net_namespace.h>
 
-- 
2.8.4

