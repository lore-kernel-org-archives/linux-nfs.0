From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: sendmail "cannot fsync directory" after 2.4 -> 2.6
Date: Thu, 09 Sep 2004 10:58:39 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1094741919.7972.5.camel@lade.trondhjem.org>
References: <413FF4EB.2070607@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-1IipP6agcrr0e546maVT"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C5QO3-0001ad-Rc
	for nfs@lists.sourceforge.net; Thu, 09 Sep 2004 07:58:59 -0700
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1C5QO0-0005C6-M5
	for nfs@lists.sourceforge.net; Thu, 09 Sep 2004 07:58:58 -0700
To: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
In-Reply-To: <413FF4EB.2070607@bio.ifi.lmu.de>
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


--=-1IipP6agcrr0e546maVT
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

P=E5 to , 09/09/2004 klokka 02:15, skreiv Frank Steiner:

> Sep  9 08:03:13 galois sendmail[21596]: sync_dir: cannot fsync directory =
.: Invalid argument
> Sep  9 08:04:02 galois sendmail[21649]: i89641NZ021648: SYSERR(root): syn=
c_dir: cannot fsync directory .: Invalid argument

Yep. We forgot to add the stub to Linux 2.6.x. Please confirm that the
following patch fixes the problem for you.

Cheers,
  Trond


--=-1IipP6agcrr0e546maVT
Content-Disposition: inline; filename=linux-2.6.9-01-add_dummy_fsync.dif
Content-Type: text/plain; name=linux-2.6.9-01-add_dummy_fsync.dif; charset=iso-8859-1
Content-Transfer-Encoding: 7bit

NFS: add an fsync() stub for directories

Signed-off-by: Trond Myklebust <trond.myklebust@fys.uio.no>

---
 dir.c |   11 +++++++++++
 1 files changed, 11 insertions(+)

Index: linux-2.6.9-rc1/fs/nfs/dir.c
===================================================================
--- linux-2.6.9-rc1.orig/fs/nfs/dir.c	2004-09-08 21:14:12.000000000 -0400
+++ linux-2.6.9-rc1/fs/nfs/dir.c	2004-09-09 10:53:49.332399870 -0400
@@ -51,12 +51,14 @@
 static int nfs_mknod(struct inode *, struct dentry *, int, dev_t);
 static int nfs_rename(struct inode *, struct dentry *,
 		      struct inode *, struct dentry *);
+static int nfs_fsync_dir(struct file *, struct dentry *, int);
 
 struct file_operations nfs_dir_operations = {
 	.read		= generic_read_dir,
 	.readdir	= nfs_readdir,
 	.open		= nfs_opendir,
 	.release	= nfs_release,
+	.fsync		= nfs_fsync_dir,
 };
 
 struct inode_operations nfs_dir_inode_operations = {
@@ -493,6 +495,15 @@
 }
 
 /*
+ * All directory operations under NFS are synchronous, so fsync()
+ * is a dummy operation.
+ */
+int nfs_fsync_dir(struct file *filp, struct dentry *dentry, int datasync)
+{
+	return 0;
+}
+
+/*
  * A check for whether or not the parent directory has changed.
  * In the case it has, we assume that the dentries are untrustworthy
  * and may need to be looked up again.

--=-1IipP6agcrr0e546maVT--



-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM. 
Deadline: Sept. 13. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
