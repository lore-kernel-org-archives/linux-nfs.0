From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 1 of 8 - Fix bug in svc_pushback_unused_pages that occurs on zero byte NFS read
Date: Wed, 18 Jun 2003 09:51:37 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E19SQEj-00083C-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19SQBP-0002U4-00
	for <nfs@lists.sourceforge.net>; Tue, 17 Jun 2003 16:48:11 -0700
Received: From notabene ([129.94.172.124] == notabene.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Wed, 18 Jun 2003 09:47:00 +1000
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


Here come 8 kNFSd patches for 2.5.72.
Several are nfsv4 related, but the first two are more generally applicable.

NeilBrown
### Comments for ChangeSet

svc_pushback_unused_pages must be ready of the possibility that
no pages were allocated or will need to be pushed back.

 ----------- Diffstat output ------------
 ./include/linux/sunrpc/svc.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff ./include/linux/sunrpc/svc.h~current~ ./include/linux/sunrpc/svc.h
--- ./include/linux/sunrpc/svc.h~current~	2003-06-18 09:17:34.000000000 +1000
+++ ./include/linux/sunrpc/svc.h	2003-06-18 09:17:34.000000000 +1000
@@ -196,14 +196,14 @@ static inline void svc_pushback_allpages
 
 static inline void svc_pushback_unused_pages(struct svc_rqst *rqstp)
 {
-        while (rqstp->rq_resused) {
+	while (rqstp->rq_resused &&
+	       rqstp->rq_res.pages != &rqstp->rq_respages[rqstp->rq_resused]) {
+
 		if (rqstp->rq_respages[--rqstp->rq_resused] != NULL) {
 			rqstp->rq_argpages[rqstp->rq_arghi++] =
 				rqstp->rq_respages[rqstp->rq_resused];
 			rqstp->rq_respages[rqstp->rq_resused] = NULL;
 		}
-		if (rqstp->rq_res.pages == &rqstp->rq_respages[rqstp->rq_resused])
-			break;
 	}
 }
 


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
