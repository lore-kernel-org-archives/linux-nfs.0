From: Greg Banks <gnb@melbourne.sgi.com>
Subject: [PATCH] SGI 900985: fix nohide export option for nfsv3
Date: Fri, 03 Oct 2003 13:47:19 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F7CF147.B778D07B@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A5GvG-0005B2-00
	for <nfs@lists.sourceforge.net>; Thu, 02 Oct 2003 20:48:06 -0700
Received: from zok.sgi.com ([204.94.215.101])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A5GvE-0006DZ-Gz
	for nfs@lists.sourceforge.net; Thu, 02 Oct 2003 20:48:04 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
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

SGI bug 900985.

The "nohide" export option fails over NFSv3 because the client gets
as a side effect of READDIRPLUS file handles for server-side mountpoints 
which haven't gone through the nohide logic in LOOKUP and thus refer
to the underlying directory instead the covering one.

This patch fixes that by changing the XDR encode for the READDIRPLUS
reply to send no file handle if the directory's child is a mountpoint.
The protocol says the filehandle is optional in the READDIRPLUS reply.
If the client has a client-side mountpoint matching the server-side
mountpoint, it will get the file handle of the mountpoint's covering
directory by traversing the client-side mountpoint.  Otherwise, the
client will issue a LOOKUP which will return either the underlying or
covering directories as per the normal nohide logic.

This is on-the-wire identical to how IRIX deals with the issue, as can
be easily demonstrated by sniffing NFS traffic to an IRIX box with a
nohide export.

Tested on Linux 2.4.21 servers with Linux 2.4 and IRIX clients.  The
patch is against 2.4 but the same bug exists in 2.6 and the same patch
should fix it (untested).



--- /usr/tmp/TmpDir.24872-0/linux/linux/fs/nfsd/nfs3xdr.c_1.23	Fri Sep 19 20:12:50
2003
+++ linux/linux/fs/nfsd/nfs3xdr.c	Fri Sep 19 20:09:25 2003
@@ -721,6 +721,8 @@
 			dchild = lookup_one_len(name, dparent,namlen);
 		if (IS_ERR(dchild))
 			goto noexec;
+		if (d_mountpoint(dchild))
+			goto noexec;
 		if (fh_compose(&fh, exp, dchild, cd->dirfh) != 0 || !dchild->d_inode)
 			goto noexec;
 		p = encode_post_op_attr(cd->rqstp, p, &fh);

--- /usr/tmp/TmpDir.24872-0/linux/linux/fs/nfsd/vfs.c_1.47	Fri Sep 19 20:12:50 2003
+++ linux/linux/fs/nfsd/vfs.c	Fri Sep 19 20:08:03 2003
@@ -86,7 +86,7 @@
  * accepted as it stands and the mounted directory is
  * returned. Otherwise the covered directory is returned.
  * NOTE: this mountpoint crossing is not supported properly by all
- *   clients and is explicitly disallowed for NFSv3
+ *   clients.
  *      NeilBrown <neilb@cse.unsw.edu.au>
  */
 int


Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
