From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 3 of 4 - Subject: NFSD binary compatibility breakage
Date: Sun, 13 Apr 2003 16:18:16 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E194aoi-0007m2-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 194apm-0006hW-00
	for <nfs@lists.sourceforge.net>; Sat, 12 Apr 2003 23:19:22 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Sun, 13 Apr 2003 16:19:17 +1000
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

### Comments for ChangeSet

The removal of "struct nfsctl_uidmap" from "nfsctl_fdparm" broke
binary compatiblity on 64-bit platforms (strictly speaking: on all
platforms with alignof(void *) > alignof(int)).  The problem is that
nfsctl_uidmap contained a "char *", which forced the alignment of the
entire union to be 64 bits.  With the removal of the uidmap, the
required alignment drops to 32 bits.  Since the first member is only
32 bits in size, this breaks compatibility with user-space.  Patch
below fixes the problem.

 ----------- Diffstat output ------------
 ./include/linux/nfsd/syscall.h |    7 +++++++
 1 files changed, 7 insertions(+)

diff ./include/linux/nfsd/syscall.h~current~ ./include/linux/nfsd/syscall.h
--- ./include/linux/nfsd/syscall.h~current~	2003-04-13 16:15:29.000000000 +1000
+++ ./include/linux/nfsd/syscall.h	2003-04-13 16:15:29.000000000 +1000
@@ -91,6 +91,13 @@ struct nfsctl_arg {
 		struct nfsctl_export	u_export;
 		struct nfsctl_fdparm	u_getfd;
 		struct nfsctl_fsparm	u_getfs;
+		/*
+		 * The following dummy member is needed to preserve binary compatibility
+		 * on platforms where alignof(void*)>alignof(int).  It's needed because
+		 * this union used to contain a member (u_umap) which contained a
+		 * pointer.
+		 */
+		void *u_ptr;
 	} u;
 #define ca_svc		u.u_svc
 #define ca_client	u.u_client


-------------------------------------------------------
This SF.net email is sponsored by: Etnus, makers of TotalView, The debugger 
for complex code. Debugging C/C++ programs can leave you feeling lost and 
disoriented. TotalView can help you find your way. Available on major UNIX 
and Linux platforms. Try it free. www.etnus.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
