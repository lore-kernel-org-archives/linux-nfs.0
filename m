From: Christoph Hellwig <hch@infradead.org>
Subject: #255931 NFS fh_verify causes lost output
Date: Wed, 18 Aug 2004 21:00:41 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040818210041.A2223@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Szabo <psz@maths.usyd.edu.au>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BxWcA-00065x-J0
	for nfs@lists.sourceforge.net; Wed, 18 Aug 2004 13:00:54 -0700
Received: from imladris.demon.co.uk ([193.237.130.41] helo=phoenix.infradead.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1BxWc9-0006jR-E3
	for nfs@lists.sourceforge.net; Wed, 18 Aug 2004 13:00:54 -0700
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

We have the following report from Paul Szabo in the Debian bugtracking system,
any chance someone could look into it?  The RedHat bugzilla reference is quite
interesting aswell.

-----------------------------------------------------------------------------
Package: kernel
Version: N/A; reported 2004-06-24
Severity: important
Tags: patch

With default root_squash and subtree_check options, there is a problem with
NFS exports. The bug may appear also with no_root_squash; can always be
avoided with no_subtree_check. The bug causes open filehandles to become
stale, and further read/write access to fail.

References to what I think are the same issue:
http://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=110421
http://groups.google.com.au/groups?hl=en&lr=&ie=UTF-8&threadm=fa.jnukgbv.3i82ba%40ifi.uio.no&rnum=3&prev=/groups%3Fq%3Dfh_verify%253A%2Bno%2Broot_squashed%26ie%3DISO-8859-1%26hl%3Den
showing that the problem is not specific to Debian, and is present on a
wide range of kernel versions.

Can reproduce the problem with lsof. Seems that if the "owner" runs lsof,
then root does lsof quite soon, there is no problem; root needs to wait a
while to produce the problem; there seems to be a 10-second cache period.
Demo (see output files vanish if user has NFS-mounted home):

su - psz -c 'sleep 1000 >sleep.out 2>&1 <&- &'            ## Start process
sleep 20; su - psz -c 'lsof -c sl'; sleep 1; lsof -u psz  ## OK (may repeat)
sleep 20; su - psz -c 'lsof -c sl'; sleep 20; lsof -u psz ## Fail

The server will log something like
  kernel: fh_verify: no root_squashed access at psz/sleep.out.

The problem causes loss of output, some or all may be lost e.g. for

sh -c 'echo hello; sleep 200; echo bye' >sh.out &
perl -e 'echo "hello\n"; sleep 200; echo "bye\n"' >pl.out &

The following patch (against kernel-source-2.4.22) seems to fix the
problem:

--- fs/nfsd/nfsfh.c.orig	Sat Aug 30 16:01:44 2003
+++ fs/nfsd/nfsfh.c	Wed Jun 23 12:57:52 2004
@@ -705,11 +705,23 @@
 			/* make sure parents give x permission to user */
 			error = permission(parent->d_inode, MAY_EXEC);
 			if (error)
+/*			{
+				printk("fh_verify: no UID=%d,GID=%d (userset=%d) access to %s at %s/%s\n",
+					current->fsuid, current->fsgid, rqstp->rq_userset,
+				       parent->d_name.name,
+				       dentry->d_parent->d_name.name,
+				       dentry->d_name.name); */
 				break;
+/*			} */
 			tdentry = parent;
 		}
 		if (exp->ex_dentry != tdentry) {
-			error = nfserr_stale;
+			error = nfserr_acces;
+/* PSz 23 Jun 04  Not STALE but ACCES: so NFS client code (RPC really)
+ *                net/sunrpc/clnt.c will handle and re-try as real user,
+ *                do not want fs/nfs/inode.c to remove the inode. */
+/* Should not say root_squashed without checking ROOTSQUASH or ALLSQUASH
+ * and UID/GID. (Probably should be dprintk: lucky it was not.) */
 			printk("fh_verify: no root_squashed access at %s/%s.\n",
 			       dentry->d_parent->d_name.name,
 			       dentry->d_name.name);

Cheers,

Paul Szabo - psz@maths.usyd.edu.au  http://www.maths.usyd.edu.au:8000/u/psz/
School of Mathematics and Statistics  University of Sydney   2006  Australia


-- System Information
Debian Release: 3.0
Architecture: i386
Kernel: Linux pisa.maths.usyd.edu.au 2.4.22-smssvr1.5 #1 SMP Fri Apr 16 13:55:30 EST 2004 i686
Locale: LANG=C, LC_CTYPE=C





-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
