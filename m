From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: [RFC Patch 01/09] NFS/RDMA client - RPC symbols
Date: Wed, 11 Jul 2007 17:07:19 -0400
Message-ID: <EXNANE01FRaqbC8wSA100000c60@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I8jQK-00021z-TB
	for nfs@lists.sourceforge.net; Wed, 11 Jul 2007 14:08:37 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I8jQO-0003fN-9l
	for nfs@lists.sourceforge.net; Wed, 11 Jul 2007 14:08:40 -0700
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com
	[10.57.156.158])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id
	l6BL8Yfk022058
	for <nfs@lists.sourceforge.net>; Wed, 11 Jul 2007 14:08:34 -0700 (PDT)
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

SUNRPC: add EXPORT_SYMBOL_GPL for generic transport functions

As a preface to allowing arbitrary transport modules to be loaded
dynamically, add EXPORT_SYMBOL_GPL for all generic transport functions that
a transport implementation might want to use.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/rpcb_clnt.c |    4 ++++
 net/sunrpc/sched.c     |    2 ++
 net/sunrpc/socklib.c   |    3 +++
 net/sunrpc/timer.c     |    4 ++++
 net/sunrpc/xprt.c      |   15 +++++++++++++++
 5 files changed, 28 insertions(+), 0 deletions(-)

Index: linux-2.6.22/net/sunrpc/sched.c
===================================================================
--- linux-2.6.22.orig/net/sunrpc/sched.c
+++ linux-2.6.22/net/sunrpc/sched.c
@@ -776,6 +776,7 @@ void *rpc_malloc(struct rpc_task *task, 
                        task->tk_pid, size, buf);
        return &buf->data;
 }
