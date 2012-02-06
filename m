Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:10746 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755468Ab2BFTRr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Feb 2012 14:17:47 -0500
Message-ID: <4F300E1D.6050104@RedHat.com>
Date: Mon, 06 Feb 2012 12:30:05 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 2/2] SUNRPC: Adding status trace points
References: <1328540888-30109-1-git-send-email-steved@redhat.com>	 <1328540888-30109-3-git-send-email-steved@redhat.com> <1328542771.5687.1.camel@lade.trondhjem.org>
In-Reply-To: <1328542771.5687.1.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/06/2012 10:39 AM, Myklebust, Trond wrote:
> On Mon, 2012-02-06 at 10:08 -0500, Steve Dickson wrote:
>> This patch adds three trace points to the status routines
>> in the sunrpc state machine.
>>
>> The goal of these trace points is to give an Admin
>> the ability to check on binding status or connection
>> status to see if there is a potential problem.
>>
>> Signed-off-by: Steve Dickson <steved@redhat.com>
>> ---
>>  include/trace/events/sunrpc.h |   53 +++++++++++++++++++++++++++++++++++++++++
>>  net/sunrpc/clnt.c             |    6 ++++-
>>  2 files changed, 58 insertions(+), 1 deletions(-)
>>
>> diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
>> index 2f82de9..abcf45d 100644
>> --- a/include/trace/events/sunrpc.h
>> +++ b/include/trace/events/sunrpc.h
>> @@ -8,6 +8,59 @@
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
>> +		__field(const struct rpc_task *, task)
>> +		__field(const struct rpc_clnt *, clnt)
>> +		__field(int, status)
>> +	),
>> +
>> +	TP_fast_assign(
>> +		__entry->task = task;
>> +		__entry->clnt = task->tk_client;
>> +		__entry->status = task->tk_status;
>> +	),
>> +
>> +	TP_printk("task:%p@%p, status %d",__entry->task, __entry->clnt, __entry->status)
>> +);
>> +
>> +DEFINE_EVENT(rpc_task_status, rpc_call_status,
>> +	TP_PROTO(struct rpc_task *task), 
>> +
>> +	TP_ARGS(task)
>> +);
>> +
>> +DEFINE_EVENT(rpc_task_status, rpc_bind_status,
>> +	TP_PROTO(struct rpc_task *task), 
>> +
>> +	TP_ARGS(task)
>> +);
>> +
>> +TRACE_EVENT(rpc_connect_status,
>> +	TP_PROTO(struct rpc_task *task, int status),
>> +
>> +	TP_ARGS(task, status),
>> +
>> +	TP_STRUCT__entry(
>> +		__field(const struct rpc_task *, task)
>> +		__field(const struct rpc_clnt *, clnt)
>> +		__field(int, status)
>> +	),
>> +
>> +	TP_fast_assign(
>> +		__entry->task = task;
>> +		__entry->clnt = task->tk_client;
>> +		__entry->status = status;
>> +	),
>> +
>> +	TP_printk("task:%p@%p, status %d",__entry->task, __entry->clnt, __entry->status)
>> +);
>> +
>>  DECLARE_EVENT_CLASS(rpc_task_running,
>>  
> 
> 
> This hunk did contain a couple of trailing whitespace errors, but I've
> fixed them up and applied.
Hmm... Sorry about... I wonder how that happen... any ways thanks!

steved.
