From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] detecting overflows in nfs_statfs
Date: Wed, 09 Jun 2004 13:17:09 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40C74615.5070605@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010108020007050800080309"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BY6hT-0003PA-OJ
	for nfs@lists.sourceforge.net; Wed, 09 Jun 2004 10:17:19 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BY6hT-0002TI-8W
	for nfs@lists.sourceforge.net; Wed, 09 Jun 2004 10:17:19 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.12.10/8.12.10) with ESMTP id i59HHCi5016207
	for <nfs@lists.sourceforge.net>; Wed, 9 Jun 2004 13:17:12 -0400
Received: from RedHat.com (vpn64-13.boston.redhat.com [172.16.66.13])
	by int-mx1.corp.redhat.com (8.11.6/8.11.6) with ESMTP id i59HHB027292
	for <nfs@lists.sourceforge.net>; Wed, 9 Jun 2004 13:17:11 -0400
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
--------------010108020007050800080309
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hello,

Here is 2.4  patch that allows nfs_statfs() to detect values that are
too large to deal with (i.e. > 32bit on a 32bit machine).  So instead
of returning garbage (as it does today), it returns all -1 which
commands (like df) know how interpret. For example:
df without the patch

Filesystem           1K-blocks      Used Available Use% Mounted on
pdl585-1:/           7108754432 -147573952589283246080 33966574080 101% 
/mnt/dl585-1

df with the patch:
Filesystem           1K-blocks      Used Available Use% Mounted on
pdl585-1:/                   1         1         1   0% /mnt/dl585-1

Which should be fairly obvious that something went wrong.....

Comments?

Maybe this issue has already been address on the list (I know Olaf
recently sent out a 2.6 patch) but if it hasn't.... maybe this is something
Marcelo would be interested in?

SteveD.


--------------010108020007050800080309
Content-Type: text/plain;
 name="linux-2.4.21-nfs-eoverflow.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.4.21-nfs-eoverflow.patch"

--- linux-2.4.21/fs/nfs/inode.c.orig	2004-06-09 12:52:29.000000000 -0400
+++ linux-2.4.21/fs/nfs/inode.c	2004-06-09 12:18:28.000000000 -0400
@@ -593,6 +593,7 @@ out_fail:
 	return NULL;
 }
 
+#define TOOBIG(_arg) ((_arg) > ~0UL)
 static int
 nfs_statfs(struct super_block *sb, struct statfs *buf)
 {
@@ -605,12 +606,27 @@ nfs_statfs(struct super_block *sb, struc
 
 	error = server->rpc_ops->statfs(server, NFS_FH(sb->s_root->d_inode), &res);
 	buf->f_type = NFS_SUPER_MAGIC;
-	if (error < 0)
+	if (error < 0) {
+		printk("nfs_statfs: statfs error = %d\n", -error);
 		goto out_err;
+	}
 
 	buf->f_bsize = sb->s_blocksize;
 	blockbits = sb->s_blocksize_bits;
 	blockres = (1 << blockbits) - 1;
+
+	/*
+	 * Make sure things fit
+	 */
+	if (TOOBIG(((res.tbytes + blockres) >> blockbits)))
+		goto too_big;
+	if (TOOBIG(((res.fbytes + blockres) >> blockbits)))
+		goto too_big;
+	if (TOOBIG(((res.abytes + blockres) >> blockbits)))
+		goto too_big;
+	if (TOOBIG(res.tfiles) || TOOBIG(res.afiles))
+		goto too_big;
+
 	buf->f_blocks = (res.tbytes + blockres) >> blockbits;
 	buf->f_bfree = (res.fbytes + blockres) >> blockbits;
 	buf->f_bavail = (res.abytes + blockres) >> blockbits;
@@ -618,11 +634,15 @@ nfs_statfs(struct super_block *sb, struc
 	buf->f_ffree = res.afiles;
 	buf->f_namelen = server->namelen;
 	return 0;
+
+ too_big:
+ 	dprintk("nfs_statfs: failed: EOVERFLOW\n");
+
  out_err:
-	printk("nfs_statfs: statfs error = %d\n", -error);
 	buf->f_bsize = buf->f_blocks = buf->f_bfree = buf->f_bavail = -1;
 	return 0;
 }
+#undef TOOBIG
 
 static int nfs_show_options(struct seq_file *m, struct vfsmount *mnt)
 {

--------------010108020007050800080309--


-------------------------------------------------------
This SF.Net email is sponsored by: GNOME Foundation
Hackers Unite!  GUADEC: The world's #1 Open Source Desktop Event.
GNOME Users and Developers European Conference, 28-30th June in Norway
http://2004/guadec.org
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
