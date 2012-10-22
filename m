Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f174.google.com ([209.85.220.174]:51746 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756155Ab2JVU02 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Oct 2012 16:26:28 -0400
Received: by mail-vc0-f174.google.com with SMTP id fk26so3432215vcb.19
        for <linux-nfs@vger.kernel.org>; Mon, 22 Oct 2012 13:26:27 -0700 (PDT)
Date: Mon, 22 Oct 2012 16:26:11 -0400
From: Chris Perl <chris.perl@gmail.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: RPC Race Condition
Message-ID: <20121022202611.GA27191@nyc-qws-132.nyc.delacy.com>
References: <20121022180339.GC24763@nyc-qws-132.nyc.delacy.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA909289403@SACEXCMBX04-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA909289403@SACEXCMBX04-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 22, 2012 at 06:28:02PM +0000, Myklebust, Trond wrote:
> Hi Chris,
> 
> Thanks for helping to debug this, and for providing such a thorough
> analysis! This is great work!
> 
> Does adding a check in xs_error_report() for xprt_connecting(xprt) so
> that we skip the call to xprt_wake_pending_tasks() if true, help to
> resolve the race?

This is what I changed:

--- a/net/sunrpc/xprtsock.c     2012-08-14 08:47:16.000000000 -0400
+++ b/net/sunrpc/xprtsock.c     2012-10-22 14:50:09.237725498 -0400
@@ -1571,7 +1571,8 @@
        dprintk("RPC:       %s client %p...\n"
                        "RPC:       error %d\n",
                        __func__, xprt, sk->sk_err);
-       xprt_wake_pending_tasks(xprt, -EAGAIN);
+       if (!xprt_connecting(xprt))
+               xprt_wake_pending_tasks(xprt, -EAGAIN);
 out:
        read_unlock_bh(&sk->sk_callback_lock);
 }

Unfortunately it does not resolve it.  It appears that does stop the wakeup
from happening where I detailed it before, but we still wake up too early.  The
following is the call stack from SystemTap catching the call to `rpc_make_runnable':

 0xffffffffa0434840 : rpc_make_runnable+0x0/0x80 [sunrpc]
 0xffffffffa0434b5e : rpc_wake_up_task_queue_locked+0x18e/0x270 [sunrpc]
 0xffffffffa0434c8e : rpc_wake_up_status+0x4e/0x80 [sunrpc]
 0xffffffffa042d8ec : xprt_wake_pending_tasks+0x2c/0x30 [sunrpc]
 0xffffffffa042da56 : xprt_disconnect_done+0x46/0x70 [sunrpc]
 0xffffffffa04305b0 : xs_tcp_setup_socket+0x330/0x4c0 [sunrpc]
 0xffffffff8108c760 : worker_thread+0x170/0x2a0 [kernel]
 0xffffffff81091d66 : kthread+0x96/0xa0 [kernel]
 0xffffffff8100c14a : child_rip+0xa/0x20 [kernel]

However, its mildly confusing to me since I cannot follow that exact
call stack in the code.  The nearest I can find to that is the
following:

  rpc_make_runnable
  rpc_wake_up_task_queue_locked
  rpc_wake_up_status
  xprt_wake_pending_tasks
  xprt_disconnect_done
  xs_sock_mark_closed
  xs_abort_connection
  xs_tcp_reuse_connection
  xs_tcp_setup_socket

As far as I can tell, we get here because the call to `kernel_connect'
from within `xs_abort_connection' by rpciod is returning 0 sometimes
(and EINPROGRESS others).  When it returns 0, we enter this block:

  if (!result)
          xs_sock_mark_closed(&transport->xprt);
  else
    dprintk("RPC:       AF_UNSPEC connect return code %d\n", result);

and that eventually gets us woken up via the call stack above.  The end
result is the same, we wake up and move on to `call_transmit' before
rpciod is done connecting the socket.

I'll do some more tracing and see what else I can come up with.

Chris
