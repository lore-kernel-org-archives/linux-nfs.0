Return-Path: linux-nfs-owner@vger.kernel.org
Received: from peace.netnation.com ([204.174.223.2]:57086 "EHLO
	peace.netnation.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757707Ab2DYBQs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Apr 2012 21:16:48 -0400
Received: from sim by peace.netnation.com with local (Exim 4.72)
	(envelope-from <sim@netnation.com>)
	id 1SMqX6-0006Li-W8
	for linux-nfs@vger.kernel.org; Tue, 24 Apr 2012 17:56:36 -0700
Date: Tue, 24 Apr 2012 17:56:36 -0700
From: Simon Kirby <sim@hostway.ca>
To: linux-nfs@vger.kernel.org
Subject: [3.2.10] NFSv3 CLOSE_WAIT hang
Message-ID: <20120425005636.GB2082@hostway.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello!

I've reported this a few times now, but we still keep hitting the issue.
NFS clients in the cluster occasionally get stuck with the socket to one
of the NFS servers in CLOSE_WAIT state, and don't recover.

The NFS servers (knfsd) used to be running 2.6.30 since newer kernels hit
XFS bugs, but are all now finally running 3.2.10 or 3.2.16.

I've added some debugging printk()s and WARN()s to the kernel to try to
figure out what is going on. Without knowing much about how it's actually
expected to work :), these were mostly to figure out why the socket is
being closed. I added the following on top of with Trond's sunrpc
debugging patch:

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 1e3b42c..c850c76 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1462,12 +1462,16 @@ call_status(struct rpc_task *task)
 		rpc_delay(task, 3*HZ);
 	case -ETIMEDOUT:
 		task->tk_action = call_timeout;
+		printk("%s: RPC call timeout (%d), disconnecting\n",
+			clnt->cl_protname, -status);
 		if (task->tk_client->cl_discrtry)
 			xprt_conditional_disconnect(task->tk_xprt,
 					req->rq_connect_cookie);
 		break;
 	case -ECONNRESET:
 	case -ECONNREFUSED:
+		printk("%s: RPC connection reset (%d), rebinding\n",
+			clnt->cl_protname, -status);
 		rpc_force_rebind(clnt);
 		rpc_delay(task, 3*HZ);
 	case -EPIPE:
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index f1c57d4..9dc7870 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -633,7 +633,12 @@ void xprt_force_disconnect(struct rpc_xprt *xprt)
 {
 	/* Don't race with the test_bit() in xprt_clear_locked() */
 	spin_lock_bh(&xprt->transport_lock);
+#if 0
 	set_bit(XPRT_CLOSE_WAIT, &xprt->state);
+#else
+	if (test_and_set_bit(XPRT_CLOSE_WAIT, &xprt->state) == 0)
+		WARN(1, "xprt_force_disconnect(): setting XPRT_CLOSE_WAIT\n");
+#endif
 	/* Try to schedule an autoclose RPC call */
 	if (test_and_set_bit(XPRT_LOCKED, &xprt->state) == 0)
 		BUG_ON(!queue_work(rpciod_workqueue, &xprt->task_cleanup));
@@ -660,7 +665,12 @@ void xprt_conditional_disconnect(struct rpc_xprt *xprt, unsigned int cookie)
 		goto out;
 	if (test_bit(XPRT_CLOSING, &xprt->state) || !xprt_connected(xprt))
 		goto out;
+#if 0
 	set_bit(XPRT_CLOSE_WAIT, &xprt->state);
+#else
+	if (test_and_set_bit(XPRT_CLOSE_WAIT, &xprt->state) == 0)
+		WARN(1, "xprt_conditional_disconnect(): setting XPRT_CLOSE_WAIT\n");
+#endif
 	/* Try to schedule an autoclose RPC call */
 	if (test_and_set_bit(XPRT_LOCKED, &xprt->state) == 0)
 		BUG_ON(!queue_work(rpciod_workqueue, &xprt->task_cleanup));
@@ -706,8 +716,10 @@ void xprt_connect(struct rpc_task *task)
 	if (!xprt_lock_write(xprt, task))
 		return;
 
-	if (test_and_clear_bit(XPRT_CLOSE_WAIT, &xprt->state))
+	if (test_and_clear_bit(XPRT_CLOSE_WAIT, &xprt->state)) {
 		xprt->ops->close(xprt);
+		printk("RPC: xprt_connect: cleared XPRT_CLOSE_WAIT for xprt %p (pid %u)\n", xprt, task->tk_pid);
+	}
 
 	if (xprt_connected(xprt))
 		xprt_release_write(xprt, task);
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 55472c4..0ed3b99 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -772,6 +772,8 @@ static void xs_tcp_release_xprt(struct rpc_xprt *xprt, struct rpc_task *task)
 	if (req->rq_bytes_sent == req->rq_snd_buf.len)
 		goto out_release;
 	set_bit(XPRT_CLOSE_WAIT, &task->tk_xprt->state);
+	WARN(1, "xs_tcp_release_xprt(): setting XPRT_CLOSE_WAIT -- req->rq_bytes_sent=%u, req->rq_snd_buf.len=%u\n",
+		req->rq_bytes_sent, req->rq_snd_buf.len);
 out_release:
 	xprt_release_xprt(xprt, task);
 }
