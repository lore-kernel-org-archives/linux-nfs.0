From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: [patch 2/4] NFS: Remove use of the Big Kernel Lock around
	calls to	rpc_execute.
Date: Tue, 17 Oct 2006 10:24:36 -0700
Message-ID: <1161105876.3315.22.camel@dyn9047022153>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GZsgF-00019e-0p
	for nfs@lists.sourceforge.net; Tue, 17 Oct 2006 10:24:44 -0700
Received: from e34.co.us.ibm.com ([32.97.110.152])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GZsgD-0007EU-P9
	for nfs@lists.sourceforge.net; Tue, 17 Oct 2006 10:24:44 -0700
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com
	[9.17.195.11])
	by e34.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k9HHOVL7031024
	for <nfs@lists.sourceforge.net>; Tue, 17 Oct 2006 13:24:31 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id
	k9HHOVYB482220
	for <nfs@lists.sourceforge.net>; Tue, 17 Oct 2006 11:24:31 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	k9HHOU35020994
	for <nfs@lists.sourceforge.net>; Tue, 17 Oct 2006 11:24:30 -0600
Received: from dyn9047022153 (dyn9047022153.beaverton.ibm.com [9.47.22.153])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id
	k9HHOUNf020945
	for <nfs@lists.sourceforge.net>; Tue, 17 Oct 2006 11:24:30 -0600
To: NFS List <nfs@lists.sourceforge.net>
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

Remove use of the Big Kernel Lock around calls to rpc_execute.

Signed-off-by: Frank Filz <ffilz@us.ibm.com>

### Diffstat output
 direct.c |    6 ------
 read.c   |    2 --
 write.c  |    2 --
 3 files changed, 10 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 9f7f8b9..ff943ab 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -307,9 +307,7 @@ static ssize_t nfs_direct_read_schedule(
 
 		data->task.tk_cookie = (unsigned long) inode;
 
-		lock_kernel();
 		rpc_execute(&data->task);
-		unlock_kernel();
 
 		dfprintk(VFS, "NFS: %5u initiated direct read call (req %s/%Ld, %zu
bytes @ offset %Lu)\n",
 				data->task.tk_pid,
@@ -475,9 +473,7 @@ static void nfs_direct_commit_schedule(s
 
 	dprintk("NFS: %5u initiated commit call\n", data->task.tk_pid);
 
-	lock_kernel();
 	rpc_execute(&data->task);
-	unlock_kernel();
 }
 
 static void nfs_direct_write_complete(struct nfs_direct_req *dreq,
struct inode *inode)
@@ -637,9 +633,7 @@ static ssize_t nfs_direct_write_schedule
 		data->task.tk_priority = RPC_PRIORITY_NORMAL;
 		data->task.tk_cookie = (unsigned long) inode;
 
-		lock_kernel();
 		rpc_execute(&data->task);
-		unlock_kernel();
 
 		dfprintk(VFS, "NFS: %5u initiated direct write call (req %s/%Ld, %zu
bytes @ offset %Lu)\n",
 				data->task.tk_pid,
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index c2e49c3..9ca6910 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -316,9 +316,7 @@ static void nfs_execute_read(struct nfs_
 	sigset_t oldset;
 
 	rpc_clnt_sigmask(clnt, &oldset);
-	lock_kernel();
 	rpc_execute(&data->task);
-	unlock_kernel();
 	rpc_clnt_sigunmask(clnt, &oldset);
 }
 
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index f6675d2..3d0470b 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -977,9 +977,7 @@ static void nfs_execute_write(struct nfs
 	sigset_t oldset;
 
 	rpc_clnt_sigmask(clnt, &oldset);
-	lock_kernel();
 	rpc_execute(&data->task);
-	unlock_kernel();
 	rpc_clnt_sigunmask(clnt, &oldset);
 }
 



-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
