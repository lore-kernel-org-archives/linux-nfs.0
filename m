From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH]  Reinstantiating stale inodes
Date: Fri, 23 Apr 2004 15:14:03 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40896AFB.8040407@RedHat.com>
References: <40892507.2030004@RedHat.com>	 <1082730973.2617.23.camel@lade.trondhjem.org> <40893DEF.3010506@RedHat.com>	 <1082737270.2617.80.camel@lade.trondhjem.org> <40895096.9020507@RedHat.com> <1082742547.2617.86.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040300000100050009030005"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BH67q-0000aE-CU
	for nfs@lists.sourceforge.net; Fri, 23 Apr 2004 12:14:14 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BH67p-0001Dy-Vs
	for nfs@lists.sourceforge.net; Fri, 23 Apr 2004 12:14:14 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1082742547.2617.86.camel@lade.trondhjem.org>
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
--------------040300000100050009030005
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Trond Myklebust wrote:

>You can if and only if
>
>  - The dentry is unhashed, and you are holding the semaphore dir->i_sem
>on the parent directory.
>OR
>  - You are holding the spin lock dcache_lock.
>  
>
I decide to hold the dir->i_sem semaphore since d_drop() needs the
dcache_lock to do the unhashing...

>Note: on 2.6.x, the second condition needs to be modified a bit: you
>probably need to hold dentry->d_lock too since the 2.6.x version of
>d_lookup() is by and large lockless...
>  
>
I'll take a look asaic...

SteveD.

--------------040300000100050009030005
Content-Type: text/plain;
 name="linux-2.4.21-nfs-estale.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.4.21-nfs-estale.patch"

--- linux-2.4.21/fs/nfs/inode.c.org	2004-04-17 18:26:32.000000000 -0400
+++ linux-2.4.21/fs/nfs/inode.c	2004-04-23 14:44:59.000000000 -0400
@@ -953,13 +953,74 @@ nfs_wait_on_inode(struct inode *inode, i
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
+	/*
+	 * We can only reinstantiate the inode if we are the
+	 * only ones accessing it.
+	 */
+	if (atomic_read(&dentry->d_count) > 1)
+		return EACCES;
+
+	error = NFS_PROTO(dir)->lookup(dir, &dentry->d_name, &fhandle, &fattr);
+	if (!error) {
+		error = -ENOMEM;
+		inode = nfs_fhget(dentry, &fhandle, &fattr);
+		if (inode) {
+			/*
+			 * Check again this time holding the i_sem semaphore
+			 * to make sure we are the only ones accessing this
+			 * dentry
+			 */
+			down(&dir->i_sem);
+			if (atomic_read(&dentry->d_count) < 2) {
+				d_drop(dentry);
+				dput(dentry);
+				d_instantiate(dentry, inode);
+				dentry->d_time = jiffies;
+				error = 0;
+			} else
+				iput(inode);
+			up(&dir->i_sem);
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

--------------040300000100050009030005--


-------------------------------------------------------
This SF.net email is sponsored by: The Robotic Monkeys at ThinkGeek
For a limited time only, get FREE Ground shipping on all orders of $35
or more. Hurry up and shop folks, this offer expires April 30th!
http://www.thinkgeek.com/freeshipping/?cpg=12297
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
