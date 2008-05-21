From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 6/6] SUNRPC: Display some debugging information as text rather than numbers
Date: Wed, 21 May 2008 16:37:23 -0400
Message-ID: <0276F8AD-8401-4991-803F-581E37223397@oracle.com>
References: <20080521180231.3295.84997.stgit@ellison> <20080521181620.3295.2298.stgit@ellison> <20080521195041.GC6712@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=WINDOWS-1252;
	format=flowed	delsp=yes
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:33561 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937494AbYEUUiw convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 May 2008 16:38:52 -0400
In-Reply-To: <20080521195041.GC6712@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 21, 2008, at 3:50 PM, J. Bruce Fields wrote:

> On Wed, May 21, 2008 at 02:16:20PM -0400, Chuck Lever wrote:
>> In rpc_show_tasks(), display the program name, version number, =20
>> procedure
>> name and tk_action as human-readable variable-length text fields =20
>> rather
>> than columnar numbers.
>>
>> Doing the symbol lookup here helps in cases where we have actual
>> debugging output from a kernel log, but don't have access to the =20
>> kernel
>> image or RPC module that generated the output.
>>
>> Sample output:
>>
>> -pid- flgs status -client- --rqstp- -timeout ---ops--
>>  5608 0001    -11 eeb42690 f6d93710        0 f8fa1764 nfsv3 WRITE =20
>> a:call_transmit_status q:none
>>  5609 0001    -11 eeb42690 f6d937e0        0 f8fa1764 nfsv3 WRITE =20
>> a:call_status q:xprt_sending
>>  5610 0001    -11 eeb42690 f6d93230        0 f8fa1764 nfsv3 WRITE =20
>> a:call_status q:xprt_sending
>>  5611 0001    -11 eeb42690 f6d93300        0 f8fa1764 nfsv3 WRITE =20
>> a:call_status q:xprt_sending
>>  5612 0001    -11 eeb42690 f6d93090        0 f8fa1764 nfsv3 WRITE =20
>> a:call_status q:xprt_sending
>>  5613 0001    -11 eeb42690 f6d933d0        0 f8fa1764 nfsv3 WRITE =20
>> a:call_status q:xprt_sending
>>  5614 0001    -11 eeb42690 f6d93cc0        0 f8fa1764 nfsv3 WRITE =20
>> a:call_status q:xprt_sending
>>  5615 0001    -11 eeb42690 f6d93a50        0 f8fa1764 nfsv3 WRITE =20
>> a:call_status q:xprt_sending
>>  5616 0001    -11 eeb42690 f6d93640        0 f8fa1764 nfsv3 WRITE =20
>> a:call_status q:xprt_sending
>>  5617 0001    -11 eeb42690 f6d93b20        0 f8fa1764 nfsv3 WRITE =20
>> a:call_status q:xprt_sending
>>  5618 0001    -11 eeb42690 f6d93160        0 f8fa1764 nfsv3 WRITE =20
>> a:call_status q:xprt_sending
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>
>> net/sunrpc/clnt.c |   29 ++++++++++++++++-------------
>> 1 files changed, 16 insertions(+), 13 deletions(-)
>>
>>
>> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
>> index 68b08d4..878752c 100644
>> --- a/net/sunrpc/clnt.c
>> +++ b/net/sunrpc/clnt.c
>> @@ -25,6 +25,7 @@
>>
>> #include <linux/module.h>
>> #include <linux/types.h>
>> +#include <linux/kallsyms.h>
>> #include <linux/mm.h>
>> #include <linux/slab.h>
>> #include <linux/smp_lock.h>
>> @@ -1527,29 +1528,31 @@ EXPORT_SYMBOL_GPL(rpc_call_null);
>> #ifdef RPC_DEBUG
>> static void rpc_show_header(void)
>> {
>> -	printk(KERN_INFO "-pid- proc flgs status -client- -prog- --rqstp- =
"
>> -		"-timeout -rpcwait -action- ---ops--\n");
>> +	printk(KERN_INFO "-pid- flgs status -client- --rqstp- "
>> +		"-timeout ---ops--\n");
>> }
>>
>> static void rpc_show_task(const struct rpc_clnt *clnt,
>> 			  const struct rpc_task *task)
>> {
>> 	const char *rpc_waitq =3D "none";
>> -	int proc =3D -1;
>> -
>> -	if (task->tk_msg.rpc_proc)
>> -		proc =3D task->tk_msg.rpc_proc->p_proc;
>> +	char *p, action[KSYM_SYMBOL_LEN];
>>
>> 	if (RPC_IS_QUEUED(task))
>> 		rpc_waitq =3D rpc_qname(task->tk_waitqueue);
>>
>> -	printk(KERN_INFO "%5u %04d %04x %6d %8p %6d %8p %8ld %8s %8p %8p=20
>> \n",
>> -		task->tk_pid, proc,
>> -		task->tk_flags, task->tk_status,
>> -		clnt, clnt->cl_prog,
>> -		task->tk_rqstp, task->tk_timeout,
>> -		rpc_waitq,
>> -		task->tk_action, task->tk_ops);
>> +	/* map tk_action pointer to a function name; then trim off
>> +	 * the "+0x0 [sunrpc]" */
>> +	sprint_symbol(action, (unsigned long)task->tk_action);
>> +	p =3D strchr(action, '+');
>> +	if (p)
>> +		*p =3D '\0';
>> +
>> +	printk(KERN_INFO "%5u %04x %6d %8p %8p %8ld %8p %sv%u %s a:%s q:%s=
=20
>> \n",
>> +		task->tk_pid, task->tk_flags, task->tk_status,
>> +		clnt, task->tk_rqstp, task->tk_timeout, task->tk_ops,
>> +		clnt->cl_protname, clnt->cl_vers, rpc_proc_name(task),
>> +		action, queue);
>
> "net/sunrpc/clnt.c: In function =91rpc_show_task=92:
> net/sunrpc/clnt.c:1555: error: =91queue=92 undeclared (first use in t=
his =20
> function)
> net/sunrpc/clnt.c:1555: error: (Each undeclared identifier is =20
> reported only once
> net/sunrpc/clnt.c:1555: error: for each function it appears in.)"
>
> Is that last "queue" supposed to be "rpc_waitq"???

Yes... I fixed that already... was that in the version I sent out this =
=20
afternoon?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com