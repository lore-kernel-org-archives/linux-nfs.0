From: Greg Banks <gnb@melbourne.sgi.com>
Subject: [PATCH] SGI 901086: NFSv2 SETATTR current server time support
Date: Mon, 20 Oct 2003 20:05:19 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F93B35F.EAFC7028@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1ABYbK-0005ez-00
	for <nfs@lists.sourceforge.net>; Mon, 20 Oct 2003 04:53:30 -0700
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=rj.sgi.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1ABWxm-0004Ya-O2
	for nfs@lists.sourceforge.net; Mon, 20 Oct 2003 03:08:34 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>,
   Trond Myklebust <trond.myklebust@fys.uio.no>
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

SGI bug 901086.

In the NFSv3 RFC, the sattr3 structure passed in the SETATTR call allows
for the client to request that the mtime and/or atime of an inode be set
to the current server time, the given (client) time, or not changed.  The
set-to-current-server value is used when you run "touch file" on the client.

This is significant for two reasons.  First, if there is clock skew between
the client and server there are times when you want the server time.  Secondly, 
the filesystem permissions checks for the two cases are actually different:
setting to an explicit time requires the setting process to own the file (or
be root), but setting to the current time requires only that the file be
writable to the process (or the process be root).

The NFSv2 RFC defines no such encoding for the sattr structure.  However
Solaris and Irix machine obey a convention where passing the invalid value
mtime.useconds=1000000 means "set both mtime and atime to the current
server time".  The convention is documented in the book "NFS Illustrated"
by Brent Callaghan.  The patch below implements this convention for the
Linux client and server (hence multiple To:s).

Tested between ia64 Linux 2.4.21, Irix & Solaris.



===========================================================================
linux/linux/fs/nfs/nfs2xdr.c
===========================================================================

--- /usr/tmp/TmpDir.14185-0/linux/linux/fs/nfs/nfs2xdr.c_1.11	Mon Oct 20 19:30:02
2003
+++ linux/linux/fs/nfs/nfs2xdr.c	Mon Oct 20 19:08:49 2003
@@ -139,9 +139,21 @@
 		*p++ = ~(u32) 0;
 	}
 
-	if (attr->ia_valid & (ATTR_MTIME|ATTR_MTIME_SET)) {
+	if (attr->ia_valid & ATTR_MTIME_SET) {
 		*p++ = htonl(attr->ia_mtime);
 		*p++ = 0;
+	} else if (attr->ia_valid & ATTR_MTIME) {
+	    	/*
+		 * Passing the invalid value useconds=1000000 for mtime
+		 * is a Sun convention for "set both mtime and atime to
+		 * current server time".  It's needed to make permissions
+		 * checks for the "touch" program across v2 mounts to
+		 * Solaris and Irix boxes work correctly. See description of
+		 * sattr in section 6.1 of "NFS Illustrated" by
+		 * Brent Callaghan, Addison-Wesley, ISBN 0-201-32750-5
+		 */
+		*p++ = htonl(attr->ia_mtime);
+		*p++ = __constant_htonl(1000000);
 	} else {
 		*p++ = ~(u32) 0;	
 		*p++ = ~(u32) 0;

===========================================================================
linux/linux/fs/nfsd/nfsxdr.c
===========================================================================

--- /usr/tmp/TmpDir.14185-0/linux/linux/fs/nfsd/nfsxdr.c_1.12	Mon Oct 20 19:30:02
2003
+++ linux/linux/fs/nfsd/nfsxdr.c	Mon Oct 20 18:27:02 2003
@@ -126,6 +126,17 @@
 	tmp  = ntohl(*p++); tmp1 = ntohl(*p++);
 	if (tmp != (u32)-1 && tmp1 != (u32)-1) {
 		iap->ia_valid |= ATTR_MTIME | ATTR_MTIME_SET;
+	    	/*
+		 * Passing the invalid value useconds=1000000 for mtime
+		 * is a Sun convention for "set both mtime and atime to
+		 * current server time".  It's needed to make permissions
+		 * checks for the "touch" program across v2 mounts to
+		 * Solaris and Irix boxes work correctly. See description of
+		 * sattr in section 6.1 of "NFS Illustrated" by
+		 * Brent Callaghan, Addison-Wesley, ISBN 0-201-32750-5
+		 */
+		if (tmp1 == 1000000)
+			iap->ia_valid &= ~(ATTR_ATIME_SET|ATTR_MTIME_SET);
 		iap->ia_mtime = tmp;
 	}
 	return p;

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
This SF.net email sponsored by: Enterprise Linux Forum Conference & Expo
The Event For Linux Datacenter Solutions & Strategies in The Enterprise 
Linux in the Boardroom; in the Front Office; & in the Server Room 
http://www.enterpriselinuxforum.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
