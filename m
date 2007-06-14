From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] Usermodehelper vs NFS Client Deadlock
Date: Thu, 14 Jun 2007 18:05:42 -0400
Message-ID: <1181858742.15174.6.camel@heimdal.trondhjem.org>
References: <200706141348.42119.behlendorf1@llnl.gov>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-yEFVkff1j2hy2YrhJKpH"
Cc: nfs@lists.sourceforge.net
To: behlendorf1@llnl.gov
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HyxRt-0006qX-2z
	for nfs@lists.sourceforge.net; Thu, 14 Jun 2007 15:05:49 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX19nC/BMzWZfVwW3K5ZTQVAgOJmMtw+KRIU=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HyxRv-0000ou-M1
	for nfs@lists.sourceforge.net; Thu, 14 Jun 2007 15:05:52 -0700
In-Reply-To: <200706141348.42119.behlendorf1@llnl.gov>
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


--=-yEFVkff1j2hy2YrhJKpH
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Thu, 2007-06-14 at 13:48 -0700, Brian Behlendorf wrote:
> Recently I've observed some interesting NFS client hangs here at LLNL.  I
> dug in to the issue and resolved it but I thought it was also a good idea
> to post the patch back upstream for further refinement and review.
> 
> The root cause of the NFS hang we were observing appears to be a rare
> deadlock between the kernel provided usermodehelper API and the linux NFS
> client.  The deadlock can arise because both of these services use the generic 
> linux work queues.  The usermodehelper API run the specified user application 
> in the context of the work queue.  And NFS submits both cleanup and reconnect 
> work to the generic work queue for handling.  Normally this is fine but a 
> deadlock can result in the following situation.
> 
>   - NFS client is in a disconnected state
>   - [events/0] runs a usermodehelper app with an NFS dependent operation,
>     this triggers an NFS reconnect.
>   - NFS reconnect happens to be submitted to [events/0] work queue.
>   - Deadlock, the [events/0] work queue will never process the reconnect
>     because it is blocked on the previous NFS dependent operation which 
>     will not complete.
> 
> The correct solution it seems to me is for NFS not to use the generic
> work queues.  A dedicated NFS work queue should be created because the NFS
> client will never have a guarantee that there are no NFS dependent 
> operations in the generic work queues.
> 
> The attached patch implements this by adding a per-protocol work queue
> for the NFS related work items.  One work queue for all NFS client work
> items would be better but that would have required a little more churn to
> the existing code base.  That said this patch is working well for us.

Why not just use rpciod? None of the tasks you are proposing to run are
blocking...

Cheers
  Trond


--=-yEFVkff1j2hy2YrhJKpH
Content-Disposition: inline; filename=fix_reconnect_deadlock.dif
Content-Type: text/plain; name=fix_reconnect_deadlock.dif; charset=utf-8
Content-Transfer-Encoding: 7bit

commit 2460343f7eed621bcb2ecbc0bf1f0df8eebb1cdb
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Jun 14 18:00:42 2007 -0400

    SUNRPC: fix hang due to eventd deadlock...
    
    Brian Behlendorf writes:
    
    The root cause of the NFS hang we were observing appears to be a rare
    deadlock between the kernel provided usermodehelper API and the linux NFS
    client.  The deadlock can arise because both of these services use the
    generic linux work queues.  The usermodehelper API run the specified user
    application in the context of the work queue.  And NFS submits both cleanup
    and reconnect work to the generic work queue for handling.  Normally this
    is fine but a deadlock can result in the following situation.
    
      - NFS client is in a disconnected state
      - [events/0] runs a usermodehelper app with an NFS dependent operation,
        this triggers an NFS reconnect.
      - NFS reconnect happens to be submitted to [events/0] work queue.
      - Deadlock, the [events/0] work queue will never process the
        reconnect because it is blocked on the previous NFS dependent
        operation which will not complete.`
    
    The solution is simply to run reconnect requests on rpciod.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 5b05b73..518acb7 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -127,7 +127,7 @@ static void xprt_clear_locked(struct rpc_xprt *xprt)
 		clear_bit(XPRT_LOCKED, &xprt->state);
 		smp_mb__after_clear_bit();
 	} else
-		schedule_work(&xprt->task_cleanup);
+		queue_work(rpciod_workqueue, &xprt->task_cleanup);
 }
 
 /*
@@ -515,7 +515,7 @@ xprt_init_autodisconnect(unsigned long data)
 	if (xprt_connecting(xprt))
 		xprt_release_write(xprt, NULL);
 	else
-		schedule_work(&xprt->task_cleanup);
+		queue_work(rpciod_workqueue, &xprt->task_cleanup);
 	return;
 out_abort:
 	spin_unlock(&xprt->transport_lock);
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index cc33c58..ee6ad3b 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -653,8 +653,7 @@ static void xs_destroy(struct rpc_xprt *xprt)
 
 	dprintk("RPC:       xs_destroy xprt %p\n", xprt);
 
-	cancel_delayed_work(&transport->connect_worker);
-	flush_scheduled_work();
+	cancel_rearming_delayed_work(&transport->connect_worker);
 
 	xprt_disconnect(xprt);
 	xs_close(xprt);
@@ -1001,7 +1000,7 @@ static void xs_tcp_state_change(struct sock *sk)
 		/* Try to schedule an autoclose RPC calls */
 		set_bit(XPRT_CLOSE_WAIT, &xprt->state);
 		if (test_and_set_bit(XPRT_LOCKED, &xprt->state) == 0)
-			schedule_work(&xprt->task_cleanup);
+			queue_work(rpciod_workqueue, &xprt->task_cleanup);
 	default:
 		xprt_disconnect(xprt);
 	}
@@ -1410,18 +1409,16 @@ static void xs_connect(struct rpc_task *task)
 		dprintk("RPC:       xs_connect delayed xprt %p for %lu "
 				"seconds\n",
 				xprt, xprt->reestablish_timeout / HZ);
-		schedule_delayed_work(&transport->connect_worker,
-					xprt->reestablish_timeout);
+		queue_delayed_work(rpciod_workqueue,
+				   &transport->connect_worker,
+				   xprt->reestablish_timeout);
 		xprt->reestablish_timeout <<= 1;
 		if (xprt->reestablish_timeout > XS_TCP_MAX_REEST_TO)
 			xprt->reestablish_timeout = XS_TCP_MAX_REEST_TO;
 	} else {
 		dprintk("RPC:       xs_connect scheduled xprt %p\n", xprt);
-		schedule_delayed_work(&transport->connect_worker, 0);
-
-		/* flush_scheduled_work can sleep... */
-		if (!RPC_IS_ASYNC(task))
-			flush_scheduled_work();
+		queue_delayed_work(rpciod_workqueue,
+				   &transport->connect_worker, 0);
 	}
 }
 

--=-yEFVkff1j2hy2YrhJKpH
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--=-yEFVkff1j2hy2YrhJKpH
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--=-yEFVkff1j2hy2YrhJKpH--
