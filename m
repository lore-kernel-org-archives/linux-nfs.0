From: NeilBrown <neilb@suse.de>
Subject: [PATCH 009 of 11] knfsd: Allow max size of NFSd payload to be
	configured.
Date: Thu, 24 Aug 2006 16:37:16 +1000
Message-ID: <1060824063716.5020@suse.de>
References: <20060824162917.3600.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GG8q4-00039D-PM
	for nfs@lists.sourceforge.net; Wed, 23 Aug 2006 23:37:16 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GG8q4-0002yN-8p
	for nfs@lists.sourceforge.net; Wed, 23 Aug 2006 23:37:17 -0700
To: Andrew Morton <akpm@osdl.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


The max possible is the maximum RPC payload.
The default depends on amount of total memory.

The value can be set within reason as long as 
 no nfsd threads are currently running.
The value can also be ready, allowing the default
to be determined after nfsd has started.

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfsctl.c           |   33 +++++++++++++++++++++++++++++++++
 ./fs/nfsd/nfssvc.c           |   19 ++++++++++++++++++-
 ./include/linux/nfsd/const.h |    4 ++--
 ./include/linux/nfsd/nfsd.h  |    1 +
 4 files changed, 54 insertions(+), 3 deletions(-)

diff .prev/fs/nfsd/nfsctl.c ./fs/nfsd/nfsctl.c
--- .prev/fs/nfsd/nfsctl.c	2006-08-24 16:24:56.000000000 +1000
+++ ./fs/nfsd/nfsctl.c	2006-08-24 16:26:10.000000000 +1000
@@ -57,6 +57,7 @@ enum {
 	NFSD_Pool_Threads,
 	NFSD_Versions,
 	NFSD_Ports,
+	NFSD_MaxBlkSize,
 	/*
 	 * The below MUST come last.  Otherwise we leave a hole in nfsd_files[]
 	 * with !CONFIG_NFSD_V4 and simple_fill_super() goes oops
@@ -82,6 +83,7 @@ static ssize_t write_threads(struct file
 static ssize_t write_pool_threads(struct file *file, char *buf, size_t size);
 static ssize_t write_versions(struct file *file, char *buf, size_t size);
 static ssize_t write_ports(struct file *file, char *buf, size_t size);
+static ssize_t write_maxblksize(struct file *file, char *buf, size_t size);
 #ifdef CONFIG_NFSD_V4
 static ssize_t write_leasetime(struct file *file, char *buf, size_t size);
 static ssize_t write_recoverydir(struct file *file, char *buf, size_t size);
@@ -100,6 +102,7 @@ static ssize_t (*write_op[])(struct file
 	[NFSD_Pool_Threads] = write_pool_threads,
 	[NFSD_Versions] = write_versions,
 	[NFSD_Ports] = write_ports,
+	[NFSD_MaxBlkSize] = write_maxblksize,
 #ifdef CONFIG_NFSD_V4
 	[NFSD_Leasetime] = write_leasetime,
 	[NFSD_RecoveryDir] = write_recoverydir,
@@ -555,6 +558,35 @@ static ssize_t write_ports(struct file *
 	return -EINVAL;
 }
 
+int nfsd_max_blksize;
+
+static ssize_t write_maxblksize(struct file *file, char *buf, size_t size)
+{
+	char *mesg = buf;
+	if (size > 0) {
+		int bsize;
+		int rv = get_int(&mesg, &bsize);
+		if (rv)
+			return rv;
+		/* force bsize into allowed range and
+		 * required alignment.
+		 */
+		if (bsize < 1024)
+			bsize = 1024;
+		if (bsize > NFSSVC_MAXBLKSIZE)
+			bsize = NFSSVC_MAXBLKSIZE;
+		bsize &= ~(1024-1);
+		lock_kernel();
+		if (nfsd_serv && nfsd_serv->sv_nrthreads) {
+			unlock_kernel();
+			return -EBUSY;
+		}
+		nfsd_max_blksize = bsize;
+		unlock_kernel();
+	}
+	return sprintf(buf, "%d\n", nfsd_max_blksize);
+}
+
 #ifdef CONFIG_NFSD_V4
 extern time_t nfs4_leasetime(void);
 
