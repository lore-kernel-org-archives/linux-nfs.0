From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 11 of 18] nfsd4_open_locktype_posix_flag
Date: Fri, 24 Sep 2004 14:54:53 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1CAi6f-0000kW-L0@notabene.cse.unsw.edu.au>
References: <20040924145130.2689.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CAi6u-00084i-B8
	for nfs@lists.sourceforge.net; Thu, 23 Sep 2004 21:55:08 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CAi6t-00069V-Os
	for nfs@lists.sourceforge.net; Thu, 23 Sep 2004 21:55:08 -0700
To: Andrew Morton <akpm@osdl.org>
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



We should set the OPEN_RESULT_LOCKTYPE_POSIX flag in the return to open, to
indicate that we support locking.

Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c  |    2 +-
 ./include/linux/nfs4.h |    1 +
 2 files changed, 2 insertions(+), 1 deletion(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2004-09-24 14:48:39.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2004-09-24 14:48:39.000000000 +1000
@@ -1383,7 +1383,7 @@ out:
 	/*
 	* To finish the open response, we just need to set the rflags.
 	*/
-	open->op_rflags = 0;
+	open->op_rflags = NFS4_OPEN_RESULT_LOCKTYPE_POSIX;
 	if (!open->op_stateowner->so_confirmed)
 		open->op_rflags |= NFS4_OPEN_RESULT_CONFIRM;
 

diff ./include/linux/nfs4.h~current~ ./include/linux/nfs4.h
--- ./include/linux/nfs4.h~current~	2004-09-24 14:47:14.000000000 +1000
+++ ./include/linux/nfs4.h	2004-09-24 14:48:39.000000000 +1000
@@ -35,6 +35,7 @@
 #define NFS4_FH_VOL_RENAME		0x0008
 
 #define NFS4_OPEN_RESULT_CONFIRM 0x0002
+#define NFS4_OPEN_RESULT_LOCKTYPE_POSIX 0x0004
 
 #define NFS4_SHARE_ACCESS_READ	0x0001
 #define NFS4_SHARE_ACCESS_WRITE	0x0002


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
