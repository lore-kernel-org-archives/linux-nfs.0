From: Chuck Lever <cel@citi.umich.edu>
Subject: [PATCH] prevent oops in xprt_lock_write, against 2.5.32
Date: Fri, 30 Aug 2002 14:13:47 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <41846.5290488259$1030731516@news.gmane.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   Linux NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from dexter.citi.umich.edu ([141.211.133.33])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17kqHK-0002qi-00
	for <nfs@lists.sourceforge.net>; Fri, 30 Aug 2002 11:13:54 -0700
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

hi linus-

when several RPC requests want to reconnect a TCP transport socket at
once, xprt_lock_write serializes the tasks to prevent multiple socket
connects.  however, TCP connects are always done by a RPC child task that
has no request slot.  xprt_lock_write can oops if there is no request slot
allocated to the invoking RPC task.  reviewed and accepted by Trond.

the xprt_lock_write changes are not yet in 2.4, so this patch does not 
apply to 2.4.

diff -drN -U2 00-stock/net/sunrpc/xprt.c 01-lock_write/net/sunrpc/xprt.c
--- 00-stock/net/sunrpc/xprt.c	Tue Aug 27 15:26:35 2002
+++ 01-lock_write/net/sunrpc/xprt.c	Thu Aug 29 10:10:00 2002
@@ -148,5 +148,5 @@
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
