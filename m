From: Olaf Kirch <okir@suse.de>
Subject: [PATCH] prevent sunrpc deadlock with debug on
Date: Thu, 16 Dec 2004 17:57:14 +0100
Message-ID: <20041216165714.GB2077@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="wac7ysb48OaltWcw"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CeywI-0001tr-BI
	for nfs@lists.sourceforge.net; Thu, 16 Dec 2004 08:57:18 -0800
Received: from mail.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1CeywH-0000l1-8d
	for nfs@lists.sourceforge.net; Thu, 16 Dec 2004 08:57:17 -0800
Received: from hermes.suse.de (hermes-ext.suse.de [195.135.221.8])
	(using TLSv1 with cipher EDH-RSA-DES-CBC3-SHA (168/168 bits))
	(No client certificate requested)
	by Cantor.suse.de (Postfix) with ESMTP id 4381E12285C6
	for <nfs@lists.sourceforge.net>; Thu, 16 Dec 2004 17:57:14 +0100 (CET)
To: nfs@lists.sourceforge.net
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


--wac7ysb48OaltWcw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Here's a patch we added to our kernel a while ago, but which
I forgot to submit... here it is.

Olaf
-- 
Olaf Kirch     | Things that make Monday morning interesting, #2:
okir@suse.de   |        "We have 8,000 NFS mount points, why do we keep
---------------+ 	 running out of privileged ports?"

--wac7ysb48OaltWcw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=sunrpc-sched-deadlock

From: Shirly Ma <xma@us.ibm.com>
Subject: Prevent sunrpc deadlock with debugging turned on
References: 38960

This patch fixes a deadlock in the RPC code when debugging is enabled.

CPU 1:
	rpc_wake_up_task
		spin_lock_bh(&rpc_queue_lock);
		-> __rpc_wake_up_task
			-> rpc_show_tasks
				-> spin_lock(&rpc_sched_lock);

CPU 2:
	rpc_killall_tasks
		spin_lock(&rpc_sched_lock);
		-> rpc_wake_up_task()
			spin_lock_bh(&rpc_queue_lock);

This is a very rare condition, but it was actually observed several times
during test runs on ppc64.

Signed-off-by: Olaf Kirch <okir@suse.de>

diff -urN linux-2.6.5-7.13/net/sunrpc/sched.c linux-2.6.5-7.13p/net/sunrpc/sched.c
--- linux-2.6.5-7.13/net/sunrpc/sched.c	2004-04-30 10:46:58.000000000 -0500
+++ linux-2.6.5-7.13p/net/sunrpc/sched.c	2004-04-30 17:21:05.000000000 -0500
@@ -931,12 +931,16 @@
 	/*
 	 * Spin lock all_tasks to prevent changes...
 	 */
+again:
 	spin_lock(&rpc_sched_lock);
 	alltask_for_each(rovr, le, &all_tasks)
-		if (!clnt || rovr->tk_client == clnt) {
+		if (!(rovr->tk_flags & RPC_TASK_KILLED) && 
+		    (!clnt || rovr->tk_client == clnt)) {
 			rovr->tk_flags |= RPC_TASK_KILLED;
 			rpc_exit(rovr, -EIO);
+			spin_unlock(&rpc_sched_lock);
 			rpc_wake_up_task(rovr);
+			goto again;
 		}
 	spin_unlock(&rpc_sched_lock);
 }

--wac7ysb48OaltWcw--


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
