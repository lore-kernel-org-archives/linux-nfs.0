From: Olaf Kirch <okir@suse.de>
Subject: File systems mounted "-o intr"
Date: Mon, 9 Feb 2004 16:34:18 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040209153418.GC19863@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="HcAYCG3uE/tztfnV"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-list1-b.sourceforge.net ([10.3.1.7] helo=sc8-sf-list1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AqLdv-0006rG-Uu
	for nfs@lists.sourceforge.net; Mon, 09 Feb 2004 16:20:47 -0800
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 4.30)
	id 1AqDQV-00059c-Ub
	for nfs@lists.sourceforge.net; Mon, 09 Feb 2004 07:34:23 -0800
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1AqDQV-0006y0-AA
	for nfs@lists.sourceforge.net; Mon, 09 Feb 2004 07:34:23 -0800
Received: from hermes.suse.de (Hermes.suse.de [195.135.221.8])
	(using TLSv1 with cipher EDH-RSA-DES-CBC3-SHA (168/168 bits))
	(No client certificate requested)
	by Cantor.suse.de (Postfix) with ESMTP id 80BF218A92D
	for <nfs@lists.sourceforge.net>; Mon,  9 Feb 2004 16:34:18 +0100 (CET)
To: nfs@lists.sourceforge.net
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


--HcAYCG3uE/tztfnV
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline

Hi,

I noticed that Ctrl-C'ing out of an application hanging on a dead
NFS server doesn't work properly, even if mounted with -o intr.
Rather than bailing out instantly, the program doesn't receive
the SIGINT until the next timeout is reached.

The attached patch should fix this. Please let me know what you
think.

Olaf
-- 
Olaf Kirch     |  Stop wasting entropy - start using predictable
okir@suse.de   |  tempfile names today!
---------------+ 

--HcAYCG3uE/tztfnV
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: attachment; filename=nfs-interruptible

--- linux-2.6.2/net/sunrpc/sched.c.orig	2004-02-06 23:11:55.000000000 +0100
+++ linux-2.6.2/net/sunrpc/sched.c	2004-02-06 23:19:59.000000000 +0100
@@ -554,21 +554,28 @@
 			if (current->pid == rpciod_pid)
 				printk(KERN_ERR "RPC: rpciod waiting on sync task!\n");
 
-			__wait_event(task->tk_wait, !RPC_IS_SLEEPING(task));
-			dprintk("RPC: %4d sync task resuming\n", task->tk_pid);
-
-			/*
-			 * When a sync task receives a signal, it exits with
-			 * -ERESTARTSYS. In order to catch any callbacks that
-			 * clean up after sleeping on some queue, we don't
-			 * break the loop here, but go around once more.
-			 */
-			if (task->tk_client->cl_intr && signalled()) {
-				dprintk("RPC: %4d got signal\n", task->tk_pid);
-				task->tk_flags |= RPC_TASK_KILLED;
-				rpc_exit(task, -ERESTARTSYS);
-				rpc_wake_up_task(task);
+			if (!task->tk_client->cl_intr) {
+				__wait_event(task->tk_wait, !RPC_IS_SLEEPING(task));
+			} else {
+				__wait_event_interruptible(task->tk_wait,
+					       	!RPC_IS_SLEEPING(task), status);
+
+				/*
+				 * When a sync task receives a signal, it exits with
+				 * -ERESTARTSYS. In order to catch any callbacks that
+				 * clean up after sleeping on some queue, we don't
+				 * break the outer loop here, but go around once more.
+				 */
+				if (status == -ERESTARTSYS) {
+					dprintk("RPC: %4d got signal\n", task->tk_pid);
+					task->tk_flags |= RPC_TASK_KILLED;
+					rpc_exit(task, -ERESTARTSYS);
+					rpc_wake_up_task(task);
+					break;
+				}
 			}
+
+			dprintk("RPC: %4d sync task resuming\n", task->tk_pid);
 		}
 	}
 

--HcAYCG3uE/tztfnV--


-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
