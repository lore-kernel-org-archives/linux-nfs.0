From: "Muntz, Daniel" <Dan.Muntz@netapp.com>
Subject: Re: Question: When NFS client check dir's permission,
	it does not check the cache data
Date: Mon, 25 Jun 2007 11:09:01 -0700
Message-ID: <01AE8AF878612047A442668306EAEB05B5A671@SACEXMV01.hq.netapp.com>
References: <467F8247.9060607@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: "Wei Yongjun" <yjwei@cn.fujitsu.com>, <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I2t02-0002E8-5Z
	for nfs@lists.sourceforge.net; Mon, 25 Jun 2007 11:09:18 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I2t02-0005pL-W7
	for nfs@lists.sourceforge.net; Mon, 25 Jun 2007 11:09:21 -0700
In-Reply-To: <467F8247.9060607@cn.fujitsu.com>
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

Or for that matter, just drop the 'access' and the second 'lookup' and
just try the 'create'. 

-----Original Message-----
From: Wei Yongjun [mailto:yjwei@cn.fujitsu.com] 
Sent: Monday, June 25, 2007 1:52 AM
To: nfs@lists.sourceforge.net
Subject: [NFS] Question: When NFS client check dir's permission, it does
not check the cache data

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
First to check the permissions of that dir ,and will be add to cache
data.
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
-			 * Optimize away all write operations, since the
server
-			 * will check permissions when we perform the
op.
-			 */
-			if ((mask & MAY_WRITE) && !(mask & MAY_READ))
-				goto out;
 	}
 
 force_lookup:






------------------------------------------------------------------------
-
This SF.net email is sponsored by DB2 Express Download DB2 Express C -
the FREE version of DB2 express and take control of your XML. No limits.
Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
