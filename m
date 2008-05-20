From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 8/8] SUNRPC: Display symbolic function addresses in rpc_show_tasks
Date: Tue, 20 May 2008 17:37:32 -0400
Message-ID: <3F88B3F3-1820-4C6D-BE3F-533207747FBF@oracle.com>
References: <20080520202108.3851.7464.stgit@ellison.1015granger.net> <20080520203018.3851.21166.stgit@ellison.1015granger.net> <1211317892.26809.8.camel@localhost>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:15947 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761094AbYETVi0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 May 2008 17:38:26 -0400
In-Reply-To: <1211317892.26809.8.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May 20, 2008, at 5:11 PM, Trond Myklebust wrote:
> On Tue, 2008-05-20 at 16:30 -0400, Chuck Lever wrote:
>> For each running RPC task, rpc_show_tasks displays the hex address  
>> of the
>> call_foo function that the task is running.  To make debugging  
>> slightly
>> nicer, let's display the call_foo function name instead.
>>
>> Sample output:
>>
>> -pid- flgs status -client- --rqstp- -timeout ---ops--
>> 27915 0001      0 ee84a460 eedf00d0    60000 f8fa677c nfs3 COMMIT  
>> act:status wq:xprt_pending
>> 27918 0080      0 ee84a460 eedf0000    60000 f8d527a8 nfs3 SETATTR  
>> act:status wq:xprt_pending
>>
>> -pid- flgs status -client- --rqstp- -timeout ---ops--
>> 60859 0001      0 ee84a460 eedf00d0        0 f8fa66c8 nfs3 READ  
>> act:status
>> 60860 0080      0 ee84a460 eedf0000        0 f8d527a8 nfs3 GETATTR  
>> act:status
>>
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>
>> include/linux/sunrpc/sched.h |    1 +
>> net/sunrpc/clnt.c            |   52 ++++++++++++++++++++++++++++++++ 
>> +++++++---
>> net/sunrpc/sched.c           |    2 +-
>> 3 files changed, 50 insertions(+), 5 deletions(-)
>>
>>
>> diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/ 
>> sched.h
>> index d1a5c8c..108342e 100644
>> --- a/include/linux/sunrpc/sched.h
>> +++ b/include/linux/sunrpc/sched.h
>> @@ -212,6 +212,7 @@ struct rpc_wait_queue {
>> struct rpc_task *rpc_new_task(const struct rpc_task_setup *);
>> struct rpc_task *rpc_run_task(const struct rpc_task_setup *);
>> void		rpc_put_task(struct rpc_task *);
>> +void		rpc_prepare_task(struct rpc_task *);
>> void		rpc_exit_task(struct rpc_task *);
>> void		rpc_release_calldata(const struct rpc_call_ops *, void *);
>> void		rpc_killall_tasks(struct rpc_clnt *);
>> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
>> index c33d727..ec9c072 100644
>> --- a/net/sunrpc/clnt.c
>> +++ b/net/sunrpc/clnt.c
>> @@ -1510,24 +1510,68 @@ struct rpc_task *rpc_call_null(struct  
>> rpc_clnt *clnt, struct rpc_cred *cred, int
>> EXPORT_SYMBOL_GPL(rpc_call_null);
>>
>> #ifdef RPC_DEBUG
>> +/*
>> + * To make it easier to tell what action each running RPC task
>> + * is executing, use a table to map the content of tk_action to
>> + * a human-readable name.  This uses a little extra memory, but
>> + * causes no additional run-time overhead per RPC request.
>> + */
>> +typedef void   (*rpc_task_action)(struct rpc_task *);
>> +
>> +static struct {
>> +	rpc_task_action		action;
>> +	const char		*name;
>> +} rpc_action_table[] = {
>> +	{ rpc_prepare_task,		"prepare"		},
>> +	{ call_start,			"start"			},
>> +	{ call_reserve,			"reserve"		},
>> +	{ call_reserveresult,		"reserveresult"		},
>> +	{ call_allocate,		"allocate"		},
>> +	{ call_bind,			"bind"			},
>> +	{ call_bind_status,		"bindstatus"		},
>> +	{ call_connect,			"connect"		},
>> +	{ call_connect_status,		"connectstatus"		},
>> +	{ call_transmit,		"transmit"		},
>> +	{ call_transmit_status,		"transmitstatus"	},
>> +	{ call_status,			"status"		},
>> +	{ call_timeout,			"timeout"		},
>> +	{ call_decode,			"decode"		},
>> +	{ call_refresh,			"refresh"		},
>> +	{ call_refreshresult,		"refreshresult"		},
>> +	{ rpc_exit_task,		"exit"			},
>> +	{ NULL,				"null"			},
>> +};
>>
>> +
>> +static const char *rpc_show_action(rpc_task_action action)
>> +{
>> +	unsigned int i;
>> +
>> +	for (i = 0; i <= ARRAY_SIZE(rpc_action_table); i++)
>> +		if (rpc_action_table[i].action == action)
>> +			return rpc_action_table[i].name;
>> +
>> +	return "unknown";
>> +}
>
>
> NACK. Maintaining tables like the above in the long run is a  
> nightmare.

> What's more, by eliminating the printout of the actual pointer you are
> potentially replacing useful information that could otherwise easily  
> be
> looked up using /proc/kallsyms with "unknown".

> The above translation could easily be done using a simple script in
> userspace instead.

Except when you don't have access to the kernel image and modules  
where the dump was generated.  Why would I want to run a script to do  
this, when Oops output already displays symbolic function addresses in  
a callback trace?

We can drop this one for now.  Please let me know about the  
disposition of the other seven.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
