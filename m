From: Olaf Kirch <okir@suse.de>
Subject: Re: df hangs on down nfs server mounted with hard,intr, can't kill
Date: Wed, 10 Mar 2004 09:09:10 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040310080910.GA21031@suse.de>
References: <482A3FA0050D21419C269D13989C61130435DD25@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="9amGYk9869ThD9tj"
Cc: Wade Hampton <wade.hampton@nsc1.net>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B0yvW-0001vV-QJ
	for nfs@lists.sourceforge.net; Wed, 10 Mar 2004 00:18:54 -0800
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1B0yNe-0000pS-Bv
	for nfs@lists.sourceforge.net; Tue, 09 Mar 2004 23:43:54 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C61130435DD25@lavender-fe.eng.netapp.com>
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


--9amGYk9869ThD9tj
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline

On Tue, Mar 09, 2004 at 11:51:10AM -0800, Lever, Charles wrote:
> the fact that "intr" doesn't work as expected is a bug, and
> folks are attempting to address this at least partially in 2.6.

FWIW, attached you'll find the patch I'm currently using.
I thought I had posted it to this list already.

BTW what is the "right" way to get stuff like this into the mainline
kernel? Trond, are you collecting stuff and pushing it to Andrew, or
should I be sending patches to him directly?

Olaf
-- 
Olaf Kirch     |  Stop wasting entropy - start using predictable
okir@suse.de   |  tempfile names today!
---------------+ 

--9amGYk9869ThD9tj
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
 

--9amGYk9869ThD9tj--


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
