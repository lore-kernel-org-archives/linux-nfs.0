From: Kasparek Tomas <kasparek@fit.vutbr.cz>
Subject: Re: NFS corruption in 2.6.18.2?
Date: Fri, 24 Nov 2006 07:47:52 +0100
Message-ID: <20061124064752.GI40079@fit.vutbr.cz>
References: <50e235a50d0f2b4fb34eed1c840565e3@swip.net>
	<20061123161738.GF40079@fit.vutbr.cz>
	<20061123172456.GG40079@fit.vutbr.cz>
	<20061123213311.GH40079@fit.vutbr.cz>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="envbJBWh7q8WU6mo"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GnUqu-0001is-0d
	for nfs@lists.sourceforge.net; Thu, 23 Nov 2006 22:48:00 -0800
Received: from kazi.fit.vutbr.cz ([147.229.8.12])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GnUqt-0002f5-DX
	for nfs@lists.sourceforge.net; Thu, 23 Nov 2006 22:48:01 -0800
Received: from kazi.fit.vutbr.cz (localhost [127.0.0.1])
	by kazi.fit.vutbr.cz (envelope-from kasparek@fit.vutbr.cz)
	(8.13.8/8.13.7) with ESMTP id kAO6lqUW073007
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <nfs@lists.sourceforge.net>; Fri, 24 Nov 2006 07:47:52 +0100 (CET)
Received: (from kasparek@localhost)
	by kazi.fit.vutbr.cz (8.13.8/8.13.1/Submit) id kAO6lqwY073006
	for nfs@lists.sourceforge.net; Fri, 24 Nov 2006 07:47:52 +0100 (CET)
	(envelope-from kasparek@fit.vutbr.cz)
To: "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
In-Reply-To: <20061123213311.GH40079@fit.vutbr.cz>
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


--envbJBWh7q8WU6mo
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Nov 23, 2006 at 10:33:11PM +0100, Kasparek Tomas wrote:
> On Thu, Nov 23, 2006 at 06:24:56PM +0100, Kasparek Tomas wrote:
> > On Thu, Nov 23, 2006 at 05:17:38PM +0100, Kasparek Tomas wrote:
> > > 
> > > > >have seen this behaviour with kernel 2.6.18 and above up to 19-rc4.
> > > > > Reported this, but no response.
> > > > > 
> > > > > http://lkml.org/lkml/2006/9/28/89
> > > >
> > > > Your test script doesn't use any form of locking. How are you ensuring
> > > > that only one client has the file open at a time?
> > > 
> > > I use no locking at all, it's just synthetic test, I don't expect data to
> > > be ordered or whatever, but the problem is blocks of zeros inserted.
> > > It behaves right with the last 2.6.16.32, zeros are contained if clients
> > > are 2.6.18.3 and 2.6.19-rc4. 
> > > 
> > > I'm going to do more testing in next few days, so hoe bring some new info.
> > > 
> > > As I wrote before, it does not depend on the server (tried with FreeBSD
> > > server and several versions of linux 2.6.16.x and 2.6.18.x).
> > 
> > Just update: 2.6.17.14 is ok
> 
> did git bisect between 2.6.17 and 2.6.18 and found that the commit is:
> 
> 44b11874ff583b6e766a05856b04f3c492c32b84
>  NFS: Separate metadata and page cache revalidation mechanisms
> 
> will verify (with and without patch) tomorrow.

2.6.18.3 with reversed 44b11874ff583b6e766a05856b04f3c492c32b84 is OK.

exact patch used included.

will try to dig deeper yet a bit.

bye

--   

  Tomas Kasparek, PhD student  E-mail: kasparek@fit.vutbr.cz
  CVT FIT VUT Brno, BI/140a    Web:    http://www.fit.vutbr.cz/~kasparek
  Bozetechova 2, 612 66        Fax:    +420 54114-1270
  Brno, Czech Republic         Phone:  +420 54114-1220

  ICQ: 293092805  jabber: tomas.kasparek@jabber.cz
  GPG: 2F1E 1AAF FD3B CFA3 1537  63BD DCBE 18FF A035 53BC


