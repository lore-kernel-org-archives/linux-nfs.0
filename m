From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [PATCH 15/19] A basic NFSv4 client for 2.5.x
Date: Sat, 12 Oct 2002 01:48:55 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15783.25447.680627.489259@charged.uio.no>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS maillist <nfs@lists.sourceforge.net>,
    nfsv4-wg@citi.umich.edu
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1809Wl-0002eb-00
	for <nfs@lists.sourceforge.net>; Fri, 11 Oct 2002 16:49:08 -0700
To: Linus Torvalds <torvalds@transmeta.com>
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

A trivial loose end: add a 'lease_time' field to 'struct nfs_fsinfo'.

diff -u --recursive --new-file linux-2.5.41-nfsv4-E14/include/linux/nfs_xdr.h linux-2.5.41-nfsv4-E15/include/linux/nfs_xdr.h
--- linux-2.5.41-nfsv4-E14/include/linux/nfs_xdr.h	2002-10-11 18:22:12.000000000 -0400
+++ linux-2.5.41-nfsv4-E15/include/linux/nfs_xdr.h	2002-10-11 18:23:09.000000000 -0400
@@ -67,6 +67,7 @@
 	__u64			afiles;	/* # of files available to user */
 	__u32			linkmax;/* max # of hard links */
 	__u32			namelen;/* max name length */
+	__u32			lease_time; /* in seconds */
 };
 
 /*


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