@@ -620,6 +652,7 @@ static int nfsd_fill_super(struct super_
 		[NFSD_Pool_Threads] = {"pool_threads", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Versions] = {"versions", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Ports] = {"portlist", &transaction_ops, S_IWUSR|S_IRUGO},
+		[NFSD_MaxBlkSize] = {"max_block_size", &transaction_ops, S_IWUSR|S_IRUGO},
 #ifdef CONFIG_NFSD_V4
 		[NFSD_Leasetime] = {"nfsv4leasetime", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_RecoveryDir] = {"nfsv4recoverydir", &transaction_ops, S_IWUSR|S_IRUSR},

diff .prev/fs/nfsd/nfssvc.c ./fs/nfsd/nfssvc.c
--- .prev/fs/nfsd/nfssvc.c	2006-08-24 16:26:10.000000000 +1000
+++ ./fs/nfsd/nfssvc.c	2006-08-24 16:26:10.000000000 +1000
@@ -198,9 +198,26 @@ int nfsd_create_serv(void)
 		unlock_kernel();
 		return 0;
 	}
+	if (nfsd_max_blksize == 0) {
+		/* choose a suitable default */
+		struct sysinfo i;
+		si_meminfo(&i);
+		/* Aim for 1/4096 of memory per thread
+		 * This gives 1MB on 4Gig machines
+		 * But only uses 32K on 128M machines.
+		 * Bottom out at 8K on 32M and smaller.
+		 * Of course, this is only a default.
+		 */
+		nfsd_max_blksize = NFSSVC_MAXBLKSIZE;
+		i.totalram >>= 12;
+		while (nfsd_max_blksize > i.totalram &&
+		       nfsd_max_blksize >= 8*1024*2)
+			nfsd_max_blksize /= 2;
+	}
 
 	atomic_set(&nfsd_busy, 0);
-	nfsd_serv = svc_create_pooled(&nfsd_program, NFSD_BUFSIZE,
+	nfsd_serv = svc_create_pooled(&nfsd_program,
+				      NFSD_BUFSIZE - NFSSVC_MAXBLKSIZE + nfsd_max_blksize,
 				      nfsd_last_thread,
 				      nfsd, SIG_NOCLEAN, THIS_MODULE);
 	if (nfsd_serv == NULL)

diff .prev/include/linux/nfsd/const.h ./include/linux/nfsd/const.h
--- .prev/include/linux/nfsd/const.h	2006-08-24 16:25:56.000000000 +1000
+++ ./include/linux/nfsd/const.h	2006-08-24 16:26:10.000000000 +1000
@@ -21,9 +21,9 @@
 #define NFSSVC_MAXVERS		3
 
 /*
- * Maximum blocksize supported by daemon currently at 32K
+ * Maximum blocksizes supported by daemon under various circumstances.
  */
-#define NFSSVC_MAXBLKSIZE	(32*1024)
+#define NFSSVC_MAXBLKSIZE	RPCSVC_MAXPAYLOAD
 /* NFSv2 is limited by the protocol specification, see RFC 1094 */
 #define NFSSVC_MAXBLKSIZE_V2	(8*1024)
 

diff .prev/include/linux/nfsd/nfsd.h ./include/linux/nfsd/nfsd.h
--- .prev/include/linux/nfsd/nfsd.h	2006-08-24 16:26:10.000000000 +1000
+++ ./include/linux/nfsd/nfsd.h	2006-08-24 16:26:10.000000000 +1000
@@ -145,6 +145,7 @@ int nfsd_vers(int vers, enum vers_op cha
 void nfsd_reset_versions(void);
 int nfsd_create_serv(void);
 
+extern int nfsd_max_blksize;
 
 /* 
  * NFSv4 State

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
