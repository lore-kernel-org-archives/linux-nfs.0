From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/2] NFS: Move fs/nfs/iostat.h to include/linux
Date: Fri, 06 Jun 2008 13:22:17 -0400
Message-ID: <20080606172216.14757.18706.stgit@manray.1015granger.net>
References: <20080606172037.14757.64893.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org, chuck.lever@oracle.com
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.242]:63473 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752422AbYFFRWV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Jun 2008 13:22:21 -0400
Received: by an-out-0708.google.com with SMTP id d40so291375and.103
        for <linux-nfs@vger.kernel.org>; Fri, 06 Jun 2008 10:22:20 -0700 (PDT)
In-Reply-To: <20080606172037.14757.64893.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The fs/nfs/iostat.h header has definitions that were designed to be exposed
to user space.  Move the header under include/linux so user space can use
the header in applications that read /proc/self/mountstats.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/client.c            |    2 
 fs/nfs/dir.c               |    2 
 fs/nfs/direct.c            |    2 
 fs/nfs/file.c              |    2 
 fs/nfs/inode.c             |    2 
 fs/nfs/iostat.h            |  164 -----------------------------------------
 fs/nfs/nfs3proc.c          |    2 
 fs/nfs/nfs4proc.c          |    2 
 fs/nfs/read.c              |    2 
 fs/nfs/super.c             |    2 
 fs/nfs/write.c             |    2 
 include/linux/nfs_iostat.h |  178 ++++++++++++++++++++++++++++++++++++++++++++
 12 files changed, 188 insertions(+), 174 deletions(-)
 delete mode 100644 fs/nfs/iostat.h
 create mode 100644 include/linux/nfs_iostat.h


diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index f2a092c..618faa3 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -32,6 +32,7 @@
 #include <linux/seq_file.h>
 #include <linux/mount.h>
 #include <linux/nfs_idmap.h>
+#include <linux/nfs_iostat.h>
 #include <linux/vfs.h>
 #include <linux/inet.h>
 #include <linux/in6.h>
@@ -43,7 +44,6 @@
 #include "nfs4_fs.h"
 #include "callback.h"
 #include "delegation.h"
-#include "iostat.h"
 #include "internal.h"
 
 #define NFSDBG_FACILITY		NFSDBG_CLIENT
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 425b984..a5cd722 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -28,6 +28,7 @@
 #include <linux/sunrpc/clnt.h>
 #include <linux/nfs_fs.h>
 #include <linux/nfs_mount.h>
+#include <linux/nfs_iostat.h>
 #include <linux/pagemap.h>
 #include <linux/smp_lock.h>
 #include <linux/pagevec.h>
@@ -37,7 +38,6 @@
 
 #include "nfs4_fs.h"
 #include "delegation.h"
-#include "iostat.h"
 #include "internal.h"
 
 /* #define NFS_DEBUG_VERBOSE 1 */
diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 08f6b04..581af62 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -47,6 +47,7 @@
 
 #include <linux/nfs_fs.h>
 #include <linux/nfs_page.h>
+#include <linux/nfs_iostat.h>
 #include <linux/sunrpc/clnt.h>
 
 #include <asm/system.h>
@@ -54,7 +55,6 @@
 #include <asm/atomic.h>
 
 #include "internal.h"
-#include "iostat.h"
 
 #define NFSDBG_FACILITY		NFSDBG_VFS
 
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index bba6181..b47c1f2 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -23,6 +23,7 @@
 #include <linux/stat.h>
 #include <linux/nfs_fs.h>
 #include <linux/nfs_mount.h>
+#include <linux/nfs_iostat.h>
 #include <linux/mm.h>
 #include <linux/slab.h>
 #include <linux/pagemap.h>
@@ -34,7 +35,6 @@
 
 #include "delegation.h"
 #include "internal.h"
-#include "iostat.h"
 
 #define NFSDBG_FACILITY		NFSDBG_FILE
 
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 596c5d8..5287f37 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -34,6 +34,7 @@
 #include <linux/seq_file.h>
 #include <linux/mount.h>
 #include <linux/nfs_idmap.h>
