From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [PATCH 6/19] A basic NFSv4 client for 2.5.x
Date: Wed, 9 Oct 2002 01:10:13 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15779.26069.950587.318118@charged.uio.no>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS maillist <nfs@lists.sourceforge.net>,
    nfsv4-wg@citi.umich.edu
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17z3UZ-0004Jv-00
	for <nfs@lists.sourceforge.net>; Tue, 08 Oct 2002 16:10:19 -0700
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

In NFSv4, an fsid is a 64-bit major number together with a 64-bit
minor number.  In previous versions, an fsid is a single number.
This patch changes 'struct nfs_fattr' accordingly.

diff -u --recursive --new-file linux-2.5.41-nfsv4-E05/fs/nfs/nfs2xdr.c linux-2.5.41-nfsv4-E06/fs/nfs/nfs2xdr.c
--- linux-2.5.41-nfsv4-E05/fs/nfs/nfs2xdr.c	2002-10-04 20:36:20.000000000 -0400
+++ linux-2.5.41-nfsv4-E06/fs/nfs/nfs2xdr.c	2002-10-08 18:44:43.000000000 -0400
@@ -107,7 +107,7 @@
 	fattr->du.nfs2.blocksize = ntohl(*p++);
 	fattr->rdev = ntohl(*p++);
 	fattr->du.nfs2.blocks = ntohl(*p++);
-	fattr->fsid = ntohl(*p++);
+	fattr->fsid_u.nfs3 = ntohl(*p++);
 	fattr->fileid = ntohl(*p++);
 	p = xdr_decode_time(p, &fattr->atime);
 	p = xdr_decode_time(p, &fattr->mtime);
diff -u --recursive --new-file linux-2.5.41-nfsv4-E05/fs/nfs/nfs3xdr.c linux-2.5.41-nfsv4-E06/fs/nfs/nfs3xdr.c
--- linux-2.5.41-nfsv4-E05/fs/nfs/nfs3xdr.c	2002-10-04 20:36:50.000000000 -0400
+++ linux-2.5.41-nfsv4-E06/fs/nfs/nfs3xdr.c	2002-10-08 18:44:43.000000000 -0400
@@ -173,7 +173,7 @@
 	/* Turn remote device info into Linux-specific dev_t */
 	fattr->rdev = ntohl(*p++) << MINORBITS;
 	fattr->rdev |= ntohl(*p++) & MINORMASK;
-	p = xdr_decode_hyper(p, &fattr->fsid);
+	p = xdr_decode_hyper(p, &fattr->fsid_u.nfs3);
 	p = xdr_decode_hyper(p, &fattr->fileid);
 	p = xdr_decode_time3(p, &fattr->atime);
 	p = xdr_decode_time3(p, &fattr->mtime);
diff -u --recursive --new-file linux-2.5.41-nfsv4-E05/include/linux/nfs_xdr.h linux-2.5.41-nfsv4-E06/include/linux/nfs_xdr.h
--- linux-2.5.41-nfsv4-E05/include/linux/nfs_xdr.h	2002-10-08 18:43:58.000000000 -0400
+++ linux-2.5.41-nfsv4-E06/include/linux/nfs_xdr.h	2002-10-08 18:44:43.000000000 -0400
@@ -24,7 +24,13 @@
 		} nfs3;
 	} du;
 	__u32			rdev;
-	__u64			fsid;
+	union {
+		__u64		nfs3;		/* also nfs2 */
+		struct {
+			__u64	major;
+			__u64	minor;
+		} nfs4;
+	} fsid_u;
 	__u64			fileid;
 	__u64			atime;
 	__u64			mtime;


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
