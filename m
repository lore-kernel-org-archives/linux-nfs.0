From: Olaf Kirch <okir@suse.de>
Subject: Re: Bug in nfs client handling of EJUKEBOX
Date: Thu, 24 Feb 2005 12:55:31 +0100
Message-ID: <20050224115531.GF11336@suse.de>
References: <1109101592/oystr@hugh.cs.washington.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="a8Wt8u1KmwUX3Y2C"
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D4Hal-0002dL-BH
	for nfs@lists.sourceforge.net; Thu, 24 Feb 2005 03:55:39 -0800
Received: from news.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1D4Hah-0000rj-Tt
	for nfs@lists.sourceforge.net; Thu, 24 Feb 2005 03:55:38 -0800
To: Jan Sanislo <oystr@cs.washington.edu>
In-Reply-To: <1109101592/oystr@hugh.cs.washington.edu>
Sender: nfs-admin@lists.sourceforge.net
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


--a8Wt8u1KmwUX3Y2C
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

> If the tk_exit procedure (e.g., nfs_read_done) called at ">>>>" above
> detects EJUKEBOX as the result of the call, it will attempt to do
> an rpc_restart and rpc_delay on the task.  The rpc_delay will set a timer.
> However, when the main loop is re-entered via the "goto restarted",
> the first thing that happens is that all timers for the task are removed.
> This results in the RPC task hanging in an uninterruptible wait.
> 
> Am I missing something here or is this really a problem?

I think this is a genuine problem. Previously, we would clear the timers
only when the task was running, i.e. inside the if (RPC_RUNNING(task))
branch. Proposed patch attached.

Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax

--a8Wt8u1KmwUX3Y2C
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=sunrpc-restart-delay-fix

Index: linux-2.6.10/net/sunrpc/sched.c
===================================================================
--- linux-2.6.10.orig/net/sunrpc/sched.c
+++ linux-2.6.10/net/sunrpc/sched.c
@@ -569,7 +569,8 @@ static int __rpc_execute(struct rpc_task
 		/*
 		 * Garbage collection of pending timers...
 		 */
-		rpc_delete_timer(task);
+		if (RPC_IS_RUNNING(task))
+			rpc_delete_timer(task);
 
 		/*
 		 * Execute any pending callback.

--a8Wt8u1KmwUX3Y2C--


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
