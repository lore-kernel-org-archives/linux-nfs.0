From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 5 of 7 - Fix problem with lockd grace period checking.
Date: Tue, 17 Dec 2002 12:59:27 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E18O715-0000p8-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18O71O-0003nl-00
	for <nfs@lists.sourceforge.net>; Mon, 16 Dec 2002 17:59:46 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.239] == wireless-239.wireless.cse.unsw.EDU.AU)
	(for <marcelo@conectiva.com.br>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Tue, 17 Dec 2002 12:59:36 +1100
To: Marcelo Tosatti <marcelo@conectiva.com.br>
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



We need to do the clear/grace period here and not before
svc_recv() because svc_recv() may sleep longer than the
grace period and the first request may be falsely processed
as if the server was in the grace period when it was not
causing unnecessary delays for the first request received.
     * Juan C. Gomez j_carlos_gome@yahoo.com

Also opencode trivial clear_grace_period function.

 ----------- Diffstat output ------------
 ./fs/lockd/svc.c |   12 ++++--------
 1 files changed, 4 insertions(+), 8 deletions(-)

diff ./fs/lockd/svc.c~current~ ./fs/lockd/svc.c
--- ./fs/lockd/svc.c~current~	2002-12-16 16:29:58.000000000 +1100
+++ ./fs/lockd/svc.c	2002-12-16 16:29:59.000000000 +1100
@@ -72,11 +72,6 @@ static unsigned long set_grace_period(vo
 	return grace_period + jiffies;
 }
 
-static inline void clear_grace_period(void)
-{
-	nlmsvc_grace_period = 0;
-}
-
 /*
  * This is the lockd kernel thread
  */
@@ -142,10 +137,8 @@ lockd(struct svc_rqst *rqstp)
 		 * (Theoretically, there shouldn't even be blocked locks
 		 * during grace period).
 		 */
-		if (!nlmsvc_grace_period) {
+		if (!nlmsvc_grace_period)
 			timeout = nlmsvc_retry_blocked();
-		} else if (time_before(grace_period_expire, jiffies))
-			clear_grace_period();
 
 		/*
 		 * Find a socket with data available and call its
@@ -175,6 +168,9 @@ lockd(struct svc_rqst *rqstp)
 				nlmsvc_ops->exp_getclient(&rqstp->rq_addr);
 		}
 
+		if (nlmsvc_grace_period &&
+		    time_before(grace_period_expire, jiffies))
+			nlmsvc_grace_period = 0;
 		svc_process(serv, rqstp);
 
 		/* Unlock export hash tables */


-------------------------------------------------------
This sf.net email is sponsored by:
With Great Power, Comes Great Responsibility 
Learn to use your power at OSDN's High Performance Computing Channel
http://hpc.devchannel.org/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
