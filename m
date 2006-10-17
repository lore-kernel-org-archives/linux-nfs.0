From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: [patch 3/4] NFS: Remove use of the Big Kernel Lock around
	calls to	rpc_call_sync
Date: Tue, 17 Oct 2006 10:24:38 -0700
Message-ID: <1161105878.3315.23.camel@dyn9047022153>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GZsgH-00019o-7p
	for nfs@lists.sourceforge.net; Tue, 17 Oct 2006 10:24:45 -0700
Received: from e35.co.us.ibm.com ([32.97.110.153])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GZsgE-0007Fh-VE
	for nfs@lists.sourceforge.net; Tue, 17 Oct 2006 10:24:46 -0700
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com
	[9.17.195.11])
	by e35.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k9HHOXFb003047
	for <nfs@lists.sourceforge.net>; Tue, 17 Oct 2006 13:24:33 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id
	k9HHOXZr465442
	for <nfs@lists.sourceforge.net>; Tue, 17 Oct 2006 11:24:33 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	k9HHOX3H021116
	for <nfs@lists.sourceforge.net>; Tue, 17 Oct 2006 11:24:33 -0600
Received: from dyn9047022153 (dyn9047022153.beaverton.ibm.com [9.47.22.153])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id
	k9HHOW2C021070
	for <nfs@lists.sourceforge.net>; Tue, 17 Oct 2006 11:24:32 -0600
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

Remove use of the Big Kernel Lock around calls to rpc_call_sync.

Signed-off-by: Frank Filz <ffilz@us.ibm.com>

### Diffstat output
 nfs3proc.c |    3 ---
 nfs4proc.c |    2 --
 proc.c     |    3 ---
 3 files changed, 8 deletions(-)

diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 3b234d4..452dd1e 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -690,8 +690,6 @@ nfs3_proc_readdir(struct dentry *dentry,
 	};
 	int			status;
 
-	lock_kernel();
-
 	if (plus)
 		msg.rpc_proc = &nfs3_procedures[NFS3PROC_READDIRPLUS];
 
@@ -702,7 +700,6 @@ nfs3_proc_readdir(struct dentry *dentry,
 	status = rpc_call_sync(NFS_CLIENT(dir), &msg, 0);
 	nfs_refresh_inode(dir, &dir_attr);
 	dprintk("NFS reply readdir: %d\n", status);
-	unlock_kernel();
 	return status;
 }
 
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 47c7e6e..bac30b3 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2225,13 +2225,11 @@ static int _nfs4_proc_readdir(struct den
 			dentry->d_parent->d_name.name,
 			dentry->d_name.name,
 			(unsigned long long)cookie);
-	lock_kernel();
 	nfs4_setup_readdir(cookie, NFS_COOKIEVERF(dir), dentry, &args);
 	res.pgbase = args.pgbase;
 	status = rpc_call_sync(NFS_CLIENT(dir), &msg, 0);
 	if (status == 0)
 		memcpy(NFS_COOKIEVERF(dir), res.verifier.data, NFS4_VERIFIER_SIZE);
-	unlock_kernel();
 	dprintk("%s: returns %d\n", __FUNCTION__, status);
 	return status;
 }
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index 4529cc4..7a9013d 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -545,13 +545,10 @@ nfs_proc_readdir(struct dentry *dentry, 
 	};
 	int			status;
 
-	lock_kernel();
-
 	dprintk("NFS call  readdir %d\n", (unsigned int)cookie);
 	status = rpc_call_sync(NFS_CLIENT(dir), &msg, 0);
 
 	dprintk("NFS reply readdir: %d\n", status);
-	unlock_kernel();
 	return status;
 }
 



-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
