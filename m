Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:58590 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752809Ab0JTV3s (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Oct 2010 17:29:48 -0400
Date: Thu, 21 Oct 2010 08:29:38 +1100
From: Neil Brown <neilb@suse.de>
To: Chuck Lever <chuck.lever@ORACLE.COM>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: NFSv4 mounts take longer the fail from ENETUNREACH than NFSv3
 mounts.
Message-ID: <20101021082938.45e4c941@notabene>
In-Reply-To: <C56CFB9A-FCA4-41DA-971F-49B9C9EE7F03@oracle.com>
References: <20101020181701.232dbeea@notabene>
	<C56CFB9A-FCA4-41DA-971F-49B9C9EE7F03@oracle.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 20 Oct 2010 10:29:05 -0400
Chuck Lever <chuck.lever@ORACLE.COM> wrote:

> 
> On Oct 20, 2010, at 3:17 AM, Neil Brown wrote:
> 
> > 
> > 
> > If I don't have any network configured (except loop-back), and try an NFSv3
> > mount, then it fails quickly:
> > 
> > 
> > ....
> > mount.nfs: portmap query failed: RPC: Remote system error - Network is unreachable
> > mount.nfs: Network is unreachable
> > 
> > 
> > If I try the same thing with a NFSv4 mount, it times out before it fails,
> > making a much longer delay.
> > 
> > This is because mount.nfs doesn't do a portmap lookup but just leaves
> > everything to the kernel.
> > The kernel does an 'rpc_ping()' which sets RPC_TASK_SOFTCONN.
> > So at least it doesn't retry after the timeout.  But given that we have a
> > clear error, we shouldn't timeout at all.
> > 
> > Unfortunately I cannot see an easy way to fix this.
> > 
> > The place where ENETUNREACH is in xs_tcp_setup_socket.  The comment there
> > says "Retry with the same socket after a delay".  The "delay" bit is correct,
> > the "retry" isn't.
> > 
> > It would seem that we should just add a 'goto out' there if RPC_TASK_SOFTCONN
> > was set.  However we cannot see the task at this point - in fact it seems
> > that there could be a queue of tasks waiting on this connection.  I guess
> > some could be soft, and some not. ???
> > 
> > So: An suggestions how to get a ENETUNREACH (or ECONNREFUSED or similar) to
> > fail immediately when  RPC_TASK_SOFTCONN is set ???
> 
> ECONNREFUSED should already fail immediately in this case.  If it's not failing immediately, that's a bug.
> 
> I agree that ENETUNREACH seems appropriate for quick failure if RPC_TASK_SOFTCONN is set.  (I thought it already worked this way, but maybe I'm mistaken).

There is certainly code that seems to treat ENETUNREACH differently if
RPC_TASK_SOFTCONN is set, but it doesn't seem to apply in the particular case
I am testing.
e.g. call_bind_status handles ENETUNREACH as a retry if not SOFTCONN and as a
failure in the SOFTCONN case.  
I guess NFSv4 doesn't hit this because the port is explicitly set to 2049 so
it never does the rpcbind step.
So maybe we need to handle ENETUNREACH in call_connect_status as well as
call_bind_status ??

Maybe something like that ...  The placement of rpc_delay seems a little of
to me, but follows call_bind_status, so it could be correct.

??

I haven't thought how EHOSTUNREACH fits into this... presumably it should
fail-quickly when SOFTCONN (which Jeff suggests it does) and should retry for
not SOFTCONN (which I haven't checked).

NeilBrown


diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index fa55490..539885e 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1245,6 +1245,12 @@ call_connect_status(struct rpc_task *task)
        }
 
        switch (status) {
+       case -ENETUNREACH:
+       case -ECONNRESET:
+       case -ECONNREFUSED:
+               if (!RPC_IS_SOFTCONN(task))
+                       rpc_delay(task, 5*HZ);
+               /* fall through */
                /* if soft mounted, test if we've timed out */
        case -ETIMEDOUT:
                task->tk_action = call_timeout;
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index fe9306b..0743994 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1906,7 +1906,8 @@ static void xs_tcp_setup_socket(struct rpc_xprt *xprt,
        case -ECONNREFUSED:
        case -ECONNRESET:
        case -ENETUNREACH:
-               /* retry with existing socket, after a delay */
+               /* allow upper layers to choose between failure and retry */
+               goto out;
        case 0:
        case -EINPROGRESS:
        case -EALREADY:

