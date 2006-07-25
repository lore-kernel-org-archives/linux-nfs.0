From: Greg Banks <gnb@melbourne.sgi.com>
Subject: [PATCH 011 of 11] knfsd: allow admin to set nthreads per node
Date: Tue, 25 Jul 2006 15:17:56 +1000
Message-ID: <1153804676.21040.27.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G5FIw-000482-8p
	for nfs@lists.sourceforge.net; Mon, 24 Jul 2006 22:18:02 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G5FIw-0004n6-5d
	for nfs@lists.sourceforge.net; Mon, 24 Jul 2006 22:18:02 -0700
To: Neil Brown <neilb@suse.de>
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

knfsd: Add /proc/fs/nfsd/pool_threads which allows the sysadmin (or
a userspace daemon) to read and change the number of nfsd threads
in each pool.  The format is a list of space-separated integers,
one per pool.

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
---

 fs/nfsd/nfsctl.c |   70 +++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfssvc.c |   74 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 144 insertions(+)

Index: linus-git/fs/nfsd/nfsctl.c
===================================================================
--- linus-git.orig/fs/nfsd/nfsctl.c	2006-07-05 15:54:31.482266717 +1000
+++ linus-git/fs/nfsd/nfsctl.c	2006-07-24 23:02:40.271026265 +1000
@@ -52,6 +52,7 @@ enum {
 	NFSD_List,
 	NFSD_Fh,
 	NFSD_Threads,
+	NFSD_Pool_Threads,
 	NFSD_Versions,
 	/*
 	 * The below MUST come last.  Otherwise we leave a hole in nfsd_files[]
@@ -75,6 +76,7 @@ static ssize_t write_getfd(struct file *
 static ssize_t write_getfs(struct file *file, char *buf, size_t size);
 static ssize_t write_filehandle(struct file *file, char *buf, size_t size);
 static ssize_t write_threads(struct file *file, char *buf, size_t size);
+static ssize_t write_pool_threads(struct file *file, char *buf, size_t size);
 static ssize_t write_versions(struct file *file, char *buf, size_t size);
 #ifdef CONFIG_NFSD_V4
 static ssize_t write_leasetime(struct file *file, char *buf, size_t size);
@@ -91,6 +93,7 @@ static ssize_t (*write_op[])(struct file
 	[NFSD_Getfs] = write_getfs,
 	[NFSD_Fh] = write_filehandle,
 	[NFSD_Threads] = write_threads,
+	[NFSD_Pool_Threads] = write_pool_threads,
 	[NFSD_Versions] = write_versions,
 #ifdef CONFIG_NFSD_V4
 	[NFSD_Leasetime] = write_leasetime,
@@ -358,6 +361,72 @@ static ssize_t write_threads(struct file
 	return strlen(buf);
 }
 
+extern int nfsd_nrpools(void);
+extern int nfsd_get_nrthreads(int n, int *);
+extern int nfsd_set_nrthreads(int n, int *);
+
+static ssize_t write_pool_threads(struct file *file, char *buf, size_t size)
+{
+	/* if size > 0, look for an array of number of threads per node
+	 * and apply them  then write out number of threads per node as reply
+	 */
+	char *mesg = buf;
+	int i;
+	int rv;
+	int len;
+    	int npools = nfsd_nrpools();
+	int *nthreads;
+
+	if (npools == 0) {
+		/*
+		 * NFS is shut down.  The admin can start it by
+		 * writing to the threads file but NOT the pool_threads
+		 * file, sorry.  Report zero threads.
+		 */
+		strcpy(buf, "0\n");
+		return strlen(buf);
+	}
+
+	nthreads = kcalloc(npools, sizeof(int), GFP_KERNEL);
+	if (nthreads == NULL)
+		return -ENOMEM;
+
+	if (size > 0) {
+		for (i = 0 ; i < npools ; i++) {
+			rv = get_int(&mesg, &nthreads[i]);
+			if (rv == -ENOENT)
+				break;		/* fewer numbers than pools */
+			if (rv)
+				goto out_free;	/* syntax error */
+			rv = -EINVAL;
+			if (nthreads[i] < 0)
+				goto out_free;
+		}
+		rv = nfsd_set_nrthreads(i, nthreads);
+		if (rv)
+			goto out_free;
+	}
+
+	rv = nfsd_get_nrthreads(npools, nthreads);
+	if (rv)
+		goto out_free;
+
+	mesg = buf;
+	size = SIMPLE_TRANSACTION_LIMIT;
+	for (i = 0 ; i < npools && size > 0 ; i++) {
+		snprintf(mesg, size, "%d%c", nthreads[i], (i == npools-1 ? '\n' : ' '));
+		len = strlen(mesg);
+		size -= len;
+		mesg += len;
+	}
+
+	return (mesg-buf);
+
+out_free:
+	kfree(nthreads);
+	return rv;
+}
+
 static ssize_t write_versions(struct file *file, char *buf, size_t size)
 {
 	/*
@@ -483,6 +552,7 @@ static int nfsd_fill_super(struct super_
 		[NFSD_List] = {"exports", &exports_operations, S_IRUGO},
 		[NFSD_Fh] = {"filehandle", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Threads] = {"threads", &transaction_ops, S_IWUSR|S_IRUSR},
+		[NFSD_Pool_Threads] = {"pool_threads", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Versions] = {"versions", &transaction_ops, S_IWUSR|S_IRUSR},
 #ifdef CONFIG_NFSD_V4
 		[NFSD_Leasetime] = {"nfsv4leasetime", &transaction_ops, S_IWUSR|S_IRUSR},
Index: linus-git/fs/nfsd/nfssvc.c
===================================================================
--- linus-git.orig/fs/nfsd/nfssvc.c	2006-07-24 22:36:40.864677820 +1000
+++ linus-git/fs/nfsd/nfssvc.c	2006-07-24 22:57:16.693656028 +1000
@@ -124,6 +124,80 @@ int nfsd_nrthreads(void)
 		return nfsd_serv->sv_nrthreads;
 }
 
+int nfsd_nrpools(void)
+{
+	if (nfsd_serv == NULL)
+		return 0;
+	else
+		return nfsd_serv->sv_nrpools;
+}
+
+int nfsd_get_nrthreads(int n, int *nthreads)
+{
+	int i = 0;
+
+	if (nfsd_serv != NULL) {
+		for (i = 0 ; i < nfsd_serv->sv_nrpools && i < n ; i++)
+			nthreads[i] = nfsd_serv->sv_pools[i].sp_nrthreads;
+	}
+
+	return 0;
+}
+
+int nfsd_set_nrthreads(int n, int *nthreads)
+{
+	int i = 0;
+	int tot = 0;
+	int err = 0;
+
+	if (nfsd_serv == NULL || n <= 0)
+		return 0;
+
+	if (n > nfsd_serv->sv_nrpools)
+		n = nfsd_serv->sv_nrpools;
+
+	/* enforce a global maximum number of threads */
+	tot = 0;
+	for (i = 0 ; i < n ; i++) {
+		if (nthreads[i] > NFSD_MAXSERVS)
+			nthreads[i] = NFSD_MAXSERVS;
+		tot += nthreads[i];
+	}
+	if (tot > NFSD_MAXSERVS) {
+		/* total too large: scale down requested numbers */
+		for (i = 0 ; i < n && tot > 0 ; i++) {
+		    	int new = nthreads[i] * NFSD_MAXSERVS / tot;
+			tot -= (nthreads[i] - new);
+			nthreads[i] = new;
+		}
+		for (i = 0 ; i < n && tot > 0 ; i++) {
+			nthreads[i]--;
+			tot--;
+		}
+	}
+
+	/*
+	 * There must always be a thread in pool 0; the admin
+	 * can't shut down NFS completely using pool_threads.
+	 */
+	if (nthreads[0] == 0)
+		nthreads[0] = 1;
+
+	/* apply the new numbers */
+	lock_kernel();
+	svc_get(nfsd_serv);
+	for (i = 0 ; i < n ; i++) {
+		err = svc_set_num_threads(nfsd_serv, &nfsd_serv->sv_pools[i],
+				    	  nthreads[i]);
+		if (err)
+			break;
+	}
+	svc_destroy(nfsd_serv);
+	unlock_kernel();
+
+	return err;
+}
+
 int
 nfsd_svc(unsigned short port, int nrservs)
 {

-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
