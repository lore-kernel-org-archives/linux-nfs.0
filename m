From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH]  Reinstantiating stale inodes
Date: Fri, 23 Apr 2004 10:15:35 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40892507.2030004@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020903080004070509060404"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BH1Sg-0005T0-QD
	for nfs@lists.sourceforge.net; Fri, 23 Apr 2004 07:15:26 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BH1Sg-0003OB-CV
	for nfs@lists.sourceforge.net; Fri, 23 Apr 2004 07:15:26 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.12.10/8.12.10) with ESMTP id i3NEFJKG019288
	for <nfs@lists.sourceforge.net>; Fri, 23 Apr 2004 10:15:19 -0400
To: nfs@lists.sourceforge.net
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
--------------020903080004070509060404
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Here is a 2.4 patch that will reinstantiate an inode
when a ESTALE error is returned on a getattr. When
the error occurs, a lookup is immediately issued
to get a new fh.

The fixes the problem of a server rsync -a directory
that a client has mounted. The key being the -a flag
since it causes the server not to update the mtime on
the directory.

My initial efforts was to make nfs_lookup_revalidate()
a bit smarter with the use of ctimes but turns out
that when nfs_lookup_revalidate() does no caching
(i.e. an otw lookup is issued on every call) the
ESTALEs still occurred.

Then I turned my attention to __nfs_refresh_inode() and
had it used ctime in its calculations of what is
and is not valid... This did work, but it cause a significant
amount of extra otw traffic (using the cthon test suite) for
the non error cases. The one thing good about this patch (imho)
is the extra lookups only occur after an error that generally
does not happen...

Comments would be appreciated, especially about how
I'm reinstantiating the dentry....

SteveD.



--------------020903080004070509060404
Content-Type: text/plain;
 name="linux-2.4.21-nfs-estale.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.4.21-nfs-estale.patch"

--- linux-2.4.21/fs/nfs/inode.c.org	2004-04-17 18:26:32.000000000 -0400
+++ linux-2.4.21/fs/nfs/inode.c	2004-04-23 03:19:51.000000000 -0400
@@ -953,13 +953,57 @@ nfs_wait_on_inode(struct inode *inode, i
 }
 
 /*
+ * Reinstantiate an inode that has gone stale
+ */
+static int
+nfs_reinstantiate(
+	struct inode *dir, 
+	struct dentry *dentry, 
+	struct nfs_fattr *fattr)
+{
+	int error;
+	struct nfs_fh fhandle;
+	struct inode *inode;
+
+	error = NFS_PROTO(dir)->lookup(dir, &dentry->d_name, &fhandle, &fattr);
+	if (!error) {
+		error = -ENOMEM;
+		inode = nfs_fhget(dentry, &fhandle, &fattr);
+		if (inode) {
+			d_drop(dentry);
+			dput(dentry);
+			d_instantiate(dentry, inode);
+			dentry->d_time = jiffies;
+			error = 0;
+		}
+	}
+	return error;
+}
+
+/*
  * Externally visible revalidation function
  */
 int
 nfs_revalidate(struct dentry *dentry)
 {
 	struct inode *inode = dentry->d_inode;
-	return nfs_revalidate_inode(NFS_SERVER(inode), inode);
+	struct inode *pinode;
+	struct nfs_fattr fattr;
+	int error;
+
+	error = nfs_revalidate_inode(NFS_SERVER(inode), inode);
+	if (!error || error != -ESTALE)
+		return error;
+	/*
+	 * We have a stale fh so ask the server for another one
+	 */
+	pinode = dentry->d_parent->d_inode;	
+	if (nfs_reinstantiate(pinode, dentry, &fattr) == 0) {
+		inode = dentry->d_inode;
+		if (nfs_refresh_inode(inode, &fattr) == 0)
+			error = 0;
+	}
+	return error;
 }
 
 /*

--------------020903080004070509060404--


-------------------------------------------------------
This SF.net email is sponsored by: The Robotic Monkeys at ThinkGeek
For a limited time only, get FREE Ground shipping on all orders of $35
or more. Hurry up and shop folks, this offer expires April 30th!
http://www.thinkgeek.com/freeshipping/?cpg=12297
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
