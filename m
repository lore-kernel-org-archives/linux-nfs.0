From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 5 of 5 - Make sure svc_process releases response even on error.
Date: Thu, 07 Nov 2002 11:56:51 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E189ayZ-0008KE-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 189ayh-0001ck-00
	for <nfs@lists.sourceforge.net>; Wed, 06 Nov 2002 16:56:59 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.204] == wireless-204.wireless.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Thu, 7 Nov 2002 11:56:51 +1100
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

If a rpc operation indicates that response should
be dropped (e.g. kmalloc failure) we must still
call pc_release to release anything it may have allocated.



 ----------- Diffstat output ------------
 ./net/sunrpc/svc.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletion(-)

--- ./net/sunrpc/svc.c	2002/11/06 23:12:09	1.2
+++ ./net/sunrpc/svc.c	2002/11/06 23:14:01	1.3
@@ -366,8 +366,12 @@ svc_process(struct svc_serv *serv, struc
 		}
 	} else {
 		dprintk("svc: calling dispatcher\n");
-		if (!versp->vs_dispatch(rqstp, statp))
+		if (!versp->vs_dispatch(rqstp, statp)) {
+			/* Release reply info */
+			if (procp->pc_release)
+				procp->pc_release(rqstp, NULL, rqstp->rq_resp);
 			goto dropit;
+		}
 	}
 
 	/* Check RPC status result */


-------------------------------------------------------
This sf.net email is sponsored by: See the NEW Palm 
Tungsten T handheld. Power & Color in a compact size!
http://ads.sourceforge.net/cgi-bin/redirect.pl?palm0001en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
