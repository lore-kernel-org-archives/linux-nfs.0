From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH]  Reinstantiating stale inodes
Date: Tue, 04 May 2004 15:05:27 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <4097E977.5020706@RedHat.com>
References: <40892507.2030004@RedHat.com>  <4093CCB6.1040500@RedHat.com>	 <1083439518.3687.19.camel@lade.trondhjem.org> <4094397C.3030303@RedHat.com>	 <1083457337.3687.60.camel@lade.trondhjem.org> <409468B2.40200@RedHat.com>	 <1083468517.3687.70.camel@lade.trondhjem.org> <4096A292.8050109@RedHat.com>	 <1083615338.3896.92.camel@lade.trondhjem.org> <4096ACA0.9050507@RedHat.com> <1083619647.3896.126.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070004010902090408010008"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BL5EV-0001Qk-Gn
	for nfs@lists.sourceforge.net; Tue, 04 May 2004 12:05:35 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BL5E0-0008Md-GD
	for nfs@lists.sourceforge.net; Tue, 04 May 2004 12:05:04 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1083619647.3896.126.camel@lade.trondhjem.org>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

This is a multi-part message in MIME format.
--------------070004010902090408010008
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


Trond Myklebust wrote:

>So the big question is: *why do you get all those extra writes*?
>  
>
This appears to be a red herring... After a complete build in a
new tree that only had the ctime and zapping cache patches I started
to get more reasonable results... But it does appear that the ctime
patch does (consistently) cause more getattrs and lookups...

W/OUT any patches
Client rpc stats:
calls      retrans    authrefrsh
30052      16         0
Client nfs v3:
null       getattr    setattr    lookup     access     readlink
0       0% 2288    7% 1199    3% 2561    8% 1171    3% 250     0%
read       write      create     mkdir      symlink    mknod
3955   13% 11897  39% 893     2% 175     0% 250     0% 0       0%
remove     rmdir      rename     link       readdir    readdirplus
1391    4% 175     0% 376     1% 250     0% 0       0% 1119    3%
fsstat     fsinfo     pathconf   commit
1500    4% 1       0% 0       0% 601     1%

With CTIME patch
Client rpc stats:
calls      retrans    authrefrsh
30288      7          0      
Client nfs v3:
null       getattr    setattr    lookup     access     readlink  
0       0% 2308    7% 1199    3% 2773    9% 1171    3% 250     0%
read       write      create     mkdir      symlink    mknod     
3954   13% 11899  39% 893     2% 175     0% 250     0% 0       0%
remove     rmdir      rename     link       readdir    readdirplus
1391    4% 175     0% 380     1% 250     0% 0       0% 1119    3%
fsstat     fsinfo     pathconf   commit    
1500    4% 1       0% 0       0% 600     1%

>There weren't any extra changes to nfs_refresh_inode() that might cause
>the actual page cache invalidation to depend on the inode ctime (as
>opposed to just the lookup cache)?
>  
>
No... there are some slight differences in __nfs_refresh_inode()... but
no smoking gun....

At this point I feel the numbers are close enough to declare victory.
The attached 2.4 patch *does* avoid ESTALEs when the server rsync -a the
mounted directory for a (very) small price... 1 to 2 percent increase in
traffic (in a particular kernel, running a particular test suite)
is not a bad price to pay to avoid ESTALEs.... imho...

What are the chances of this patch (or something similar) making
it into 2.4. tree?

SteveD.


--------------070004010902090408010008
Content-Type: text/plain;
 name="linux-2.4-nfs-estale.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.4-nfs-estale.patch"

