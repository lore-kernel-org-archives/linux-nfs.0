From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH]  Reinstantiating stale inodes
Date: Sat, 01 May 2004 12:13:42 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <4093CCB6.1040500@RedHat.com>
References: <40892507.2030004@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090609080908080604070605"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BJx7e-00022K-5a
	for nfs@lists.sourceforge.net; Sat, 01 May 2004 09:13:50 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BJx7d-0008Ug-Nq
	for nfs@lists.sourceforge.net; Sat, 01 May 2004 09:13:49 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.12.10/8.12.10) with ESMTP id i41GDhKG018299
	for <nfs@lists.sourceforge.net>; Sat, 1 May 2004 12:13:43 -0400
Received: from RedHat.com (vpn50-80.rdu.redhat.com [172.16.50.80])
	by int-mx1.corp.redhat.com (8.11.6/8.11.6) with ESMTP id i41GDgv06063
	for <nfs@lists.sourceforge.net>; Sat, 1 May 2004 12:13:42 -0400
To: nfs@lists.sourceforge.net
In-Reply-To: <40892507.2030004@RedHat.com>
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
--------------090609080908080604070605
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Steve Dickson wrote:

> Here is a 2.4 patch that will reinstantiate an inode
> when a ESTALE error is returned on a getattr. When
> the error occurs, a lookup is immediately issued
> to get a new fh.
>
> The fixes the problem of a server rsync -a directory
> that a client has mounted. The key being the -a flag
> since it causes the server not to update the mtime on
> the directory.

It turns out there is a much easier and simpler (safer)
way to reinstantiate inodes than my original patch.

Realizing only parts of an inode needed to be reinstantiated
not the entire thing, this second patch only reinstantiates
two parts of the inode (i.e. fhandle and fattrs) instead of the
entire inode like my original patch did.

I had to export the new nfs_reinstantiate() function because
the ACL code needs to use it, so things like ls -l will work....

Comments? Is this something Marcelo might be interested in?

SteveD.







--------------090609080908080604070605
Content-Type: text/plain;
 name="linux-2.4.21-nfs-estale2.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.4.21-nfs-estale2.patch"

--- linux-2.4.21/fs/nfs/inode.c.org	2004-04-17 18:26:32.000000000 -0400
+++ linux-2.4.21/fs/nfs/inode.c	2004-05-01 11:11:12.000000000 -0400
@@ -953,13 +953,48 @@ nfs_wait_on_inode(struct inode *inode, i
 }
 
 /*
+ * Reinstantiate an inode that has gone stale
+ */
+int
+nfs_reinstantiate(struct dentry *dentry)
+{
+	int error;
+	struct nfs_fh fhandle;
+	struct inode *dir = dentry->d_parent->d_inode;
+	struct inode *inode = dentry->d_inode;
+	struct nfs_fattr fattr;
+
+	nfs_zap_caches(dir);
+	nfs_zap_caches(inode);
+
+	error = NFS_PROTO(dir)->lookup(dir, &dentry->d_name, &fhandle, &fattr);
+	if (!error) {
+		memcpy(&inode->u.nfs_i.fh, &fhandle, sizeof(struct nfs_fh));
+		nfs_refresh_inode(inode, &fattr);
+	}
+
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
+	int error;
+
+	error = nfs_revalidate_inode(NFS_SERVER(inode), inode);
+	if (!error || error != -ESTALE)
+		return error;
+	/*
+	 * We have a stale fh so ask the server for another one
+	 */
+	if (nfs_reinstantiate(dentry) == 0)
+		error = 0;
+
+	return error;
 }
 
 /*
--- linux-2.4.21/include/linux/nfs_fs.h.org	2004-04-17 18:40:02.000000000 -0400
+++ linux-2.4.21/include/linux/nfs_fs.h	2004-05-01 10:55:59.000000000 -0400
@@ -159,6 +159,7 @@ extern struct inode *nfs_fhget(struct de
 				struct nfs_fattr *);
 extern int __nfs_refresh_inode(struct inode *, struct nfs_fattr *);
 extern int nfs_revalidate(struct dentry *);
+extern int nfs_reinstantiate(struct dentry *);
 extern int nfs_permission(struct inode *, int);
 extern int nfs_open(struct inode *, struct file *);
 extern int nfs_release(struct inode *, struct file *);

--------------090609080908080604070605--


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
