From: "Batsakis, Alexandros" <Alexandros.Batsakis@netapp.com>
Subject: Re: [PATCH 6/6] RPC: adjust timeout for connect, bind, restablish so that they sensitive to the major time out value
Date: Fri, 5 Feb 2010 14:14:08 -0800
Message-ID: <383F4881-BD88-4155-B605-4D24F5B05BDD@netapp.com>
References: <1265155576-7618-1-git-send-email-batsakis@netapp.com> <1265155576-7618-2-git-send-email-batsakis@netapp.com> <1265155576-7618-3-git-send-email-batsakis@netapp.com> <1265155576-7618-4-git-send-email-batsakis@netapp.com> <1265155576-7618-5-git-send-email-batsakis@netapp.com> <1265155576-7618-6-git-send-email-batsakis@netapp.com> <1265155576-7618-7-git-send-email-batsakis@netapp.com> <4B6C7BCA.2040806@oracle.com>
Mime-Version: 1.0 (iPhone Mail 7D11)
Content-Type: text/plain;
	format=flowed;
	delsp=yes;
	charset="us-ascii"
Cc: "Alexandros Batsakis" <batsakis@netapp.com>,
	<linux-nfs@vger.kernel.org>, <trond@netapp.com>
To: "Chuck Lever" <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:35934 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933791Ab0BEWPE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Feb 2010 17:15:04 -0500
In-Reply-To: <4B6C7BCA.2040806@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Yeah sure,

So imagine that for a specific connection the remaining major timeo  
value is 30secs. Xs_connect has a default timeout before attempting to  
reconnect of 60secs. The user (NFS) expects to "hear back" from the  
rpc layer within the timeout as in often cases e.g. lease renewal,  
it's of no benefit for an operation to reach the server at a later  
time and miss the critical time because it was sleeping for an  
arbitrary amount of time.

My patch ensures that the reconnection attempts happen within the user- 
specified limits by replacing the 60secs default timeout with a value  
that is less than the time to expire. If this is not ideal the user  
should readjust the timeout value.

Does it make sense?

-alexandros

On Feb 5, 2010, at 12:14, "Chuck Lever" <chuck.lever@oracle.com> wrote:

