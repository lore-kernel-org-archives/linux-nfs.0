From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 4 of 5 - Fix problem where knfsd wouldn't release filesystem on unexport.
Date: Tue, 11 Feb 2003 15:37:24 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E18iSAe-0008Ha-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18iSAz-0005vN-00
	for <nfs@lists.sourceforge.net>; Mon, 10 Feb 2003 20:37:46 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Tue, 11 Feb 2003 15:37:33 +1100
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

Problem was that the cache was being updated inplace, rather
than swapping in a new entry, so old filesystem pointers
were overwritten without being released.

 ----------- Diffstat output ------------
 ./fs/nfsd/export.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff ./fs/nfsd/export.c~current~ ./fs/nfsd/export.c
--- ./fs/nfsd/export.c~current~	2003-02-11 14:25:42.000000000 +1100
+++ ./fs/nfsd/export.c	2003-02-11 14:25:42.000000000 +1100
@@ -691,7 +691,7 @@ exp_export(struct nfsctl_export *nxp)
 	new.ex_anon_gid = nxp->ex_anon_gid;
 	new.ex_fsid = nxp->ex_dev;
 
-	exp = svc_export_lookup(&new, 2);
+	exp = svc_export_lookup(&new, 1);
 
 	if (exp == NULL)
 		goto finish;


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