+#include <linux/nfs_iostat.h>
 #include <linux/vfs.h>
 #include <linux/inet.h>
 #include <linux/nfs_xdr.h>
@@ -44,7 +45,6 @@
 #include "nfs4_fs.h"
 #include "callback.h"
 #include "delegation.h"
-#include "iostat.h"
 #include "internal.h"
 
 #define NFSDBG_FACILITY		NFSDBG_VFS
diff --git a/fs/nfs/iostat.h b/fs/nfs/iostat.h
deleted file mode 100644
index 6350ecb..0000000
--- a/fs/nfs/iostat.h
+++ /dev/null
@@ -1,164 +0,0 @@
-/*
- *  linux/fs/nfs/iostat.h
- *
- *  Declarations for NFS client per-mount statistics
- *
- *  Copyright (C) 2005, 2006 Chuck Lever <cel@netapp.com>
- *
- *  NFS client per-mount statistics provide information about the health of
- *  the NFS client and the health of each NFS mount point.  Generally these
- *  are not for detailed problem diagnosis, but simply to indicate that there
- *  is a problem.
- *
- *  These counters are not meant to be human-readable, but are meant to be
- *  integrated into system monitoring tools such as "sar" and "iostat".  As
- *  such, the counters are sampled by the tools over time, and are never
- *  zeroed after a file system is mounted.  Moving averages can be computed
- *  by the tools by taking the difference between two instantaneous samples
- *  and dividing that by the time between the samples.
- */
-
-#ifndef _NFS_IOSTAT
-#define _NFS_IOSTAT
-
-#define NFS_IOSTAT_VERS		"1.0"
-
-/*
- * NFS byte counters
- *
- * 1.  SERVER - the number of payload bytes read from or written to the
- *     server by the NFS client via an NFS READ or WRITE request.
- *
- * 2.  NORMAL - the number of bytes read or written by applications via
- *     the read(2) and write(2) system call interfaces.
- *
- * 3.  DIRECT - the number of bytes read or written from files opened
- *     with the O_DIRECT flag.
- *
- * These counters give a view of the data throughput into and out of the NFS
- * client.  Comparing the number of bytes requested by an application with the
- * number of bytes the client requests from the server can provide an
- * indication of client efficiency (per-op, cache hits, etc).
- *
- * These counters can also help characterize which access methods are in
- * use.  DIRECT by itself shows whether there is any O_DIRECT traffic.
- * NORMAL + DIRECT shows how much data is going through the system call
- * interface.  A large amount of SERVER traffic without much NORMAL or
- * DIRECT traffic shows that applications are using mapped files.
- *
- * NFS page counters
- *
- * These count the number of pages read or written via nfs_readpage(),
- * nfs_readpages(), or their write equivalents.
- */
-enum nfs_stat_bytecounters {
-	NFSIOS_NORMALREADBYTES = 0,
-	NFSIOS_NORMALWRITTENBYTES,
-	NFSIOS_DIRECTREADBYTES,
-	NFSIOS_DIRECTWRITTENBYTES,
-	NFSIOS_SERVERREADBYTES,
-	NFSIOS_SERVERWRITTENBYTES,
-	NFSIOS_READPAGES,
-	NFSIOS_WRITEPAGES,
-	__NFSIOS_BYTESMAX,
-};
-
-/*
- * NFS event counters
- *
- * These counters provide a low-overhead way of monitoring client activity
- * without enabling NFS trace debugging.  The counters show the rate at
- * which VFS requests are made, and how often the client invalidates its
- * data and attribute caches.  This allows system administrators to monitor
- * such things as how close-to-open is working, and answer questions such
- * as "why are there so many GETATTR requests on the wire?"
- *
- * They also count anamolous events such as short reads and writes, silly
- * renames due to close-after-delete, and operations that change the size
- * of a file (such operations can often be the source of data corruption
- * if applications aren't using file locking properly).
- */
-enum nfs_stat_eventcounters {
-	NFSIOS_INODEREVALIDATE = 0,
-	NFSIOS_DENTRYREVALIDATE,
-	NFSIOS_DATAINVALIDATE,
-	NFSIOS_ATTRINVALIDATE,
-	NFSIOS_VFSOPEN,
-	NFSIOS_VFSLOOKUP,
-	NFSIOS_VFSACCESS,
-	NFSIOS_VFSUPDATEPAGE,
-	NFSIOS_VFSREADPAGE,
-	NFSIOS_VFSREADPAGES,
-	NFSIOS_VFSWRITEPAGE,
-	NFSIOS_VFSWRITEPAGES,
-	NFSIOS_VFSGETDENTS,
-	NFSIOS_VFSSETATTR,
-	NFSIOS_VFSFLUSH,
-	NFSIOS_VFSFSYNC,
-	NFSIOS_VFSLOCK,
-	NFSIOS_VFSRELEASE,
-	NFSIOS_CONGESTIONWAIT,
-	NFSIOS_SETATTRTRUNC,
-	NFSIOS_EXTENDWRITE,
-	NFSIOS_SILLYRENAME,
-	NFSIOS_SHORTREAD,
-	NFSIOS_SHORTWRITE,
-	NFSIOS_DELAY,
-	__NFSIOS_COUNTSMAX,
-};
-
-#ifdef __KERNEL__
-
-#include <linux/percpu.h>
-#include <linux/cache.h>
-
-struct nfs_iostats {
-	unsigned long long	bytes[__NFSIOS_BYTESMAX];
-	unsigned long		events[__NFSIOS_COUNTSMAX];
-} ____cacheline_aligned;
-
-static inline void nfs_inc_server_stats(struct nfs_server *server, enum nfs_stat_eventcounters stat)
-{
-	struct nfs_iostats *iostats;
-	int cpu;
-
-	cpu = get_cpu();
-	iostats = per_cpu_ptr(server->io_stats, cpu);
-	iostats->events[stat] ++;
-	put_cpu_no_resched();
-}
-
-static inline void nfs_inc_stats(struct inode *inode, enum nfs_stat_eventcounters stat)
-{
-	nfs_inc_server_stats(NFS_SERVER(inode), stat);
-}
-
-static inline void nfs_add_server_stats(struct nfs_server *server, enum nfs_stat_bytecounters stat, unsigned long addend)
-{
-	struct nfs_iostats *iostats;
-	int cpu;
-
-	cpu = get_cpu();
-	iostats = per_cpu_ptr(server->io_stats, cpu);
-	iostats->bytes[stat] += addend;
-	put_cpu_no_resched();
-}
-
-static inline void nfs_add_stats(struct inode *inode, enum nfs_stat_bytecounters stat, unsigned long addend)
-{
-	nfs_add_server_stats(NFS_SERVER(inode), stat, addend);
-}
-
-static inline struct nfs_iostats *nfs_alloc_iostats(void)
-{
-	return alloc_percpu(struct nfs_iostats);
-}
-
-static inline void nfs_free_iostats(struct nfs_iostats *stats)
-{
-	if (stats != NULL)
-		free_percpu(stats);
-}
-
-#endif
-#endif
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index c3523ad..d461eb3 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -17,8 +17,8 @@
 #include <linux/nfs_page.h>
 #include <linux/lockd/bind.h>
 #include <linux/nfs_mount.h>
