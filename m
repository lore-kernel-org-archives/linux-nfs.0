From: Brian Behlendorf <behlendorf1@llnl.gov>
Subject: [PATCH] Usermodehelper vs NFS Client Deadlock
Date: Thu, 14 Jun 2007 13:48:41 -0700
Message-ID: <200706141348.42119.behlendorf1@llnl.gov>
Reply-To: behlendorf1@llnl.gov
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_qmacGjegK5Vt0Rw"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HywFK-0007zY-BE
	for nfs@lists.sourceforge.net; Thu, 14 Jun 2007 13:48:46 -0700
Received: from nspiron-2.llnl.gov ([128.115.41.82])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HywFM-0003lI-Uq
	for nfs@lists.sourceforge.net; Thu, 14 Jun 2007 13:48:49 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

--Boundary-00=_qmacGjegK5Vt0Rw
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


Recently I've observed some interesting NFS client hangs here at LLNL.  I
dug in to the issue and resolved it but I thought it was also a good idea
to post the patch back upstream for further refinement and review.

The root cause of the NFS hang we were observing appears to be a rare
deadlock between the kernel provided usermodehelper API and the linux NFS
client.  The deadlock can arise because both of these services use the generic 
linux work queues.  The usermodehelper API run the specified user application 
in the context of the work queue.  And NFS submits both cleanup and reconnect 
work to the generic work queue for handling.  Normally this is fine but a 
deadlock can result in the following situation.

  - NFS client is in a disconnected state
  - [events/0] runs a usermodehelper app with an NFS dependent operation,
    this triggers an NFS reconnect.
  - NFS reconnect happens to be submitted to [events/0] work queue.
  - Deadlock, the [events/0] work queue will never process the reconnect
    because it is blocked on the previous NFS dependent operation which 
    will not complete.

The correct solution it seems to me is for NFS not to use the generic
work queues.  A dedicated NFS work queue should be created because the NFS
client will never have a guarantee that there are no NFS dependent 
operations in the generic work queues.

The attached patch implements this by adding a per-protocol work queue
for the NFS related work items.  One work queue for all NFS client work
items would be better but that would have required a little more churn to
the existing code base.  That said this patch is working well for us.

Thanks,
Brian


--------- Stacks from deadlocked system ------------

PID: 12401  TASK: 10044576330       CPU: 2   COMMAND: "khelper"
 #0 [1009dd71548] schedule at ffffffff802f0cab
 #1 [1009dd71620] flush_cpu_workqueue at ffffffff80144329
 #2 [1009dd716c0] flush_workqueue at ffffffff801443c4
 #3 [1009dd716e0] __rpc_execute at ffffffffa0028ee7
 #4 [1009dd71770] rpc_call_sync at ffffffffa002479c
 #5 [1009dd717a0] nfs3_rpc_wrapper at ffffffffa0074c87
 #6 [1009dd717d0] nfs3_proc_getattr at ffffffffa0074edf
 #7 [1009dd71830] __nfs_revalidate_inode at ffffffffa006be91
 #8 [1009dd71940] nfs_lookup_revalidate at ffffffffa006764b
 #9 [1009dd71af0] do_lookup at ffffffff80184fd4
#10 [1009dd71b30] __link_path_walk at ffffffff8018556f
#11 [1009dd71bf0] link_path_walk at ffffffff80186270
#12 [1009dd71cd0] path_lookup at ffffffff801864c0
#13 [1009dd71d00] open_exec at ffffffff80181afa
#14 [1009dd71df0] do_execve at ffffffff80182e5f
#15 [1009dd71e30] sys_execve at ffffffff8010de46
#16 [1009dd71e60] execve at ffffffff8011004d
#17 [1009dd71f10] ____exec_usermodehelper at ffffffff80143994
#18 [1009dd71f40] ____call_usermodehelper at ffffffff801439d4
#19 [1009dd71f50] kernel_thread at ffffffff8010ffdf

PID: 12     TASK: 1012aa2a130       CPU: 2   COMMAND: "events/2"
 #0 [1012aa33b18] schedule at ffffffff802f0cab
 #1 [1012aa33bf0] wait_for_completion at ffffffff802f0eef
 #2 [1012aa33c70] call_usermodehelper at ffffffff80143b97
 #3 [1012aa33d50] libcfs_run_upcall at ffffffffa01d8726
 #4 [1012aa33d90] kpr_do_upcall at ffffffffa0206a5f
 #5 [1012aa33e70] worker_thread at ffffffff80144136
 #6 [1012aa33f20] kthread at ffffffff80147e5b
 #7 [1012aa33f50] kernel_thread at ffffffff8010ffdf

