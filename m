From: Greg Banks <gnb@melbourne.sgi.com>
Subject: [PATCH] SGI 905314 (2/2): document constraints on client transfer size
Date: Fri, 28 Nov 2003 23:45:52 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3FC74380.6367DBAA@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1APi0p-0001XT-00
	for <nfs@lists.sourceforge.net>; Fri, 28 Nov 2003 04:46:19 -0800
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=zok.sgi.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1APi0p-0005ZF-In
	for nfs@lists.sourceforge.net; Fri, 28 Nov 2003 04:46:19 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

G'day,

SGI bug #905314

This patch adds a comment documenting the actual constraints
on NFS_MAX_FILE_IO_BUFFER_SIZE for the next guy who needs to know ;-)

--- /usr/tmp/TmpDir.28396-0/linux/linux/include/linux/nfs_fs.h_1.21	Fri Nov 28
23:07:47 2003
+++ linux/include/linux/nfs_fs.h	Fri Nov 28 21:55:30 2003
@@ -40,6 +40,18 @@
  */
 #define NFS_MAX_DIRCACHE		16
 
+/* 
+ * NFS_MAX_FILE_IO_BUFFER_SIZE limits the rsize and wsize that
+ * userspace can request in mount options (note that the server
+ * also gives us a limit in response to the FSINFO call).  The
+ * value is constrained by 1) has to fit in a UDP datagram less
+ * some headers 2) has to be a multiple of page size 3) has to
+ * be no more than NFS_READ_MAXIOV=8 pages for rsize, and
+ * NFS_WRITE_MAXIOV=8 pages for wsize and 4) has to be a power
+ * of two (actually this is bogus but nfs_read_super relies on it).
+ * For best performance we usually want the largest value
+ * consistent with these constraints.
+ */
 #define NFS_MAX_FILE_IO_BUFFER_SIZE	32768
 #define NFS_DEF_FILE_IO_BUFFER_SIZE	4096
 



Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