> Hi Alexandros-
>
> I think we need a little more than the short description for these  
> patches.  Can you explain why the extra logic in xs_connect is  
> necessary?  What exactly happens if the RENEW doesn't reach the  
> server because the transport can't be reconnected?
>
> In other words, what problem are you trying to address here?
>
> On 02/02/2010 07:06 PM, Alexandros Batsakis wrote:
>> Signed-off-by: Alexandros Batsakis<batsakis@netapp.com>
>> ---
>>  net/sunrpc/clnt.c     |    2 +-
>>  net/sunrpc/sunrpc.h   |    2 ++
>>  net/sunrpc/xprt.c     |   18 +++++++++++++++---
>>  net/sunrpc/xprtsock.c |   12 ++++++++++--
>>  4 files changed, 28 insertions(+), 6 deletions(-)
>>
>> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
>> index 154034b..8e552cd 100644
>> --- a/net/sunrpc/clnt.c
>> +++ b/net/sunrpc/clnt.c
>> @@ -1019,7 +1019,7 @@ call_bind(struct rpc_task *task)
>>      task->tk_action = call_connect;
>>      if (!xprt_bound(xprt)) {
>>          task->tk_action = call_bind_status;
>> -        task->tk_timeout = xprt->bind_timeout;
>> +        xprt_set_timeout_sane(task, xprt->bind_timeout);
>>          xprt->ops->rpcbind(task);
>>      }
>>  }
>> diff --git a/net/sunrpc/sunrpc.h b/net/sunrpc/sunrpc.h
>> index 90c292e..87c7aaa 100644
>> --- a/net/sunrpc/sunrpc.h
>> +++ b/net/sunrpc/sunrpc.h
>> @@ -37,6 +37,8 @@ struct rpc_buffer {
>>      char    data[];
>>  };
>>
>> +void xprt_set_timeout_sane(struct rpc_task *task, unsigned long  
>> timeout);
>> +
>>  static inline int rpc_reply_expected(struct rpc_task *task)
>>  {
>>      return (task->tk_msg.rpc_proc != NULL)&&
>> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
>> index 469de29..f6f3988 100644
>> --- a/net/sunrpc/xprt.c
>> +++ b/net/sunrpc/xprt.c
>> @@ -482,7 +482,7 @@ void xprt_wait_for_buffer_space(struct rpc_task  
>> *task, rpc_action action)
>>      struct rpc_rqst *req = task->tk_rqstp;
>>      struct rpc_xprt *xprt = req->rq_xprt;
>>
>> -    task->tk_timeout = req->rq_timeout;
>> +    xprt_set_timeout_sane(task, req->rq_timeout);
>>      rpc_sleep_on(&xprt->pending, task, action);
>>  }
>>  EXPORT_SYMBOL_GPL(xprt_wait_for_buffer_space);
>> @@ -518,7 +518,7 @@ EXPORT_SYMBOL_GPL(xprt_write_space);
>>   */
>>  void xprt_set_retrans_timeout_def(struct rpc_task *task)
>>  {
>> -    task->tk_timeout = task->tk_rqstp->rq_timeout;
>> +    xprt_set_timeout_sane(task, task->tk_rqstp->rq_timeout);
>>  }
>>  EXPORT_SYMBOL_GPL(xprt_set_retrans_timeout_def);
>>
>> @@ -682,6 +682,18 @@ out_abort:
>>      spin_unlock(&xprt->transport_lock);
>>  }
>>
>> +void xprt_set_timeout_sane(struct rpc_task *task, unsigned long  
>> timeout)
>
> xprt_set_timeout_sane?  That's amusing, but it isn't very  
> descriptive to someone who doesn't know why this extra function is  
> needed.
>
>> +{
>> +    unsigned long majorto = task->tk_rqstp->rq_majortimeo;
>> +
>> +    if (majorto<= jiffies)
>> +        task->tk_timeout = 5 * HZ;
>> +    else if (timeout>  majorto - jiffies)
>> +        task->tk_timeout = 2 * (majorto - jiffies) / 3;
>> +    else
>> +        task->tk_timeout = timeout;
>> +}
>> +
>>  /**
>>   * xprt_connect - schedule a transport connect operation
>>   * @task: RPC task that is requesting the connect
>> @@ -710,7 +722,7 @@ void xprt_connect(struct rpc_task *task)
>>          if (task->tk_rqstp)
>>              task->tk_rqstp->rq_bytes_sent = 0;
>>
>> -        task->tk_timeout = xprt->connect_timeout;
>> +        xprt_set_timeout_sane(task, xprt->connect_timeout);
>>          rpc_sleep_on(&xprt->pending, task, xprt_connect_status);
>>          xprt->stat.connect_start = jiffies;
>>          xprt->ops->connect(task);
>> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
>> index 721bafd..7fcc97f 100644
>> --- a/net/sunrpc/xprtsock.c
>> +++ b/net/sunrpc/xprtsock.c
>> @@ -2020,9 +2020,17 @@ static void xs_connect(struct rpc_task *task)
>>          return;
>>
>>      if (transport->sock != NULL&&  !RPC_IS_SOFTCONN(task)) {
>> +        unsigned long majorto = task->tk_rqstp->rq_majortimeo;
>> +
>> +        if (majorto<= jiffies)
>> +            xprt->reestablish_timeout = 5 * HZ;
>> +        else if (xprt->reestablish_timeout>  majorto - jiffies)
>> +            xprt->reestablish_timeout = 2 * (majorto - jiffies)
>> +              / 3;
>
> This looks like the code you added above in _sane.  Can you reuse  
> that code here?
>
>> +
>>          dprintk("RPC:       xs_connect delayed xprt %p for %lu "
>> -                "seconds\n",
>> -                xprt, xprt->reestablish_timeout / HZ);
>> +            "seconds\n",
>> +            xprt, xprt->reestablish_timeout + (HZ - 1) / HZ);
>>          queue_delayed_work(rpciod_workqueue,
>>                  &transport->connect_worker,
>>                     xprt->reestablish_timeout);
>
>
> -- 
> chuck[dot]lever[at]oracle[dot]com
