From: Miquel van Smoorenburg <miquels@cistron.nl>
Subject: off_t in nfsd_commit needs to be loff_t
Date: Mon, 2 Feb 2004 13:02:18 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040202120217.GA9380@cistron.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ancmb-0007er-HB
	for nfs@lists.sourceforge.net; Mon, 02 Feb 2004 04:02:29 -0800
Received: from 10fwd.cistron-office.nl
	([62.216.29.197] helo=smtp.cistron-office.nl ident=mail)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1Ancma-0003f3-Rx
	for nfs@lists.sourceforge.net; Mon, 02 Feb 2004 04:02:29 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>
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

While I was stress-testing NFS/XFS on 2.6.1/2.6.2-rc, I found that
sometimes my "dd" would exit with:

	#  dd if=/dev/zero bs=4096 > /mnt/file
	dd: writing `standard output': Invalid argument
	1100753+0 records in
	1100752+0 records out

After adding some debug printk's to the server and client code
and some tcpdump-ing, I found that the NFSERR_INVAL was returned by
nfsd_commit on the server.

Turns out that the "offset" argument is off_t instead of loff_t.
It isn't used at all (unfortunately), but it _is_ checked for
sanity, so that's where the error came from.

Here's the fix: nfsd_commit-loff_t.patch

Should go into the next -rc, I guess.

diff -ruN -X /home/staff/miquels/diff-exclude linux-2.6.2-rc2.orig/include/linux/nfsd/nfsd.h linux-2.6.2-rc2/include/linux/nfsd/nfsd.h
--- linux-2.6.2-rc2.orig/include/linux/nfsd/nfsd.h	2004-01-09 08:00:04.000000000 +0100
+++ linux-2.6.2-rc2/include/linux/nfsd/nfsd.h	2004-02-02 12:27:31.000000000 +0100
@@ -86,7 +86,7 @@
 				struct svc_fh *res, int createmode,
 				u32 *verifier, int *truncp);
 int		nfsd_commit(struct svc_rqst *, struct svc_fh *,
-				off_t, unsigned long);
+				loff_t, unsigned long);
 #endif /* CONFIG_NFSD_V3 */
 int		nfsd_open(struct svc_rqst *, struct svc_fh *, int,
 				int, struct file *);
diff -ruN -X /home/staff/miquels/diff-exclude linux-2.6.2-rc2.orig/fs/nfsd/nfs3proc.c linux-2.6.2-rc2/fs/nfsd/nfs3proc.c
--- linux-2.6.2-rc2.orig/fs/nfsd/nfs3proc.c	2004-01-09 07:59:26.000000000 +0100
+++ linux-2.6.2-rc2/fs/nfsd/nfs3proc.c	2004-02-02 12:49:20.000000000 +0100
@@ -595,10 +595,10 @@
 {
 	int	nfserr;
 
-	dprintk("nfsd: COMMIT(3)   %s %d@%ld\n",
+	dprintk("nfsd: COMMIT(3)   %s %u@%Lu\n",
 				SVCFH_fmt(&argp->fh),
 				argp->count,
-				(unsigned long) argp->offset);
+				(unsigned long long) argp->offset);
 
 	if (argp->offset > NFS_OFFSET_MAX)
 		RETURN_STATUS(nfserr_inval);
diff -ruN -X /home/staff/miquels/diff-exclude linux-2.6.2-rc2.orig/fs/nfsd/vfs.c linux-2.6.2-rc2/fs/nfsd/vfs.c
--- linux-2.6.2-rc2.orig/fs/nfsd/vfs.c	2004-02-01 12:12:04.000000000 +0100
+++ linux-2.6.2-rc2/fs/nfsd/vfs.c	2004-02-02 12:48:38.000000000 +0100
@@ -823,7 +823,7 @@
  */
 int
 nfsd_commit(struct svc_rqst *rqstp, struct svc_fh *fhp,
-               off_t offset, unsigned long count)
+               loff_t offset, unsigned long count)
 {
 	struct file	file;
 	int		err;


Mike.


-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
