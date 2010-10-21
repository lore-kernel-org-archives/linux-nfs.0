Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:54737 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756474Ab0JUNxg convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Oct 2010 09:53:36 -0400
Subject: Re: NFSv4 mounts take longer the fail from ENETUNREACH than NFSv3 mounts.
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20101021080956.65691ec0@barsoom.rdu.redhat.com>
Date: Thu, 21 Oct 2010 09:52:54 -0400
Cc: Neil Brown <neilb@suse.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <49BC2A20-E681-4BBF-87C4-466D0FE943B3@ORACLE.COM>
References: <20101020181701.232dbeea@notabene> <C56CFB9A-FCA4-41DA-971F-49B9C9EE7F03@oracle.com> <20101021082938.45e4c941@notabene> <20101021115622.4766887b@notabene> <20101021080956.65691ec0@barsoom.rdu.redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Oct 21, 2010, at 8:09 AM, Jeff Layton wrote:

> On Thu, 21 Oct 2010 11:56:22 +1100
> Neil Brown <neilb@suse.de> wrote:
> 
>> On Thu, 21 Oct 2010 08:29:38 +1100
>> Neil Brown <neilb@suse.de> wrote:
>> 
>>> On Wed, 20 Oct 2010 10:29:05 -0400
>>> Chuck Lever <chuck.lever@ORACLE.COM> wrote:
>>> 
>>>> 
>>>> On Oct 20, 2010, at 3:17 AM, Neil Brown wrote:
>>>> 
>>>>> 
>>>>> 
>>>>> If I don't have any network configured (except loop-back), and try an NFSv3
>>>>> mount, then it fails quickly:
>>>>> 
>>>>> 
>>>>> ....
>>>>> mount.nfs: portmap query failed: RPC: Remote system error - Network is unreachable
>>>>> mount.nfs: Network is unreachable
>>>>> 
>>>>> 
>>>>> If I try the same thing with a NFSv4 mount, it times out before it fails,
>>>>> making a much longer delay.
>>>>> 
>>>>> This is because mount.nfs doesn't do a portmap lookup but just leaves
>>>>> everything to the kernel.
>>>>> The kernel does an 'rpc_ping()' which sets RPC_TASK_SOFTCONN.
>>>>> So at least it doesn't retry after the timeout.  But given that we have a
>>>>> clear error, we shouldn't timeout at all.
>>>>> 
>>>>> Unfortunately I cannot see an easy way to fix this.
>>>>> 
>>>>> The place where ENETUNREACH is in xs_tcp_setup_socket.  The comment there
>>>>> says "Retry with the same socket after a delay".  The "delay" bit is correct,
>>>>> the "retry" isn't.
>>>>> 
>>>>> It would seem that we should just add a 'goto out' there if RPC_TASK_SOFTCONN
>>>>> was set.  However we cannot see the task at this point - in fact it seems
>>>>> that there could be a queue of tasks waiting on this connection.  I guess
>>>>> some could be soft, and some not. ???
>>>>> 
>>>>> So: An suggestions how to get a ENETUNREACH (or ECONNREFUSED or similar) to
>>>>> fail immediately when  RPC_TASK_SOFTCONN is set ???
>>>> 
>>>> ECONNREFUSED should already fail immediately in this case.  If it's not failing immediately, that's a bug.
>>>> 
>>>> I agree that ENETUNREACH seems appropriate for quick failure if RPC_TASK_SOFTCONN is set.  (I thought it already worked this way, but maybe I'm mistaken).
>>> 
>>> There is certainly code that seems to treat ENETUNREACH differently if
>>> RPC_TASK_SOFTCONN is set, but it doesn't seem to apply in the particular case
>>> I am testing.
>>> e.g. call_bind_status handles ENETUNREACH as a retry if not SOFTCONN and as a
>>> failure in the SOFTCONN case.  
>>> I guess NFSv4 doesn't hit this because the port is explicitly set to 2049 so
>>> it never does the rpcbind step.
>>> So maybe we need to handle ENETUNREACH in call_connect_status as well as
>>> call_bind_status ??
>>> 
>>> Maybe something like that ...  The placement of rpc_delay seems a little of
>>> to me, but follows call_bind_status, so it could be correct.
>>> 
>> 
>> I did a bit of testing of the patch that I sent and it isn't quite write -
>> the ENETUNREACH doesn't propagate all the way up to call_connect_status.
>> This patch fixes that.
>> 
>> With it, the rpc_ping fails nicely,  but when a reconnect is tried on an
>> already-mounted filesystem it doesn't fail but rather retries every 5 seconds.
>> This is what I wanted to happen.
>> 
>> However I'm not at all sure that "5 seconds" is correct.  I copied it from
>> call_bind_status, but it seems a bit short.  Maybe the number in
>> call_bind_status is a bit low???
>> 
>> Here is my current patch - which is more a starting point for discussion than
>> a concrete proposal.
>> 
>> Thanks,
>> NeilBrown
>> 
>> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
>> index fa55490..539885e 100644
>> --- a/net/sunrpc/clnt.c
>> +++ b/net/sunrpc/clnt.c
>> @@ -1245,6 +1245,12 @@ call_connect_status(struct rpc_task *task)
>> 	}
>> 
>> 	switch (status) {
>> +	case -ENETUNREACH:
>> +	case -ECONNRESET:
>> +	case -ECONNREFUSED:
>> +		if (!RPC_IS_SOFTCONN(task))
>> +			rpc_delay(task, 5*HZ);
>> +		/* fall through */
> 
> Maybe instead of the above, we should do something like:
> 
> 		if (RPC_IS_SOFTCONN(task)) {
> 			rpc_exit(task, status);
> 			return;
> 		}
> 
> ...IOW, if this is a SOFTCONN task, return connect errors immediately.
> If it's not a SOFTCONN task, treat it as we would a timeout?
> 
> That'll would probably fix the -ENETUNREACH case, but I'm not sure what
> to do about the cases that rely on xs_error_report. It seems a little
> suspicious that those errors all get turned into -EAGAIN.

I think the theory is that all of the transport connect problems should be handled by the lower layers (xprtsock and the kernel's socket code) during the call_transmit step.  If something needs to be retried (say, a connection attempt) then the lower layer returns EAGAIN and the finite state machine will retry.

One of the issues is how to deal with partially transmitted requests and GSS credentials.  Some cases you have to re-encode the request before transmitting again.  The finite state machine attempts to deal with that.


> 
>> 		/* if soft mounted, test if we've timed out */
>> 	case -ETIMEDOUT:
>> 		task->tk_action = call_timeout;
>> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
>> index 970fb00..27673d9 100644
>> --- a/net/sunrpc/xprt.c
>> +++ b/net/sunrpc/xprt.c
>> @@ -733,6 +733,10 @@ static void xprt_connect_status(struct rpc_task *task)
>> 	}
>> 
>> 	switch (task->tk_status) {
>> +	case -ENETUNREACH:
>> +	case -ECONNREFUSED:
>> +	case -ECONNRESET:
>> +		break;
>> 	case -EAGAIN:
>> 		dprintk("RPC: %5u xprt_connect_status: retrying\n", task->tk_pid);
>> 		break;
>> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
>> index fe9306b..0743994 100644
>> --- a/net/sunrpc/xprtsock.c
>> +++ b/net/sunrpc/xprtsock.c
>> @@ -1906,7 +1906,8 @@ static void xs_tcp_setup_socket(struct rpc_xprt *xprt,
>> 	case -ECONNREFUSED:
>> 	case -ECONNRESET:
>> 	case -ENETUNREACH:
>> -		/* retry with existing socket, after a delay */
>> +		/* allow upper layers to choose between failure and retry */
>> +		goto out;
>> 	case 0:
>> 	case -EINPROGRESS:
>> 	case -EALREADY:
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> 
> 
> 
> -- 
> Jeff Layton <jlayton@redhat.com>

-- 
chuck[dot]lever[at]oracle[dot]com