@@ -1517,6 +1519,11 @@ static void xs_tcp_state_change(struct sock *sk)
 		/* The server initiated a shutdown of the socket */
 		xprt_force_disconnect(xprt);
 		xprt->connect_cookie++;
+		printk("RPC: server initated shutdown -- state %x conn %d dead %d zapped %d sk_shutdown %d\n",
+			sk->sk_state, xprt_connected(xprt),
+			sock_flag(sk, SOCK_DEAD),
+			sock_flag(sk, SOCK_ZAPPED),
+			sk->sk_shutdown);
 	case TCP_CLOSING:
 		/*
 		 * If the server closed down the connection, make sure that
---

Mount options on the clients: rw,hard,intr,tcp,timeo=300,retrans=2,vers=3
...the timeout is primarily left over from an attempt to make HA
fail-over "reconnection" times faster, since with UDP it actually did
make a significant difference. Does this even matter with TCP sockets?

Here, we hit the CLOSE_WAIT state. There are a number of occasional
"RPC call timeout (110), disconnecting" in normal operation; I'm not sure
why this is.

[1119196.640017] nfs: RPC call timeout (110), disconnecting
[1119196.720026] nfs: RPC call timeout (110), disconnecting
[1119196.892021] nfs: RPC call timeout (110), disconnecting
[1119198.516022] nfs: RPC call timeout (110), disconnecting
[1119220.576025] nfs: RPC call timeout (110), disconnecting
[1119871.048040] nfs: RPC call timeout (110), disconnecting
[1120266.464021] nfs: RPC call timeout (110), disconnecting
[1120341.472021] nfs: RPC call timeout (110), disconnecting
[1122139.008022] nfs: RPC call timeout (110), disconnecting
[1122166.112043] nfs: RPC call timeout (110), disconnecting
[1122302.304037] nfs: RPC call timeout (110), disconnecting
[1122666.735765] ------------[ cut here ]------------
[1122666.735855] WARNING: at net/sunrpc/xprt.c:640 xprt_force_disconnect+0x4a/0xa0()
[1122666.735945] Hardware name: PowerEdge 1950
[1122666.736025] xprt_force_disconnect(): setting XPRT_CLOSE_WAIT
[1122666.736099] Modules linked in: ipmi_devintf ipmi_si ipmi_msghandler xt_recent nf_conntrack_ftp xt_state xt_owner nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 bnx2 serio_raw evdev
[1122666.736898] Pid: 18458, comm: httpd Tainted: G        W    3.2.10-hw+ #16
[1122666.736975] Call Trace:
[1122666.737043]  <IRQ>  [<ffffffff816b545a>] ? xprt_force_disconnect+0x4a/0xa0
[1122666.737176]  [<ffffffff8105dd60>] warn_slowpath_common+0x80/0xc0
[1122666.737252]  [<ffffffff8105de99>] warn_slowpath_fmt+0x69/0x70
[1122666.737335]  [<ffffffffa0055aff>] ? tcp_packet+0x7cf/0x10f0 [nf_conntrack]
[1122666.737414]  [<ffffffff81702c41>] ? _raw_spin_lock_bh+0x11/0x40
[1122666.737490]  [<ffffffff816b545a>] xprt_force_disconnect+0x4a/0xa0
[1122666.737566]  [<ffffffff816b87e8>] xs_tcp_state_change+0x78/0x320
[1122666.737643]  [<ffffffff81667f4b>] tcp_fin+0x17b/0x210
[1122666.737717]  [<ffffffff81668c52>] tcp_data_queue+0x4c2/0xe70
[1122666.737793]  [<ffffffff8166c389>] ? tcp_validate_incoming+0x109/0x340
[1122666.737869]  [<ffffffff8166c709>] tcp_rcv_established+0x149/0xb00
[1122666.737946]  [<ffffffff816751dc>] tcp_v4_do_rcv+0x15c/0x2e0
[1122666.738021]  [<ffffffff81649924>] ? nf_iterate+0x84/0xb0
[1122666.738096]  [<ffffffff816759af>] tcp_v4_rcv+0x64f/0x8b0
[1122666.738170]  [<ffffffff81649a9d>] ? nf_hook_slow+0x6d/0x130
[1122666.738246]  [<ffffffff816543b0>] ? ip_rcv+0x2f0/0x2f0
[1122666.738322]  [<ffffffff8165445a>] ip_local_deliver_finish+0xaa/0x1d0
[1122666.738399]  [<ffffffff8165460d>] ip_local_deliver+0x8d/0xa0
[1122666.738474]  [<ffffffff81653ef9>] ip_rcv_finish+0x169/0x330
[1122666.738549]  [<ffffffff8165433d>] ip_rcv+0x27d/0x2f0
[1122666.738625]  [<ffffffff816256e7>] __netif_receive_skb+0x437/0x490
[1122666.738701]  [<ffffffff81627568>] netif_receive_skb+0x78/0x80
[1122666.738778]  [<ffffffff813aa8dc>] ? is_swiotlb_buffer+0x3c/0x50
[1122666.738854]  [<ffffffff816276a0>] napi_skb_finish+0x50/0x70
[1122666.738929]  [<ffffffff81627ce5>] napi_gro_receive+0x105/0x140
[1122666.739008]  [<ffffffffa0029e7b>] bnx2_poll_work+0x60b/0x1550 [bnx2]
[1122666.739085]  [<ffffffff8105096d>] ? enqueue_task_fair+0x15d/0x540
[1122666.739163]  [<ffffffff8104825e>] ? cpu_smt_mask+0x1e/0x20
[1122666.739238]  [<ffffffff810475dd>] ? check_preempt_curr+0x7d/0xa0
[1122666.739315]  [<ffffffffa002aeec>] bnx2_poll+0x5c/0x230 [bnx2]
[1122666.739391]  [<ffffffff81627f0b>] net_rx_action+0x11b/0x2e0
[1122666.739467]  [<ffffffff81019276>] ? read_tsc+0x16/0x40
[1122666.739542]  [<ffffffff81064fa0>] __do_softirq+0xe0/0x1d0
[1122666.739619]  [<ffffffff8170c8ec>] call_softirq+0x1c/0x30
[1122666.739693]  [<ffffffff810142b5>] do_softirq+0x65/0xa0
[1122666.739767]  [<ffffffff81064cad>] irq_exit+0xad/0xe0
[1122666.739841]  [<ffffffff81013a94>] do_IRQ+0x64/0xe0
[1122666.739914]  [<ffffffff81702dee>] common_interrupt+0x6e/0x6e
[1122666.739988]  <EOI>  [<ffffffff8170a712>] ? system_call_fastpath+0x16/0x1b
[1122666.740127] ---[ end trace 18327738ff1711ee ]---
[1122666.740203] RPC: server initated shutdown -- state 8 conn 1 dead 0 zapped 1 sk_shutdown 1

No other messages after this -- we see the socket in CLOSE_WAIT:

Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name Timer
tcp        0      0 10.10.52.11:801         10.10.52.225:2049       CLOSE_WAIT  -                off (0.00/0/0)

Here's the dmesg after "rpcdebug -m rpc -c all": http://0x.ca/sim/ref/3.2.10/dmesg

Where should I go from here? Is it valid that some processes should get
stuck in uninterruptible sleep in this case? Is it valid that the server
should hang up at all?

Cheers,

Simon-
