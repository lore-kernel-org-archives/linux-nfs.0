From: Chuck Lever <cel@citi.umich.edu>
Subject: [PATCH] too many setattr calls from VFS layer
Date: Thu, 7 Nov 2002 17:43:54 -0500 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0211071740520.18237-100000@dexter.citi.umich.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   Linux NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from dexter.citi.umich.edu ([141.211.133.33])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 189vNe-0000xF-00
	for <nfs@lists.sourceforge.net>; Thu, 07 Nov 2002 14:44:06 -0800
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

new code in 2.5 VFS layer invokes notify_change to clear the suid and sgid
bits for every write request.  notify_change needs to optimize out calls
to ->setattr that don't do anything, because for many network file
systems, an on-the-wire SETATTR request is generated for every ->setattr
call, resulting in unnecessary latency for NFS writes.


diff -ruN 05-nfsroot/fs/attr.c 06-setattr/fs/attr.c
--- 05-nfsroot/fs/attr.c	Mon Nov  4 17:30:07 2002
+++ 06-setattr/fs/attr.c	Thu Nov  7 17:31:37 2002
@@ -134,6 +134,7 @@
 	if (!(ia_valid & ATTR_MTIME_SET))
 		attr->ia_mtime = now;
 	if (ia_valid & ATTR_KILL_SUID) {
+		attr->ia_valid &= ~ATTR_KILL_SUID;
 		if (mode & S_ISUID) {
 			if (!(ia_valid & ATTR_MODE)) {
 				ia_valid = attr->ia_valid |= ATTR_MODE;
@@ -143,6 +144,7 @@
 		}
 	}
 	if (ia_valid & ATTR_KILL_SGID) {
+		attr->ia_valid &= ~ ATTR_KILL_SGID;
 		if ((mode & (S_ISGID | S_IXGRP)) == (S_ISGID | S_IXGRP)) {
 			if (!(ia_valid & ATTR_MODE)) {
 				ia_valid = attr->ia_valid |= ATTR_MODE;
@@ -151,6 +153,8 @@
 			attr->ia_mode &= ~S_ISGID;
 		}
 	}
+	if (!attr->ia_valid)
+		return 0;
 
 	if (inode->i_op && inode->i_op->setattr) {
 		error = security_ops->inode_setattr(dentry, attr);



-------------------------------------------------------
This sf.net email is sponsored by: See the NEW Palm 
Tungsten T handheld. Power & Color in a compact size!
http://ads.sourceforge.net/cgi-bin/redirect.pl?palm0001en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
