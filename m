From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] detecting overflows in nfs_statfs
Date: Mon, 28 Jun 2004 07:20:53 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40DFFF15.5010909@RedHat.com>
References: <40C74615.5070605@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050009030606080607000909"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BeuC5-0001s4-Jw
	for nfs@lists.sourceforge.net; Mon, 28 Jun 2004 04:21:01 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1BeuC5-0001QI-5Z
	for nfs@lists.sourceforge.net; Mon, 28 Jun 2004 04:21:01 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.12.10/8.12.10) with ESMTP id i5SBKse1026654
	for <nfs@lists.sourceforge.net>; Mon, 28 Jun 2004 07:20:54 -0400
Received: from RedHat.com (vpn64-8.boston.redhat.com [172.16.66.8])
	by int-mx1.corp.redhat.com (8.11.6/8.11.6) with ESMTP id i5SBKr020793
	for <nfs@lists.sourceforge.net>; Mon, 28 Jun 2004 07:20:53 -0400
To: nfs@lists.sourceforge.net
In-Reply-To: <40C74615.5070605@RedHat.com>
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
--------------050009030606080607000909
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Steve Dickson wrote:

> Here is 2.4  patch that allows nfs_statfs() to detect values that are
> too large to deal with (i.e. > 32bit on a 32bit machine).  So instead
> of returning garbage (as it does today), it returns all -1 which
> commands (like df) know how interpret. For example:
> df without the patch
>
> Filesystem           1K-blocks      Used Available Use% Mounted on
> pdl585-1:/           7108754432 -147573952589283246080 33966574080 
> 101% /mnt/dl585-1
>
> df with the patch:
> Filesystem           1K-blocks      Used Available Use% Mounted on
> pdl585-1:/                   1         1         1   0% /mnt/dl585-1
>
> Which should be fairly obvious that something went wrong.....
>
> Comments?
>
> Maybe this issue has already been address on the list (I know Olaf
> recently sent out a 2.6 patch) but if it hasn't.... maybe this is 
> something
> Marcelo would be interested in?
>
This is an update to the previous patch that 1) always sets f_namelen
to a valid value since apps could be depending on it and 2) f_files
and f_ffree are set to -1 on any an overflows.

SteveD.



--------------050009030606080607000909
Content-Type: text/plain;
 name="linux-2.4.21-nfs-eoverflow4.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.4.21-nfs-eoverflow4.patch"

--- linux-2.4.21/fs/nfs/inode.c.orig	2004-06-09 12:52:29.000000000 -0400
+++ linux-2.4.21/fs/nfs/inode.c	2004-06-16 21:14:37.000000000 -0400
@@ -593,6 +593,7 @@ out_fail:
 	return NULL;
 }
 
+#define TOOBIG(_arg) ((_arg) > LONG_MAX)
 static int
 nfs_statfs(struct super_block *sb, struct statfs *buf)
 {
@@ -605,24 +606,44 @@ nfs_statfs(struct super_block *sb, struc
 
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
+	buf->f_namelen = server->namelen;
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
 	buf->f_files = res.tfiles;
 	buf->f_ffree = res.afiles;
-	buf->f_namelen = server->namelen;
 	return 0;
+
+ too_big:
+ 	dprintk("nfs_statfs: failed: EOVERFLOW\n");
+	buf->f_files = buf->f_ffree = -1;
+
  out_err:
-	printk("nfs_statfs: statfs error = %d\n", -error);
 	buf->f_bsize = buf->f_blocks = buf->f_bfree = buf->f_bavail = -1;
 	return 0;
 }
+#undef TOOBIG
 
 static int nfs_show_options(struct seq_file *m, struct vfsmount *mnt)
 {

--------------050009030606080607000909--


-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
