From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] Corrects error path in nfs_instantiate()
Date: Fri, 04 Apr 2003 12:11:19 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3E8DBCB7.20305@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050602060607090205060607"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from nat-pool-rdu.redhat.com ([66.187.233.200] helo=lacrosse.corp.redhat.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 191UiT-0001h0-00
	for <nfs@lists.sourceforge.net>; Fri, 04 Apr 2003 09:11:01 -0800
Received: from RedHat.com (dickson.boston.redhat.com [172.16.65.20])
	by lacrosse.corp.redhat.com (8.11.6/8.9.3) with ESMTP id h34HAsu27549
	for <nfs@lists.sourceforge.net>; Fri, 4 Apr 2003 12:10:54 -0500
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

This is a multi-part message in MIME format.
--------------050602060607090205060607
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

In the 2.4.20 kernel, nfs_instantiate() is only calling d_drop() when
the lookup fails. The dentry also need to be removed from the
dirent cache when we can't get an inode.... Also, as Trond
pointed out, ENOMEM should be returned (instead of EACCES)
when we run out of inodes...

SteveD.


--------------050602060607090205060607
Content-Type: text/plain;
 name="linux-2.4.20-nfs-d_drop.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.4.20-nfs-d_drop.patch"

--- linux-2.4.20/fs/nfs/dir.c.orig	2003-04-04 06:55:20.000000000 -0500
+++ linux-2.4.20/fs/nfs/dir.c	2003-04-04 08:40:53.000000000 -0500
@@ -756,7 +756,7 @@ static int nfs_instantiate(struct dentry
 				struct nfs_fattr *fattr)
 {
 	struct inode *inode;
-	int error = -EACCES;
+	int error = 0;
 
 	if (fhandle->size == 0 || !(fattr->valid & NFS_ATTR_FATTR)) {
 		struct inode *dir = dentry->d_parent->d_inode;
@@ -768,9 +768,12 @@ static int nfs_instantiate(struct dentry
 	if (inode) {
 		d_instantiate(dentry, inode);
 		nfs_renew_times(dentry);
-		error = 0;
+	} else {
+		error = -ENOMEM;
+		goto out_err;
 	}
 	return error;
+
 out_err:
 	d_drop(dentry);
 	return error;


--------------050602060607090205060607--



-------------------------------------------------------
This SF.net email is sponsored by: ValueWeb: 
Dedicated Hosting for just $79/mo with 500 GB of bandwidth! 
No other company gives more support or power for your dedicated server
http://click.atdmt.com/AFF/go/sdnxxaff00300020aff/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
