From: Bruce Allan <bwa@us.ibm.com>
Subject: patch to fix oops when rpc_debug enabled
Date: 04 Apr 2003 08:01:03 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1049472064.1308.9.camel@w-bwa1.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: bwa@us.ibm.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from e33.co.us.ibm.com ([32.97.110.131])
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 191Tcx-0001Df-00
	for <nfs@lists.sourceforge.net>; Fri, 04 Apr 2003 08:01:15 -0800
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e33.co.us.ibm.com (8.12.9/8.12.2) with ESMTP id h34G14Eu136860
	for <nfs@lists.sourceforge.net>; Fri, 4 Apr 2003 11:01:04 -0500
To: nfs@lists.sourceforge.net
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

Discovered a couple different intermittent oops'es after enabling
rpc_debug.  The patch below is against 2.5.66.

--- linux-2.5.66/net/sunrpc/sched.c	2003-03-24 14:00:44.000000000 -0800
+++ linux-2.5.66-rpc_debug/net/sunrpc/sched.c	2003-04-04 07:48:17.000000000 -0800
@@ -1115,9 +1115,10 @@
 		"-rpcwait -action- --exit--\n");
 	alltask_for_each(t, le, &all_tasks)
 		printk("%05d %04d %04x %06d %8p %6d %8p %08ld %8s %8p %8p\n",
-			t->tk_pid, t->tk_msg.rpc_proc->p_proc,
+			t->tk_pid,
+			t->tk_msg.rpc_proc ? t->tk_msg.rpc_proc->p_proc : 0,
 			t->tk_flags, t->tk_status,
-			t->tk_client, t->tk_client->cl_prog,
+			t->tk_client, t->tk_client ? t->tk_client->cl_prog : 0,
 			t->tk_rqstp, t->tk_timeout,
 			t->tk_rpcwait ? rpc_qname(t->tk_rpcwait) : " <NULL> ",
 			t->tk_action, t->tk_exit);

-- 
Bruce Allan
Linux Technology Center
IBM Corporation, Beaverton OR



-------------------------------------------------------
This SF.net email is sponsored by: ValueWeb: 
Dedicated Hosting for just $79/mo with 500 GB of bandwidth! 
No other company gives more support or power for your dedicated server
http://click.atdmt.com/AFF/go/sdnxxaff00300020aff/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
