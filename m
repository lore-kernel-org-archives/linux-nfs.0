From: Olaf Kirch <okir@suse.de>
Subject: [PATCH] Prevent oops in nfs_sb_init
Date: Tue, 23 Mar 2004 11:17:40 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040323101740.GE24978@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="a8Wt8u1KmwUX3Y2C"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B5j0E-0002FQ-Qi
	for nfs@lists.sourceforge.net; Tue, 23 Mar 2004 02:19:22 -0800
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1B5j0E-0006ob-DA
	for nfs@lists.sourceforge.net; Tue, 23 Mar 2004 02:19:22 -0800
Received: from hermes.suse.de (Hermes.suse.de [195.135.221.8])
	(using TLSv1 with cipher EDH-RSA-DES-CBC3-SHA (168/168 bits))
	(No client certificate requested)
	by Cantor.suse.de (Postfix) with ESMTP id 796E5352359
	for <nfs@lists.sourceforge.net>; Tue, 23 Mar 2004 11:17:40 +0100 (CET)
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


--a8Wt8u1KmwUX3Y2C
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline

nfs_sb_init will crash when the fsinfo call fails, because
it tries to iput() an uninitialized pointer. The attached patch
should fix this.

Olaf
-- 
Olaf Kirch     |  Stop wasting entropy - start using predictable
okir@suse.de   |  tempfile names today!
---------------+ 

--a8Wt8u1KmwUX3Y2C
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: attachment; filename=nfs-mount-fail-crash

--- linux-2.6.4/fs/nfs/inode.c.orig	2004-03-22 17:21:52.000000000 +0100
+++ linux-2.6.4/fs/nfs/inode.c	2004-03-23 11:13:17.000000000 +0100
@@ -277,7 +277,7 @@
 nfs_sb_init(struct super_block *sb, rpc_authflavor_t authflavor)
 {
 	struct nfs_server	*server;
-	struct inode		*root_inode;
+	struct inode		*root_inode = NULL;
 	struct nfs_fattr	fattr;
 	struct nfs_fsinfo	fsinfo = {
 					.fattr = &fattr,
@@ -361,7 +361,7 @@
 	/* Yargs. It didn't work out. */
 out_no_root:
 	printk("nfs_read_super: get root inode failed\n");
-	if (!IS_ERR(root_inode))
+	if (root_inode && !IS_ERR(root_inode))
 		iput(root_inode);
 	return -EINVAL;
 }

--a8Wt8u1KmwUX3Y2C--


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
