From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 4 of 15 - Handle -EAGAIN from exp_find properly in nfsfh.c
Date: Mon, 06 Jan 2003 11:05:03 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E18VKlL-0002XM-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18VKld-0002X5-00
	for <nfs@lists.sourceforge.net>; Sun, 05 Jan 2003 16:05:21 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Mon, 6 Jan 2003 11:05:04 +1100
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



 ----------- Diffstat output ------------
 ./fs/nfsd/nfsfh.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff ./fs/nfsd/nfsfh.c~current~ ./fs/nfsd/nfsfh.c
--- ./fs/nfsd/nfsfh.c~current~	2003-01-06 09:55:50.000000000 +1100
+++ ./fs/nfsd/nfsfh.c	2003-01-06 09:55:50.000000000 +1100
@@ -146,11 +146,11 @@ fh_verify(struct svc_rqst *rqstp, struct
 		}
 
 		error = nfserr_dropit;
-		if (IS_ERR(exp))
+		if (IS_ERR(exp) && PTR_ERR(exp) == -EAGAIN)
 			goto out;
 
 		error = nfserr_stale; 
-		if (!exp)
+		if (!exp || IS_ERR(exp))
 			goto out;
 
 		/* Check if the request originated from a secure port. */


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
