From: Juan Gomez <juang@us.ibm.com>
Subject: kNFS(lockd) patch for linux-2.4.19
Date: Wed, 16 Oct 2002 10:02:27 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <OF4E36542B.49FA2553-ON87256C54.005D4BE5@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net,
   trond.myklebust@fys.uio.no
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from e6.ny.us.ibm.com ([32.97.182.106])
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 181rZH-0004Cy-00
	for <nfs@lists.sourceforge.net>; Wed, 16 Oct 2002 10:02:48 -0700
To: neilb@cse.unsw.edu.au
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






Neil,

Here is the same patch for 2.4.* hopefuly you can get this in the kernel as
well as I have not received any reply from Marcelo.

Juan

----- Forwarded by Juan Gomez/Almaden/IBM on 10/16/02 10:00 AM -----
                                                                                                                                      
                      Juan Gomez                                                                                                      
                                               To:       marcelo@conectiva.com.br                                                     
                      10/15/02 09:10 AM        cc:       linux-kernel@vger.kernel.org                                                 
                                               From:     Juan Gomez/Almaden/IBM@IBMUS                                                 
                                               Subject:  kNFS(lockd) patch for linux-2.4.19                                           
                                                                                                                                      
                                                                                                                                      
                                                                                                                                      



Marcelo,

Have you had a chance to include this?

Juan

----- Forwarded by Juan Gomez/Almaden/IBM on 10/15/02 09:11 AM -----
                                                                                                                                            
                      Juan Gomez                                                                                                            
                      <gomez@cs.sjsu.edu>            To:       marcelo@conectiva.com.br                                                     
                      Sent by:                       cc:       trond.myklebust@fys.uio.no, linux-kernel@vger.kernel.org                     
                      linux-kernel-owner@vger        Subject:  kNFS(lockd) patch for linux-2.4.19                                           
                      .kernel.org                                                                                                           
                                                                                                                                            
                                                                                                                                            
                      10/08/02 01:59 PM                                                                                                     
                                                                                                                                            
                                                                                                                                            




Marcelo,

Would you please consider the attached patch for inclusion in 2.4..*?
The patch solves a faulty delay observed by the first client that access
lockd just after the grace period.

Juan
diff -ru linux-2.4.19/fs/lockd/svc.c
linux-2.4.19-plus-delay-patch/fs/lockd/svc.c
--- linux-2.4.19/fs/lockd/svc.c            Sun Oct 21 10:32:33 2001
+++ linux-2.4.19-plus-delay-patch/fs/lockd/svc.c             Tue Oct  8
13:19:40 2002
@@ -144,8 +144,7 @@
                          */
                         if (!nlmsvc_grace_period) {
                                     timeout = nlmsvc_retry_blocked();
-                        } else if (time_before(grace_period_expire,
jiffies))
-                                    clear_grace_period();
+                        }

                         /*
                          * Find a socket with data available and call its
@@ -163,6 +162,22 @@

                         dprintk("lockd: request from %08x\n",

(unsigned)ntohl(rqstp->rq_addr.sin_addr.s_addr));
+                /*
+                 * We need to do the clear/grace period here and not
before
+                 * svc_recv() because svc_recv() may sleep longer than the

+                 * grace period and the first request may be falsely
processed
+                 * as if the server was in the grace period when it was
not
+                 * causing unnecessary delays for the first request
received.
+                 * Juan C. Gomez j_carlos_gome@yahoo.com
+                 */
+
+                if (nlmsvc_grace_period
+                    &&
+                    time_before(grace_period_expire, jiffies)) {
+                         clear_grace_period();
+                }
+
+

                         /*
                          * Look up the NFS client handle. The handle is
needed for

-
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/







-------------------------------------------------------
This sf.net email is sponsored by: viaVerio will pay you up to
$1,000 for every account that you consolidate with us.
http://ad.doubleclick.net/clk;4749864;7604308;v?
http://www.viaverio.com/consolidator/osdn.cfm
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
