From: NeilBrown <neilb@suse.de>
Subject: [PATCH 004 of 4] Allow max size of NFSd payload to be
	configured.
Date: Mon, 7 Aug 2006 10:35:21 +1000
Message-ID: <1060807003521.12403@suse.de>
References: <20060807103020.12286.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G9t5a-0007UP-Qq
	for nfs@lists.sourceforge.net; Sun, 06 Aug 2006 17:35:26 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G9t5a-0004d3-Jj
	for nfs@lists.sourceforge.net; Sun, 06 Aug 2006 17:35:27 -0700
To: Greg Banks <gnb@melbourne.sgi.com>
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
 This formula really needs to be justified.
The value can be set within reason as long as 
 no nfsd threads are currently running.

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfsctl.c           |   25 +++++++++++++++++++++++++
 ./fs/nfsd/nfssvc.c           |   14 +++++++++++++-
 ./include/linux/nfsd/const.h |    4 ++--
 ./include/linux/nfsd/nfsd.h  |    1 +
 4 files changed, 41 insertions(+), 3 deletions(-)

diff .prev/fs/nfsd/nfsctl.c ./fs/nfsd/nfsctl.c
--- .prev/fs/nfsd/nfsctl.c	2006-08-07 09:32:12.000000000 +1000
+++ ./fs/nfsd/nfsctl.c	2006-08-07 10:23:44.000000000 +1000
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
@@ -553,6 +556,27 @@ static ssize_t write_ports(struct file *
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
+		if (bsize < 1024)
+			bsize = 1024;
+		if (bsize > NFSSVC_MAXBLKSIZE)
+			bsize = NFSSVC_MAXBLKSIZE;
+		if (nfsd_serv && nfsd_serv->sv_nrthreads)
+			return -EBUSY;
+		nfsd_max_blksize = bsize;
+	}
+	return sprintf(buf, "%d\n", nfsd_max_blksize);
+}
+
 #ifdef CONFIG_NFSD_V4
 extern time_t nfs4_leasetime(void);
 
@@ -618,6 +642,7 @@ static int nfsd_fill_super(struct super_
 		[NFSD_Pool_Threads] = {"pool_threads", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Versions] = {"versions", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Ports] = {"portlist", &transaction_ops, S_IWUSR|S_IRUGO},
+		[NFSD_MaxBlkSize] = {"max_block_size", &transaction_ops, S_IWUSR|S_IRUGO},
 #ifdef CONFIG_NFSD_V4
 		[NFSD_Leasetime] = {"nfsv4leasetime", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_RecoveryDir] = {"nfsv4recoverydir", &transaction_ops, S_IWUSR|S_IRUSR},

diff .prev/fs/nfsd/nfssvc.c ./fs/nfsd/nfssvc.c
--- .prev/fs/nfsd/nfssvc.c	2006-08-07 09:32:12.000000000 +1000
+++ ./fs/nfsd/nfssvc.c	2006-08-07 10:24:56.000000000 +1000
@@ -198,9 +198,21 @@ int nfsd_create_serv(void)
 		unlock_kernel();
 		return 0;
 	}
+	if (nfsd_max_blksize == 0) {
+		/* choose a suitable default */
+		struct sysinfo i;
+		si_meminfo(&i);
+		if (i.totalram > (1<<(30-PAGE_SHIFT)))
+			nfsd_max_blksize = NFSSVC_MAXBLKSIZE;
+		else if (i.totalram > (1<<(24-PAGE_SHIFT)))
+			nfsd_max_blksize = 128*1024;
+		else
+			nfsd_max_blksize = 32*1024;
+	}
 
 	atomic_set(&nfsd_busy, 0);
-	nfsd_serv = svc_create_pooled(&nfsd_program, NFSD_BUFSIZE,
+	nfsd_serv = svc_create_pooled(&nfsd_program,
+				      NFSD_BUFSIZE - NFSSVC_MAXBLKSIZE + nfsd_max_blksize,
 				      nfsd_last_thread,
 				      nfsd, SIG_NOCLEAN, THIS_MODULE);
 	if (nfsd_serv == NULL)

diff .prev/include/linux/nfsd/const.h ./include/linux/nfsd/const.h
--- .prev/include/linux/nfsd/const.h	2006-08-07 10:17:53.000000000 +1000
+++ ./include/linux/nfsd/const.h	2006-08-07 10:22:41.000000000 +1000
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
--- .prev/include/linux/nfsd/nfsd.h	2006-07-28 11:34:33.000000000 +1000
+++ ./include/linux/nfsd/nfsd.h	2006-08-07 10:24:59.000000000 +1000
@@ -145,6 +145,7 @@ int nfsd_vers(int vers, enum vers_op cha
 void nfsd_reset_versions(void);
 int nfsd_create_serv(void);
 
+extern int nfsd_max_blksize;
 
 /* 
  * NFSv4 State

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