--- linux-2.4/fs/nfs/dir.c.orig	2003-11-11 16:55:40.000000000 -0500
+++ linux-2.4/fs/nfs/dir.c	2004-05-04 13:26:20.000000000 -0400
@@ -421,7 +421,7 @@ int nfs_check_verifier(struct inode *dir
 		return 1;
 	if (nfs_revalidate_inode(NFS_SERVER(dir), dir))
 		return 0;
-	return time_after(dentry->d_time, NFS_MTIME_UPDATE(dir));
+	return time_after(dentry->d_time, NFS_CTIME_UPDATE(dir));
 }
 
 /*
--- linux-2.4/fs/nfs/inode.c.orig	2004-05-04 13:26:21.000000000 -0400
+++ linux-2.4/fs/nfs/inode.c	2004-05-04 13:28:20.000000000 -0400
@@ -821,8 +821,16 @@ nfs_wait_on_inode(struct inode *inode, i
 int
 nfs_revalidate(struct dentry *dentry)
 {
+	int error;
 	struct inode *inode = dentry->d_inode;
-	return nfs_revalidate_inode(NFS_SERVER(inode), inode);
+
+	error = nfs_revalidate_inode(NFS_SERVER(inode), inode);
+	if (error == -ESTALE) {
+		struct inode *dir = dentry->d_parent->d_inode;
+		nfs_zap_caches(dir);
+	}
+
+	return error;
 }
 
 /*
@@ -1054,16 +1062,16 @@ __nfs_refresh_inode(struct inode *inode,
 	if (nfs_have_writebacks(inode) && new_isize < inode->i_size)
 		new_isize = inode->i_size;
 
-	NFS_CACHE_CTIME(inode) = fattr->ctime;
-	inode->i_ctime = nfs_time_to_secs(fattr->ctime);
+	if (NFS_CACHE_CTIME(inode) != fattr->ctime) {
+		NFS_CACHE_CTIME(inode) = fattr->ctime;
+		inode->i_ctime = nfs_time_to_secs(fattr->ctime);
+		NFS_CTIME_UPDATE(inode) = jiffies;
+	}
 
 	inode->i_atime = new_atime;
 
-	if (NFS_CACHE_MTIME(inode) != new_mtime) {
-		NFS_MTIME_UPDATE(inode) = jiffies;
-		NFS_CACHE_MTIME(inode) = new_mtime;
-		inode->i_mtime = nfs_time_to_secs(new_mtime);
-	}
+	NFS_CACHE_MTIME(inode) = new_mtime;
+	inode->i_mtime = nfs_time_to_secs(new_mtime);
 
 	NFS_CACHE_ISIZE(inode) = new_size;
 	inode->i_size = new_isize;
--- linux-2.4/include/linux/nfs_fs.h.orig	2004-05-04 13:26:23.000000000 -0400
+++ linux-2.4/include/linux/nfs_fs.h	2004-05-04 13:26:24.000000000 -0400
@@ -78,7 +78,7 @@ static inline struct nfs_inode_info *NFS
 #define NFS_CONGESTED(inode)		(RPC_CONGESTED(NFS_CLIENT(inode)))
 #define NFS_COOKIEVERF(inode)		((inode)->u.nfs_i.cookieverf)
 #define NFS_READTIME(inode)		((inode)->u.nfs_i.read_cache_jiffies)
-#define NFS_MTIME_UPDATE(inode)		((inode)->u.nfs_i.cache_mtime_jiffies)
+#define NFS_CTIME_UPDATE(inode)		((inode)->u.nfs_i.cache_ctime_jiffies)
 #define NFS_CACHE_CTIME(inode)		((inode)->u.nfs_i.read_cache_ctime)
 #define NFS_CACHE_MTIME(inode)		((inode)->u.nfs_i.read_cache_mtime)
 #define NFS_CACHE_ISIZE(inode)		((inode)->u.nfs_i.read_cache_isize)
--- linux-2.4/include/linux/nfs_fs_i.h.orig	2004-05-04 13:26:24.000000000 -0400
+++ linux-2.4/include/linux/nfs_fs_i.h	2004-05-04 13:26:24.000000000 -0400
@@ -49,10 +49,10 @@ struct nfs_inode_info {
 	unsigned long		attrtimeo_timestamp;
 
 	/*
-	 * Timestamp that dates the change made to read_cache_mtime.
+	 * Timestamp that dates the change made to read_cache_ctime.
 	 * This is of use for dentry revalidation
 	 */
-	unsigned long		cache_mtime_jiffies;
+	unsigned long		cache_ctime_jiffies;
 
 	/*
 	 * This is the cookie verifier used for NFSv3 readdir

--------------070004010902090408010008--


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