+#include <linux/nfs_iostat.h>
 
-#include "iostat.h"
 #include "internal.h"
 
 #define NFSDBG_FACILITY		NFSDBG_PROC
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 1293e0a..df93fa8 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -45,6 +45,7 @@
 #include <linux/nfs4.h>
 #include <linux/nfs_fs.h>
 #include <linux/nfs_page.h>
+#include <linux/nfs_iostat.h>
 #include <linux/smp_lock.h>
 #include <linux/namei.h>
 #include <linux/mount.h>
@@ -52,7 +53,6 @@
 #include "nfs4_fs.h"
 #include "delegation.h"
 #include "internal.h"
-#include "iostat.h"
 
 #define NFSDBG_FACILITY		NFSDBG_PROC
 
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 40d1798..306363f 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -18,12 +18,12 @@
 #include <linux/sunrpc/clnt.h>
 #include <linux/nfs_fs.h>
 #include <linux/nfs_page.h>
+#include <linux/nfs_iostat.h>
 #include <linux/smp_lock.h>
 
 #include <asm/system.h>
 
 #include "internal.h"
-#include "iostat.h"
 
 #define NFSDBG_FACILITY		NFSDBG_PAGECACHE
 
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 2a4a024..ef27035 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -43,6 +43,7 @@
 #include <linux/seq_file.h>
 #include <linux/mount.h>
 #include <linux/nfs_idmap.h>