--envbJBWh7q8WU6mo
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="nfs-zeros-own.patch"

This patch reverse the following:

http://www.kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=44b11874ff583b6e766a05856b04f3c492c32b84
NFS: Separate metadata and page cache revalidation mechanisms

diff -ruN linux-2.6.18.3/fs/nfs/dir.c linux-2.6.18.3-test/fs/nfs/dir.c
--- linux-2.6.18.3/fs/nfs/dir.c	2006-11-22 17:24:34.000000000 +0100
+++ linux-2.6.18.3-test/fs/nfs/dir.c	2006-11-24 07:10:18.495039500 +0100
@@ -528,7 +528,7 @@
 
 	lock_kernel();
 
-	res = nfs_revalidate_mapping(inode, filp->f_mapping);
+	res = nfs_revalidate_inode(NFS_SERVER(inode), inode);
 	if (res < 0) {
 		unlock_kernel();
 		return res;
diff -ruN linux-2.6.18.3/fs/nfs/file.c linux-2.6.18.3-test/fs/nfs/file.c
--- linux-2.6.18.3/fs/nfs/file.c	2006-09-20 07:53:53.000000000 +0200
+++ linux-2.6.18.3-test/fs/nfs/file.c	2006-11-24 07:10:18.659049750 +0100
@@ -127,6 +127,23 @@
 }
 
 /**
+ * nfs_revalidate_file - Revalidate the page cache & related metadata
+ * @inode - pointer to inode struct
+ * @file - pointer to file
+ */
+static int nfs_revalidate_file(struct inode *inode, struct file *filp)
+{
+	struct nfs_inode *nfsi = NFS_I(inode);
+	int retval = 0;
+
+	if ((nfsi->cache_validity & (NFS_INO_REVAL_PAGECACHE|NFS_INO_INVALID_ATTR))
+			|| nfs_attribute_timeout(inode))
+		retval = __nfs_revalidate_inode(NFS_SERVER(inode), inode);
+	nfs_revalidate_mapping(inode, filp->f_mapping);
+	return 0;
+}
+
+/**
  * nfs_revalidate_size - Revalidate the file size
  * @inode - pointer to inode struct
  * @file - pointer to struct file
@@ -211,7 +228,7 @@
 		dentry->d_parent->d_name.name, dentry->d_name.name,
 		(unsigned long) count, (unsigned long) pos);
 
-	result = nfs_revalidate_mapping(inode, iocb->ki_filp->f_mapping);
+	result = nfs_revalidate_file(inode, iocb->ki_filp);
 	nfs_add_stats(inode, NFSIOS_NORMALREADBYTES, count);
 	if (!result)
 		result = generic_file_aio_read(iocb, buf, count, pos);
@@ -230,7 +247,7 @@
 		dentry->d_parent->d_name.name, dentry->d_name.name,
 		(unsigned long) count, (unsigned long long) *ppos);
 
-	res = nfs_revalidate_mapping(inode, filp->f_mapping);
+	res = nfs_revalidate_file(inode, filp);
 	if (!res)
 		res = generic_file_sendfile(filp, ppos, count, actor, target);
 	return res;
@@ -246,7 +263,7 @@
 	dfprintk(VFS, "nfs: mmap(%s/%s)\n",
 		dentry->d_parent->d_name.name, dentry->d_name.name);
 
-	status = nfs_revalidate_mapping(inode, file->f_mapping);
+	status = nfs_revalidate_file(inode, file);
 	if (!status)
 		status = generic_file_mmap(file, vma);
 	return status;
@@ -366,6 +383,7 @@
 		if (result)
 			goto out;
 	}
+	nfs_revalidate_mapping(inode, iocb->ki_filp->f_mapping);
 
 	result = count;
 	if (!count)
diff -ruN linux-2.6.18.3/fs/nfs/inode.c linux-2.6.18.3-test/fs/nfs/inode.c
--- linux-2.6.18.3/fs/nfs/inode.c	2006-09-20 07:53:53.000000000 +0200
+++ linux-2.6.18.3-test/fs/nfs/inode.c	2006-11-24 07:10:18.707052750 +0100
@@ -593,7 +593,7 @@
 		status = -ESTALE;
 		/* Do we trust the cached ESTALE? */
 		if (NFS_ATTRTIMEO(inode) != 0) {
-			if (nfsi->cache_validity & (NFS_INO_INVALID_ATTR|NFS_INO_INVALID_ATIME)) {
+			if (nfsi->cache_validity & (NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA|NFS_INO_INVALID_ATIME)) {
 				/* no */
 			} else
 				goto out;
@@ -624,6 +624,8 @@
 	}
 	spin_unlock(&inode->i_lock);
 
+	nfs_revalidate_mapping(inode, inode->i_mapping);
+
 	if (nfsi->cache_validity & NFS_INO_INVALID_ACL)
 		nfs_zap_acl_cache(inode);
 
@@ -668,16 +670,9 @@
  * @inode - pointer to host inode
  * @mapping - pointer to mapping
  */
-int nfs_revalidate_mapping(struct inode *inode, struct address_space *mapping)
+void nfs_revalidate_mapping(struct inode *inode, struct address_space *mapping)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
-	int ret = 0;
-
-	if (NFS_STALE(inode))
-		ret = -ESTALE;
-	if ((nfsi->cache_validity & NFS_INO_REVAL_PAGECACHE)
-			|| nfs_attribute_timeout(inode))
-		ret = __nfs_revalidate_inode(NFS_SERVER(inode), inode);
 
 	if (nfsi->cache_validity & NFS_INO_INVALID_DATA) {
 		nfs_inc_stats(inode, NFSIOS_DATAINVALIDATE);
@@ -698,7 +693,6 @@
 				inode->i_sb->s_id,
 				(long long)NFS_FILEID(inode));
 	}
