From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Question: When NFS client check dir's permission,
 it does not check the cache data
Date: Mon, 25 Jun 2007 16:52:23 +0800
Message-ID: <467F8247.9060607@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I2kJe-00008w-QZ
	for nfs@lists.sourceforge.net; Mon, 25 Jun 2007 01:52:58 -0700
Received: from [222.73.24.84] (helo=song.cn.fujitsu.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I2kJh-0000hb-Ny
	for nfs@lists.sourceforge.net; Mon, 25 Jun 2007 01:53:02 -0700
Received: from tang.cn.fujitsu.com (tang.cn.fujitsu.com [10.167.250.3])
	by song.cn.fujitsu.com (Postfix) with ESMTP id C188D1700EB
	for <nfs@lists.sourceforge.net>; Mon, 25 Jun 2007 16:52:40 +0800 (CST)
Received: from fnst.cn.fujitsu.com (localhost.localdomain [127.0.0.1])
	by tang.cn.fujitsu.com (8.13.1/8.13.1) with ESMTP id l5P8qdUT027655
	for <nfs@lists.sourceforge.net>; Mon, 25 Jun 2007 16:52:40 +0800
Received: from [10.167.141.203] (unknown [10.167.141.203])
	by fnst.cn.fujitsu.com (Postfix) with ESMTP id 9C956D4002
	for <nfs@lists.sourceforge.net>; Mon, 25 Jun 2007 17:05:41 +0800 (CST)
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hello, everyone
 When I test NFS client, I found a poblem that, if a dir we do not have 
permission to write, it will let the server to check permissions when we 
perform the write op.
This is comment by source code:
  * Optimize away all write operations, since the server
  * will check permissions when we perform the op.
In my test, the process is like following:
#touch dir/file
NFS Server                         NFS Client
                       <----------      lookup (dir)
lookup ok      ------------->
                       <----------      access (dir)   (*1)
access(read only)   -----------> 
                       <----------      lookup (file)
lookup(NOENT)     ------------->
                       <----------      create (file)  (*2)
create(NOPERM)     ------------->

(*1)
First to check the permissions of that dir ,and will be add to cache data.
(*2)
Since the Client had known the permission of the dir, why no used it? 
Does this effect to NFS client's performance?
Maybe we can check the cache first, if it not exists, then let the 
server to check permissions when we perform the write op.
Is this better? Maybe code looks like following(not an useable patch):

--- fs/nfs/dir.c.orig	2007-06-12 02:37:06.000000000 +0800
+++ fs/nfs/dir.c	2007-06-25 16:26:03.000000000 +0800
@@ -1936,6 +1936,14 @@ static int nfs_do_access(struct inode *i
        ...
	status = nfs_access_get_cached(inode, cred, &cache);
 	if (status == 0)
 		goto out;
 
+	/*
+	 * Optimize away all write operations, since the server
+	 * will check permissions when we perform the op.
+	 */
+	if(((inode->i_mode & S_IFMT) == S_IFDIR) 
+		&& (mask & MAY_WRITE) && !(mask & MAY_READ))
+		return 0;
+
 	/* Be clever: ask server to check for all possible rights */
 	cache.mask = MAY_EXEC | MAY_WRITE | MAY_READ;
 	cache.cred = cred;
@@ -1973,13 +1981,6 @@ int nfs_permission(struct inode *inode, 
 					&& (nd->flags & LOOKUP_OPEN))
 				goto out;
 			break;
-		case S_IFDIR:
-			/*
-			 * Optimize away all write operations, since the server
-			 * will check permissions when we perform the op.
-			 */
-			if ((mask & MAY_WRITE) && !(mask & MAY_READ))
-				goto out;
 	}
 
 force_lookup:






-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
