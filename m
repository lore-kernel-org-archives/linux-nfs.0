From: Chuck Lever <cel@citi.umich.edu>
Subject: [PATCH] prevent oops in xprt_lock_write, against 2.4.20
Date: Fri, 30 Aug 2002 18:22:31 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0208301817150.1653-100000@dexter.citi.umich.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   Linux NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from dexter.citi.umich.edu ([141.211.133.33])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17kuA7-000199-00
	for <nfs@lists.sourceforge.net>; Fri, 30 Aug 2002 15:22:43 -0700
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

hi marcelo-

when several RPC requests want to reconnect a TCP transport socket at
once, xprt_lock_write serializes the tasks to prevent multiple socket
connects.  however, TCP connects are always done by a RPC child task that
has no request slot.  xprt_lock_write can oops if there is no request slot
allocated to the invoking RPC task.  reviewed and accepted by Trond.

i had thought the 2.5.32 patch wouldn't apply to 2.4.20, but Trond pointed
out to me that his xprt_lock_write patches snuck into 2.4.20-pre5, which i
hadn't noticed.


--- 2.4.20-pre5/net/sunrpc/xprt.c.orig	Fri Aug 30 15:49:28 2002
+++ 2.4.20-pre5/net/sunrpc/xprt.c	Fri Aug 30 18:16:17 2002
@@ -147,5 +147,5 @@
 		task->tk_timeout = 0;
 		task->tk_status = -EAGAIN;
-		if (task->tk_rqstp->rq_nresend)
+		if (task->tk_rqstp && task->tk_rqstp->rq_nresend)
 			rpc_sleep_on(&xprt->resend, task, NULL, NULL);
 		else

-- 

corporate:	<cel at netapp dot com>
personal:	<chucklever at bigfoot dot com>




-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