--Boundary-00=_qmacGjegK5Vt0Rw
Content-Type: text/x-diff;
  charset="us-ascii";
  name="nfs-workqueue.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="nfs-workqueue.patch"

Author: Brian Behlendorf <behlendorf1@llnl.gov>, LLNL
Date:   Mon Jun 14 2007

Create a per-protocol NFS work queue to ensure NFS work items
can not deadlock with NFS dependant operations in the generic 
workqueues.

Signed-off-by: Brian Behlendorf <behlendorf1@llnl.gov>

Index: linux+rhel4+chaos/include/linux/sunrpc/xprt.h
===================================================================
--- linux+rhel4+chaos.orig/include/linux/sunrpc/xprt.h
+++ linux+rhel4+chaos/include/linux/sunrpc/xprt.h
@@ -168,6 +168,12 @@ struct rpc_xprt {
 	unsigned long		tcp_copied,	/* copied to request */
 				tcp_flags;
 	/*
+	 * Dedicated workqueue for connect/cleanup to avoid deadlocking on
+	 * unrelated NFS dependant operations in the predefined workqueue
+	 */
+	struct workqueue_struct *wq;
+
+	/*
 	 * Connection of sockets
 	 */
 	struct work_struct	sock_connect;
Index: linux+rhel4+chaos/net/sunrpc/xprt.c
===================================================================
--- linux+rhel4+chaos.orig/net/sunrpc/xprt.c
+++ linux+rhel4+chaos/net/sunrpc/xprt.c
@@ -472,7 +472,7 @@ xprt_init_autodisconnect(unsigned long d

 	task->tk_timeout = RPC_CONNECT_TIMEOUT;
 	rpc_sleep_on(&xprt->pending, task, xprt_connect_status, NULL);
-	schedule_work(&xprt->task_cleanup);
+	queue_work(xprt->wq, &xprt->task_cleanup);
 	return;
 out_write:
 	xprt_release_write(xprt, task);
@@ -564,12 +564,12 @@ void xprt_connect(struct rpc_task *task)
 		 * 	 seconds
 		 */
 		if (xprt->sock != NULL)
-			schedule_delayed_work(&xprt->sock_connect,
+			queue_delayed_work(xprt->wq, &xprt->sock_connect,
 					RPC_REESTABLISH_TIMEOUT);
 		else {
-			schedule_work(&xprt->sock_connect);
+			queue_work(xprt->wq, &xprt->sock_connect);
 			if (!RPC_IS_ASYNC(task))
-				flush_scheduled_work();
+				flush_workqueue(xprt->wq);
 		}
 	}
 	return;
@@ -1478,6 +1478,13 @@ xprt_setup(int proto, struct sockaddr_in
 	}
 	memset(xprt->slot, 0, slot_table_size);
 
+	xprt->wq = create_singlethread_workqueue("rpc.xprt");
+	if (xprt->wq == NULL) {
+		kfree(xprt->slot);
+		kfree(xprt);
+		return ERR_PTR(-ENOMEM);
+	}
+
 	xprt->addr = *ap;
 	xprt->prot = proto;
 	xprt->stream = (proto == IPPROTO_TCP)? 1 : 0;
@@ -1673,7 +1680,7 @@ xprt_shutdown(struct rpc_xprt *xprt)
 
 	/* synchronously wait for connect worker to finish */
 	cancel_delayed_work(&xprt->sock_connect);
-	flush_scheduled_work();
+	flush_workqueue(xprt->wq);
 }
 
 /*
@@ -1696,6 +1703,7 @@ xprt_destroy(struct rpc_xprt *xprt)
 	xprt_shutdown(xprt);
 	xprt_disconnect(xprt);
 	xprt_close(xprt);
+	destroy_workqueue(xprt->wq);
 	kfree(xprt->slot);
 	kfree(xprt);
 

--Boundary-00=_qmacGjegK5Vt0Rw
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--Boundary-00=_qmacGjegK5Vt0Rw
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--Boundary-00=_qmacGjegK5Vt0Rw--
