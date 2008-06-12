From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 32/37] NFS: Move fs/nfs/iostat.h to include/linux
Date: Thu, 12 Jun 2008 15:22:01 -0400
Message-ID: <20080612192201.24528.70875.stgit@localhost.localdomain>
References: <20080612192159.24528.43756.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Chuck Lever <chuck.lever@oracle.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:40624 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755126AbYFLTeK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jun 2008 15:34:10 -0400
In-Reply-To: <20080612192159.24528.43756.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

The fs/nfs/iostat.h header has definitions that were designed to be exposed
to user space.  Move these definitions under include/linux so user space can
use the definitions in applications that read /proc/self/mountstats.

Also address a handful of coding style issues called out by checkpatch.pl in
fs/nfs/iostat.h.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/iostat.h            |  119 +++++---------------------------------------
 include/linux/nfs_iostat.h |  119 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 132 insertions(+), 106 deletions(-)

diff --git a/fs/nfs/iostat.h b/fs/nfs/iostat.h
index 6350ecb..2ec65e1 100644
--- a/fs/nfs/iostat.h
+++ b/fs/nfs/iostat.h
@@ -5,135 +5,41 @@
  *
  *  Copyright (C) 2005, 2006 Chuck Lever <cel@netapp.com>
  *
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
  */
 
 #ifndef _NFS_IOSTAT
 #define _NFS_IOSTAT
 
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
 #include <linux/percpu.h>
 #include <linux/cache.h>
+#include <linux/nfs_iostat.h>
 
 struct nfs_iostats {
 	unsigned long long	bytes[__NFSIOS_BYTESMAX];
 	unsigned long		events[__NFSIOS_COUNTSMAX];
 } ____cacheline_aligned;
 
-static inline void nfs_inc_server_stats(struct nfs_server *server, enum nfs_stat_eventcounters stat)
+static inline void nfs_inc_server_stats(struct nfs_server *server,
+					enum nfs_stat_eventcounters stat)
 {
 	struct nfs_iostats *iostats;
 	int cpu;
 
 	cpu = get_cpu();
 	iostats = per_cpu_ptr(server->io_stats, cpu);
-	iostats->events[stat] ++;
+	iostats->events[stat]++;
 	put_cpu_no_resched();
 }
 
-static inline void nfs_inc_stats(struct inode *inode, enum nfs_stat_eventcounters stat)
+static inline void nfs_inc_stats(struct inode *inode,
+				 enum nfs_stat_eventcounters stat)
 {
 	nfs_inc_server_stats(NFS_SERVER(inode), stat);
 }
 
-static inline void nfs_add_server_stats(struct nfs_server *server, enum nfs_stat_bytecounters stat, unsigned long addend)
+static inline void nfs_add_server_stats(struct nfs_server *server,
+					enum nfs_stat_bytecounters stat,
+					unsigned long addend)
 {
 	struct nfs_iostats *iostats;
 	int cpu;
@@ -144,7 +50,9 @@ static inline void nfs_add_server_stats(struct nfs_server *server, enum nfs_stat
 	put_cpu_no_resched();
 }
 
-static inline void nfs_add_stats(struct inode *inode, enum nfs_stat_bytecounters stat, unsigned long addend)
+static inline void nfs_add_stats(struct inode *inode,
+				 enum nfs_stat_bytecounters stat,
+				 unsigned long addend)
 {
 	nfs_add_server_stats(NFS_SERVER(inode), stat, addend);
 }
@@ -160,5 +68,4 @@ static inline void nfs_free_iostats(struct nfs_iostats *stats)
 		free_percpu(stats);
 }
 
-#endif
-#endif
+#endif /* _NFS_IOSTAT */
diff --git a/include/linux/nfs_iostat.h b/include/linux/nfs_iostat.h
new file mode 100644
index 0000000..1cb9a3f
--- /dev/null
+++ b/include/linux/nfs_iostat.h
@@ -0,0 +1,119 @@
+/*
+ *  User-space visible declarations for NFS client per-mount
+ *  point statistics
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
+#ifndef _LINUX_NFS_IOSTAT
+#define _LINUX_NFS_IOSTAT
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
+#endif	/* _LINUX_NFS_IOSTAT */