-	return ret;
 }
 
 /**
diff -ruN linux-2.6.18.3/fs/nfs/symlink.c linux-2.6.18.3-test/fs/nfs/symlink.c
--- linux-2.6.18.3/fs/nfs/symlink.c	2006-09-20 07:53:53.000000000 +0200
+++ linux-2.6.18.3-test/fs/nfs/symlink.c	2006-11-24 07:10:18.731054250 +0100
@@ -52,7 +52,7 @@
 {
 	struct inode *inode = dentry->d_inode;
 	struct page *page;
-	void *err = ERR_PTR(nfs_revalidate_mapping(inode, inode->i_mapping));
+	void *err = ERR_PTR(nfs_revalidate_inode(NFS_SERVER(inode), inode));
 	if (err)
 		goto read_failed;
 	page = read_cache_page(&inode->i_data, 0,
diff -ruN linux-2.6.18.3/include/linux/nfs_fs.h linux-2.6.18.3-test/include/linux/nfs_fs.h
--- linux-2.6.18.3/include/linux/nfs_fs.h	2006-09-20 07:54:03.000000000 +0200
+++ linux-2.6.18.3-test/include/linux/nfs_fs.h	2006-11-24 07:10:18.963068750 +0100
@@ -302,7 +302,7 @@
 extern int nfs_attribute_timeout(struct inode *inode);
 extern int nfs_revalidate_inode(struct nfs_server *server, struct inode *inode);
 extern int __nfs_revalidate_inode(struct nfs_server *, struct inode *);
-extern int nfs_revalidate_mapping(struct inode *inode, struct address_space *mapping);
+extern void nfs_revalidate_mapping(struct inode *inode, struct address_space *mapping);
 extern int nfs_setattr(struct dentry *, struct iattr *);
 extern void nfs_setattr_update_inode(struct inode *inode, struct iattr *attr);
 extern void nfs_begin_attr_update(struct inode *);

--envbJBWh7q8WU6mo
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--envbJBWh7q8WU6mo
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--envbJBWh7q8WU6mo--