+EXPORT_SYMBOL_GPL(rpc_malloc);
 
 /**
  * rpc_free - free buffer allocated via rpc_malloc
@@ -801,6 +802,7 @@ void rpc_free(void *buffer)
        else
                kfree(buf);
 }
+EXPORT_SYMBOL_GPL(rpc_free);
 
 /*
  * Creation and deletion of RPC task structures
Index: linux-2.6.22/net/sunrpc/socklib.c
===================================================================
--- linux-2.6.22.orig/net/sunrpc/socklib.c
+++ linux-2.6.22/net/sunrpc/socklib.c
@@ -34,6 +34,7 @@ size_t xdr_skb_read_bits(struct xdr_skb_
        desc->offset += len;
        return len;
 }
+EXPORT_SYMBOL_GPL(xdr_skb_read_bits);
 
 /**
  * xdr_skb_read_and_csum_bits - copy and checksum from skb to buffer
@@ -137,6 +138,7 @@ copy_tail:
 out:
        return copied;
 }
+EXPORT_SYMBOL_GPL(xdr_partial_copy_from_skb);
 
 /**
  * csum_partial_copy_to_xdr - checksum and copy data
@@ -179,3 +181,4 @@ no_checksum:
                return -1;
        return 0;
 }
+EXPORT_SYMBOL_GPL(csum_partial_copy_to_xdr);
Index: linux-2.6.22/net/sunrpc/timer.c
===================================================================
--- linux-2.6.22.orig/net/sunrpc/timer.c
+++ linux-2.6.22/net/sunrpc/timer.c
@@ -17,6 +17,7 @@
 
 #include <linux/types.h>
 #include <linux/unistd.h>
+#include <linux/module.h>
 
 #include <linux/sunrpc/clnt.h>
 
@@ -40,6 +41,7 @@ rpc_init_rtt(struct rpc_rtt *rt, unsigne
                rt->ntimeouts[i] = 0;
        }
 }
+EXPORT_SYMBOL_GPL(rpc_init_rtt);
 
 /*
  * NB: When computing the smoothed RTT and standard deviation,
@@ -75,6 +77,7 @@ rpc_update_rtt(struct rpc_rtt *rt, unsig
        if (*sdrtt < RPC_RTO_MIN)
                *sdrtt = RPC_RTO_MIN;
 }
+EXPORT_SYMBOL_GPL(rpc_update_rtt);
 
 /*
  * Estimate rto for an nfs rpc sent via. an unreliable datagram.
@@ -103,3 +106,4 @@ rpc_calc_rto(struct rpc_rtt *rt, unsigne
 
        return res;
 }
+EXPORT_SYMBOL_GPL(rpc_calc_rto);
Index: linux-2.6.22/net/sunrpc/xprt.c
===================================================================
--- linux-2.6.22.orig/net/sunrpc/xprt.c
+++ linux-2.6.22/net/sunrpc/xprt.c
@@ -118,6 +118,7 @@ out_sleep:
                rpc_sleep_on(&xprt->sending, task, NULL, NULL);
        return 0;
 }
+EXPORT_SYMBOL_GPL(xprt_reserve_xprt);
 
 static void xprt_clear_locked(struct rpc_xprt *xprt)
 {
@@ -167,6 +168,7 @@ out_sleep:
                rpc_sleep_on(&xprt->sending, task, NULL, NULL);
        return 0;
 }
+EXPORT_SYMBOL_GPL(xprt_reserve_xprt_cong);
 
 static inline int xprt_lock_write(struct rpc_xprt *xprt, struct rpc_task *task)
 {
@@ -246,6 +248,7 @@ void xprt_release_xprt(struct rpc_xprt *
                __xprt_lock_write_next(xprt);
        }
 }
+EXPORT_SYMBOL_GPL(xprt_release_xprt);
 
 /**
  * xprt_release_xprt_cong - allow other requests to use a transport
@@ -262,6 +265,7 @@ void xprt_release_xprt_cong(struct rpc_x
                __xprt_lock_write_next_cong(xprt);
        }
 }
+EXPORT_SYMBOL_GPL(xprt_release_xprt_cong);
 
 static inline void xprt_release_write(struct rpc_xprt *xprt, struct rpc_task *task)
 {
@@ -314,6 +318,7 @@ void xprt_release_rqst_cong(struct rpc_t
 {
        __xprt_put_cong(task->tk_xprt, task->tk_rqstp);
 }
+EXPORT_SYMBOL_GPL(xprt_release_rqst_cong);
 
 /**
  * xprt_adjust_cwnd - adjust transport congestion window
@@ -345,6 +350,7 @@ void xprt_adjust_cwnd(struct rpc_task *t
        xprt->cwnd = cwnd;
        __xprt_put_cong(xprt, req);
 }
+EXPORT_SYMBOL_GPL(xprt_adjust_cwnd);
 
 /**
  * xprt_wake_pending_tasks - wake all tasks on a transport's pending queue
@@ -359,6 +365,7 @@ void xprt_wake_pending_tasks(struct rpc_
        else
                rpc_wake_up(&xprt->pending);
 }
+EXPORT_SYMBOL_GPL(xprt_wake_pending_tasks);
 
 /**
  * xprt_wait_for_buffer_space - wait for transport output buffer to clear
@@ -373,6 +380,7 @@ void xprt_wait_for_buffer_space(struct r
        task->tk_timeout = req->rq_timeout;
        rpc_sleep_on(&xprt->pending, task, NULL, NULL);
 }
+EXPORT_SYMBOL_GPL(xprt_wait_for_buffer_space);
 
 /**
  * xprt_write_space - wake the task waiting for transport output buffer space
@@ -393,6 +401,7 @@ void xprt_write_space(struct rpc_xprt *x
        }
        spin_unlock_bh(&xprt->transport_lock);
 }
+EXPORT_SYMBOL_GPL(xprt_write_space);
 
 /**
  * xprt_set_retrans_timeout_def - set a request's retransmit timeout
@@ -406,6 +415,7 @@ void xprt_set_retrans_timeout_def(struct
 {
        task->tk_timeout = task->tk_rqstp->rq_timeout;
 }
+EXPORT_SYMBOL_GPL(xprt_set_retrans_timeout_def);
 
 /*
  * xprt_set_retrans_timeout_rtt - set a request's retransmit timeout
@@ -425,6 +435,7 @@ void xprt_set_retrans_timeout_rtt(struct
        if (task->tk_timeout > max_timeout || task->tk_timeout == 0)
                task->tk_timeout = max_timeout;
 }
+EXPORT_SYMBOL_GPL(xprt_set_retrans_timeout_rtt);
 
 static void xprt_reset_majortimeo(struct rpc_rqst *req)
 {
@@ -500,6 +511,7 @@ void xprt_disconnect(struct rpc_xprt *xp
        xprt_wake_pending_tasks(xprt, -ENOTCONN);
        spin_unlock_bh(&xprt->transport_lock);
 }
+EXPORT_SYMBOL_GPL(xprt_disconnect);
 
 static void
 xprt_init_autodisconnect(unsigned long data)
@@ -610,6 +622,7 @@ struct rpc_rqst *xprt_lookup_rqst(struct
        xprt->stat.bad_xids++;
        return NULL;
 }
+EXPORT_SYMBOL_GPL(xprt_lookup_rqst);
 
 /**
  * xprt_update_rtt - update an RPC client's RTT state after receiving a reply
@@ -629,6 +642,7 @@ void xprt_update_rtt(struct rpc_task *ta
                rpc_set_timeo(rtt, timer, req->rq_ntrans - 1);
        }
 }
+EXPORT_SYMBOL_GPL(xprt_update_rtt);
 
 /**
  * xprt_complete_rqst - called when reply processing is complete
@@ -653,6 +667,7 @@ void xprt_complete_rqst(struct rpc_task 
        req->rq_received = req->rq_private_buf.len = copied;
        rpc_wake_up_task(task);
 }
+EXPORT_SYMBOL_GPL(xprt_complete_rqst);
 
 static void xprt_timer(struct rpc_task *task)
 {


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
