From: Greg Banks <gnb@sgi.com>
Subject: [PATCH 2.6] SGI 921857: find broken with nohide on NFSv3
Date: Thu, 23 Sep 2004 18:15:17 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040923081517.GB11180@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CAOar-0004jK-5O
	for nfs@lists.sourceforge.net; Thu, 23 Sep 2004 01:04:45 -0700
Received: from omx3-ext.sgi.com ([192.48.171.20] helo=omx3.sgi.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CAOap-000451-Qt
	for nfs@lists.sourceforge.net; Thu, 23 Sep 2004 01:04:45 -0700
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

G'day,

This patch makes "find" work when traversing nohide exports on NFSv3.
The READDIRPLUS reply needs to not return a file handle for the ".."
entry when the directory is a server side mountpoint, which would be
the directory itself, otherwise the client remembers the wrong file
handle and gets confused.

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>


Index: linux/fs/nfsd/nfs3xdr.c
===================================================================
--- linux.orig/fs/nfsd/nfs3xdr.c	2004-09-22 17:20:41.%N +1000
+++ linux/fs/nfsd/nfs3xdr.c	2004-09-22 19:45:27.%N +1000
@@ -817,6 +817,10 @@ compose_entry_fh(struct nfsd3_readdirres
 	if (isdotent(name, namlen)) {
 		if (namlen == 2) {
 			dchild = dget_parent(dparent);
+			if (dchild == dparent) {
+				dput(dchild);
+				return 1;
+			}
 		} else
 			dchild = dget(dparent);
 	} else


Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
