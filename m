Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:56194 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753916Ab2AWUtp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Jan 2012 15:49:45 -0500
Message-ID: <4F1DC7E6.4010200@RedHat.com>
Date: Mon, 23 Jan 2012 15:49:42 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] SUNRPC: Adding status trace points
References: <1327348480-32549-1-git-send-email-steved@redhat.com> <1327348480-32549-2-git-send-email-steved@redhat.com> <383508F5-8A0B-4EBE-B81B-6A75887CD156@oracle.com>
In-Reply-To: <383508F5-8A0B-4EBE-B81B-6A75887CD156@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/23/2012 03:02 PM, Chuck Lever wrote:
> 
> On Jan 23, 2012, at 2:54 PM, Steve Dickson wrote:
> 
>> This patch adds three trace points to the status routines
>> in the sunrpc state machine.
>>
>> Signed-off-by: Steve Dickson <steved@redhat.com>
>> ---
>> include/trace/events/sunrpc.h |   45 +++++++++++++++++++++++++++++++++++++++++
>> net/sunrpc/clnt.c             |    4 +++
>> 2 files changed, 49 insertions(+), 0 deletions(-)
>>
>> diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
>> index 1852f11..bca5ad3 100644
>> --- a/include/trace/events/sunrpc.h
>> +++ b/include/trace/events/sunrpc.h
>> @@ -8,6 +8,51 @@
>> #include <linux/sunrpc/clnt.h>
>> #include <linux/tracepoint.h>
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
>> +	TP_PROTO(int status),
>> +
>> +	TP_ARGS(status),
>> +
>> +	TP_STRUCT__entry(
>> +		__field(int, status)
>> +	),
>> +
>> +	TP_fast_assign(
>> +		__entry->status = status;
>> +	),
>> +
>> +	TP_printk("status=%d", __entry->status)
>> +);
>> +
>> DECLARE_EVENT_CLASS(rpc_task_running,
>>
>> 	TP_PROTO(const struct rpc_clnt *clnt, const struct rpc_task *task, const void *action),
>> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
>> index f0268ea..bbe7385 100644
>> --- a/net/sunrpc/clnt.c
>> +++ b/net/sunrpc/clnt.c
>> @@ -55,6 +55,7 @@ static DEFINE_SPINLOCK(rpc_client_lock);
>>
>> static DECLARE_WAIT_QUEUE_HEAD(destroy_wait);
>>
>> +#include <trace/events/sunrpc.h>
> 
> I'd prefer that this #include be kept with the others at the head of the file, unless there is a strong reason this one needs to be inconsistent.
No particular reason it there... Things still compile when its moved up.
Trond, if you are inclined to accept these I'll do the repost.
 
> 
> I'm glad a clean way was found to add trace points to the RPC client.
Ditto... I wounder if it time we talking about maintaining some 
basic probs that we can point people to help them debug. Also
maybe come up with some type of strategy of how we want to
use this in the future... Should be start moving toward 
having trace point replace dprintks? 

steved. 