+#include <linux/nfs_iostat.h>
 #include <linux/vfs.h>
 #include <linux/inet.h>
 #include <linux/in6.h>
@@ -57,7 +58,6 @@
 #include "nfs4_fs.h"
 #include "callback.h"
 #include "delegation.h"
-#include "iostat.h"
 #include "internal.h"
 
 #define NFSDBG_FACILITY		NFSDBG_VFS
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index c03a039..1bb0593 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -18,13 +18,13 @@
 #include <linux/nfs_fs.h>
 #include <linux/nfs_mount.h>
 #include <linux/nfs_page.h>
+#include <linux/nfs_iostat.h>
 #include <linux/backing-dev.h>
 
 #include <asm/uaccess.h>
 
 #include "delegation.h"
 #include "internal.h"
-#include "iostat.h"
 
 #define NFSDBG_FACILITY		NFSDBG_PAGECACHE
 
diff --git a/include/linux/nfs_iostat.h b/include/linux/nfs_iostat.h
new file mode 100644
index 0000000..cdfa9de
--- /dev/null
+++ b/include/linux/nfs_iostat.h
@@ -0,0 +1,178 @@
+/*
+ *  Declarations for NFS client per-mount statistics
+ *
+ *  Copyright (C) 2005, 2006 Chuck Lever <cel@netapp.com>
+ *
+ *  NFS client per-mount statistics provide information about the
+ *  health of the NFS client and the health of each NFS mount point.
+ *  Generally these are not for detailed problem diagnosis, but
+ *  simply to indicate that there is a problem.
+ *
+ *  These counters are not meant to be human-readable, but are meant
+ *  to be integrated into system monitoring tools such as "sar" and
+ *  "iostat".  As such, the counters are sampled by the tools over
+ *  time, and are never zeroed after a file system is mounted.
+ *  Moving averages can be computed by the tools by taking the
+ *  difference between two instantaneous samples  and dividing that
+ *  by the time between the samples.
+ */
+
+#ifndef _NFS_IOSTAT
+#define _NFS_IOSTAT
+
+#define NFS_IOSTAT_VERS		"1.0"
+
+/*
+ * NFS byte counters
+ *
+ * 1.  SERVER - the number of payload bytes read from or written
+ *     to the server by the NFS client via an NFS READ or WRITE
+ *     request.
+ *
+ * 2.  NORMAL - the number of bytes read or written by applications
+ *     via the read(2) and write(2) system call interfaces.
+ *
+ * 3.  DIRECT - the number of bytes read or written from files
+ *     opened with the O_DIRECT flag.
+ *
+ * These counters give a view of the data throughput into and out
+ * of the NFS client.  Comparing the number of bytes requested by
+ * an application with the number of bytes the client requests from
+ * the server can provide an indication of client efficiency
+ * (per-op, cache hits, etc).
+ *
+ * These counters can also help characterize which access methods
+ * are in use.  DIRECT by itself shows whether there is any O_DIRECT
+ * traffic.  NORMAL + DIRECT shows how much data is going through
+ * the system call interface.  A large amount of SERVER traffic
+ * without much NORMAL or DIRECT traffic shows that applications
+ * are using mapped files.
+ *
+ * NFS page counters
+ *
+ * These count the number of pages read or written via nfs_readpage(),
+ * nfs_readpages(), or their write equivalents.
+ *
+ * NB: When adding new byte counters, please include the measured
+ * units in the name of each byte counter to help users of this
+ * interface determine what exactly is being counted.
+ */
+enum nfs_stat_bytecounters {
+	NFSIOS_NORMALREADBYTES = 0,
+	NFSIOS_NORMALWRITTENBYTES,
+	NFSIOS_DIRECTREADBYTES,
+	NFSIOS_DIRECTWRITTENBYTES,
+	NFSIOS_SERVERREADBYTES,
+	NFSIOS_SERVERWRITTENBYTES,
+	NFSIOS_READPAGES,
+	NFSIOS_WRITEPAGES,
+	__NFSIOS_BYTESMAX,
+};
+
+/*
+ * NFS event counters
+ *
+ * These counters provide a low-overhead way of monitoring client
+ * activity without enabling NFS trace debugging.  The counters
+ * show the rate at which VFS requests are made, and how often the
+ * client invalidates its data and attribute caches.  This allows
+ * system administrators to monitor such things as how close-to-open
+ * is working, and answer questions such as "why are there so many
+ * GETATTR requests on the wire?"
+ *
+ * They also count anamolous events such as short reads and writes,
+ * silly renames due to close-after-delete, and operations that
+ * change the size of a file (such operations can often be the
+ * source of data corruption if applications aren't using file
+ * locking properly).
+ */
+enum nfs_stat_eventcounters {
+	NFSIOS_INODEREVALIDATE = 0,
+	NFSIOS_DENTRYREVALIDATE,
+	NFSIOS_DATAINVALIDATE,
+	NFSIOS_ATTRINVALIDATE,
+	NFSIOS_VFSOPEN,
+	NFSIOS_VFSLOOKUP,
+	NFSIOS_VFSACCESS,
+	NFSIOS_VFSUPDATEPAGE,
+	NFSIOS_VFSREADPAGE,
+	NFSIOS_VFSREADPAGES,
+	NFSIOS_VFSWRITEPAGE,
+	NFSIOS_VFSWRITEPAGES,
+	NFSIOS_VFSGETDENTS,
+	NFSIOS_VFSSETATTR,
+	NFSIOS_VFSFLUSH,
+	NFSIOS_VFSFSYNC,
+	NFSIOS_VFSLOCK,
+	NFSIOS_VFSRELEASE,
+	NFSIOS_CONGESTIONWAIT,
+	NFSIOS_SETATTRTRUNC,
+	NFSIOS_EXTENDWRITE,
+	NFSIOS_SILLYRENAME,
+	NFSIOS_SHORTREAD,
+	NFSIOS_SHORTWRITE,
+	NFSIOS_DELAY,
+	__NFSIOS_COUNTSMAX,
+};
+
+#ifdef __KERNEL__
+
+#include <linux/percpu.h>
+#include <linux/cache.h>
+
+struct nfs_iostats {
+	unsigned long long	bytes[__NFSIOS_BYTESMAX];
+	unsigned long		events[__NFSIOS_COUNTSMAX];
+} ____cacheline_aligned;
+
+static inline void nfs_inc_server_stats(struct nfs_server *server,
+					enum nfs_stat_eventcounters stat)
+{
+	struct nfs_iostats *iostats;
+	int cpu;
+
+	cpu = get_cpu();
+	iostats = per_cpu_ptr(server->io_stats, cpu);
+	iostats->events[stat]++;
+	put_cpu_no_resched();
+}
+
+static inline void nfs_inc_stats(struct inode *inode,
+				 enum nfs_stat_eventcounters stat)
+{
+	nfs_inc_server_stats(NFS_SERVER(inode), stat);
+}
+
+static inline void nfs_add_server_stats(struct nfs_server *server,
+					enum nfs_stat_bytecounters stat,
+					unsigned long addend)
+{
+	struct nfs_iostats *iostats;
+	int cpu;
+
+	cpu = get_cpu();
+	iostats = per_cpu_ptr(server->io_stats, cpu);
+	iostats->bytes[stat] += addend;
+	put_cpu_no_resched();
+}
+
+static inline void nfs_add_stats(struct inode *inode,
+				 enum nfs_stat_bytecounters stat,
+				 unsigned long addend)
+{
+	nfs_add_server_stats(NFS_SERVER(inode), stat, addend);
+}
+
+static inline struct nfs_iostats *nfs_alloc_iostats(void)
+{
+	return alloc_percpu(struct nfs_iostats);
+}
+
+static inline void nfs_free_iostats(struct nfs_iostats *stats)
+{
+	if (stats != NULL)
+		free_percpu(stats);
+}
+
+#endif
+#endif

