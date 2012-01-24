Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:24984 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754965Ab2AXNeN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Jan 2012 08:34:13 -0500
Message-ID: <4F1EB353.1060205@RedHat.com>
Date: Tue, 24 Jan 2012 08:34:11 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] SUNRPC: Adding status trace points
References: <1327348480-32549-1-git-send-email-steved@redhat.com>	 <1327348480-32549-2-git-send-email-steved@redhat.com> <1327354611.2628.20.camel@lade.trondhjem.org>
In-Reply-To: <1327354611.2628.20.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey,

On 01/23/2012 04:36 PM, Trond Myklebust wrote:
> On Mon, 2012-01-23 at 14:54 -0500, Steve Dickson wrote: 
>> This patch adds three trace points to the status routines
>> in the sunrpc state machine.
>>
>> Signed-off-by: Steve Dickson <steved@redhat.com>
>> ---
>>  include/trace/events/sunrpc.h |   45 +++++++++++++++++++++++++++++++++++++++++
>>  net/sunrpc/clnt.c             |    4 +++
>>  2 files changed, 49 insertions(+), 0 deletions(-)
>>
>> diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
>> index 1852f11..bca5ad3 100644
>> --- a/include/trace/events/sunrpc.h
>> +++ b/include/trace/events/sunrpc.h
>> @@ -8,6 +8,51 @@
>>  #include <linux/sunrpc/clnt.h>
>>  #include <linux/tracepoint.h>
>>  
>> +DECLARE_EVENT_CLASS(rpc_task_status,
>> +
>> +	TP_PROTO(struct rpc_task *task),
>> +
>> +	TP_ARGS(task),
>> +
>> +	TP_STRUCT__entry(
>> +		__field(int, status)
>> +	),
>> +
>> +	TP_fast_assign(
>> +		__entry->status = task->tk_status;
>> +	),
>> +
>> +	TP_printk("status %d", __entry->status)
>> +);
> 
> How do you tell which RPC task this refers to in the output? 
>From the task pointer I send up to the prob. Once I have that
pointer I can grab any field out it. An example:

probe kernel.trace("rpc_call_status")
{
    terror = task_status($task);
    if (terror)
        printf("%s[%d]:call_status:%s:%s: error %d (%s)\n", 
            execname(), pid(), cl_server($task), cl_prog($task), 
            terror, errno_str(terror));
}
The home grown routine task_status($task) pulls the status out task 
structure. If there is status I will get the following output:
    mount.nfs[13368]:call_status:vf16:nfs[4]:0: error -32 (EPIPE)

The built in routine execname() and pid() supply the process name
and pid. The home grown routines, cl_server($task) and cl_prog($task)
pull out the server, protocol, and version from the task. Finally
the built in routine errno_str() is used for the errno to string 
conversion. 


> Shouldn't we rather make the above
> 
> 	TP_printk("task:%p@%p, status %d", __entry->task, __entry->clnt, __entry->status)
> 
> so that it matches the format in the previous tracepoint patch?
Sure if you want to standardizer on that type of format thats 
fine with me... but, as you do in your trace points, we should also
make the clnt point available to the prob by making it part of the
TP_ARGS(). The more data we can look at the better..

Question about TP_printk() statements? How do you uses them? Meaning
how get them to print? I've never needed or used them since I
always used probs to grab that type of info.

> 
> Also, why are you adding tracepoints for specific states in
> net/sunrpc/clnt.c? 
I was just looking for status not state. Basically to see if there is
an problem at all... 

> Is the intention to allow the user to target specific
> bugs that might be harder to spot in the output from
> trace_rpc_task_run_action()?
These were architected explicitly show if a bind was failing and why
or if a connection was failing and why. A much higher level (and 
simpler) than the info trace_rpc_task_run_action supplies.
They are more directed at admin types verses developer types.

(Note, these trace points are currently in RHEL and we have found 
them somewhat useful)

steved.
