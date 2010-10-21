Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:22197 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758430Ab0JUOLC convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Oct 2010 10:11:02 -0400
Subject: Re: NFSv4 mounts take longer the fail from ENETUNREACH than NFSv3 mounts.
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20101021115622.4766887b@notabene>
Date: Thu, 21 Oct 2010 10:10:24 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <4F99C48A-025F-4B43-B9C1-1C6EE23C1253@ORACLE.COM>
References: <20101020181701.232dbeea@notabene> <C56CFB9A-FCA4-41DA-971F-49B9C9EE7F03@oracle.com> <20101021082938.45e4c941@notabene> <20101021115622.4766887b@notabene>
To: Neil Brown <neilb@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Oct 20, 2010, at 8:56 PM, Neil Brown wrote:

> On Thu, 21 Oct 2010 08:29:38 +1100
> Neil Brown <neilb@suse.de> wrote:
> 
>> On Wed, 20 Oct 2010 10:29:05 -0400
>> Chuck Lever <chuck.lever@ORACLE.COM> wrote:
>> 
>>> 
>>> On Oct 20, 2010, at 3:17 AM, Neil Brown wrote:
>>> 
>>>> 
>>>> 
>>>> If I don't have any network configured (except loop-back), and try an NFSv3
>>>> mount, then it fails quickly:
>>>> 
>>>> 
>>>> ....
>>>> mount.nfs: portmap query failed: RPC: Remote system error - Network is unreachable
>>>> mount.nfs: Network is unreachable
>>>> 
>>>> 
>>>> If I try the same thing with a NFSv4 mount, it times out before it fails,
>>>> making a much longer delay.
>>>> 
>>>> This is because mount.nfs doesn't do a portmap lookup but just leaves
>>>> everything to the kernel.
>>>> The kernel does an 'rpc_ping()' which sets RPC_TASK_SOFTCONN.
>>>> So at least it doesn't retry after the timeout.  But given that we have a
>>>> clear error, we shouldn't timeout at all.
>>>> 
>>>> Unfortunately I cannot see an easy way to fix this.
>>>> 
>>>> The place where ENETUNREACH is in xs_tcp_setup_socket.  The comment there
>>>> says "Retry with the same socket after a delay".  The "delay" bit is correct,
>>>> the "retry" isn't.
>>>> 
>>>> It would seem that we should just add a 'goto out' there if RPC_TASK_SOFTCONN
>>>> was set.  However we cannot see the task at this point - in fact it seems
>>>> that there could be a queue of tasks waiting on this connection.  I guess
>>>> some could be soft, and some not. ???
>>>> 
>>>> So: An suggestions how to get a ENETUNREACH (or ECONNREFUSED or similar) to
>>>> fail immediately when  RPC_TASK_SOFTCONN is set ???
>>> 
>>> ECONNREFUSED should already fail immediately in this case.  If it's not failing immediately, that's a bug.
>>> 
>>> I agree that ENETUNREACH seems appropriate for quick failure if RPC_TASK_SOFTCONN is set.  (I thought it already worked this way, but maybe I'm mistaken).
>> 
>> There is certainly code that seems to treat ENETUNREACH differently if
>> RPC_TASK_SOFTCONN is set, but it doesn't seem to apply in the particular case
>> I am testing.
>> e.g. call_bind_status handles ENETUNREACH as a retry if not SOFTCONN and as a
>> failure in the SOFTCONN case.  
>> I guess NFSv4 doesn't hit this because the port is explicitly set to 2049 so
>> it never does the rpcbind step.
>> So maybe we need to handle ENETUNREACH in call_connect_status as well as
>> call_bind_status ??
>> 
>> Maybe something like that ...  The placement of rpc_delay seems a little of
>> to me, but follows call_bind_status, so it could be correct.
>> 
> 
> I did a bit of testing of the patch that I sent and it isn't quite write -
> the ENETUNREACH doesn't propagate all the way up to call_connect_status.
> This patch fixes that.
> 
> With it, the rpc_ping fails nicely,  but when a reconnect is tried on an
> already-mounted filesystem it doesn't fail but rather retries every 5 seconds.
> This is what I wanted to happen.
> 
> However I'm not at all sure that "5 seconds" is correct.  I copied it from
> call_bind_status, but it seems a bit short.  Maybe the number in
> call_bind_status is a bit low???

I think that number is arbitrary.  Five seconds might be too often to try on a server that is trying to come up, I agree.

> Here is my current patch - which is more a starting point for discussion than
> a concrete proposal.

Sure.

I'm sorry I can't be more helpful here, it's been a while.  An important thing to remember is that the call_bind step is different than the call_connect step: call_bind can actually perform a whole other RPC under the covers.  And: rpcbind doesn't do an initial NULL RPC, it just does the RPCBIND request.

So the three places where this SOFTCONN thingie seems to matter is a) during the initial RPC ping, b) during an rpcbind request, and c) when the server is probing the callback parameters the client gave it via SETCLIENTID.

We should be sure that all three places are working as expected; ie. the check-in criteria should include more than just "mount".

Also, TCP is not the only connection-oriented transport we support here, so we should be careful that we're not doing anything that will break RDMA.


> Thanks,
> NeilBrown
> 
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index fa55490..539885e 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -1245,6 +1245,12 @@ call_connect_status(struct rpc_task *task)
> 	}
> 
> 	switch (status) {
> +	case -ENETUNREACH:
> +	case -ECONNRESET:
> +	case -ECONNREFUSED:
> +		if (!RPC_IS_SOFTCONN(task))
> +			rpc_delay(task, 5*HZ);
> +		/* fall through */
> 		/* if soft mounted, test if we've timed out */
> 	case -ETIMEDOUT:
> 		task->tk_action = call_timeout;
> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> index 970fb00..27673d9 100644
> --- a/net/sunrpc/xprt.c
> +++ b/net/sunrpc/xprt.c
> @@ -733,6 +733,10 @@ static void xprt_connect_status(struct rpc_task *task)
> 	}
> 
> 	switch (task->tk_status) {
> +	case -ENETUNREACH:
> +	case -ECONNREFUSED:
> +	case -ECONNRESET:
> +		break;

I'm not sure why you are including ECONN* here (and above).  My impression was that case was working as expected.  Can you explain the (non-NETUNREACH) transport connection-related problem you see?

Theoretically, the architecture of the connection retry logic means that all three of these should be mapped to EAGAIN by the transports (xprtsock.c, in this specific case).

> 	case -EAGAIN:
> 		dprintk("RPC: %5u xprt_connect_status: retrying\n", task->tk_pid);
> 		break;
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index fe9306b..0743994 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -1906,7 +1906,8 @@ static void xs_tcp_setup_socket(struct rpc_xprt *xprt,
> 	case -ECONNREFUSED:
> 	case -ECONNRESET:
> 	case -ENETUNREACH:
> -		/* retry with existing socket, after a delay */
> +		/* allow upper layers to choose between failure and retry */
> +		goto out;
> 	case 0:
> 	case -EINPROGRESS:
> 	case -EALREADY:
> 

-- 
chuck[dot]lever[at]oracle[dot]com




