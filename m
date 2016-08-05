Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:36515 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935561AbcHESJD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Aug 2016 14:09:03 -0400
Subject: Re: [PATCH Version 7 6/8] SUNRPC add an RPC null call to test session
 trunking connection
To: "Adamson, Andy" <William.Adamson@netapp.com>
References: <1469645000-19791-1-git-send-email-andros@netapp.com>
 <1469645000-19791-7-git-send-email-andros@netapp.com>
 <c3229909-cafb-6234-df63-3a6785cf8ab2@Netapp.com>
 <F10330FF-4D9E-4DEE-8420-54F508865303@netapp.com>
CC: Trond Myklebust <trond.myklebust@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <818f69ab-f43e-427e-a697-a4430830637c@Netapp.com>
Date: Fri, 5 Aug 2016 14:08:56 -0400
MIME-Version: 1.0
In-Reply-To: <F10330FF-4D9E-4DEE-8420-54F508865303@netapp.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/05/2016 12:41 PM, Adamson, Andy wrote:
> 
>> On Aug 4, 2016, at 3:26 PM, Schumaker, Anna <Anna.Schumaker@netapp.com> wrote:
>>
>> Hi Andy,
>>
>> On 07/27/2016 02:43 PM, andros@netapp.com wrote:
>>> From: Andy Adamson <andros@netapp.com>
>>>
>>> Signed-off-by: Andy Adamson <andros@netapp.com>
>>> ---
>>> include/linux/sunrpc/clnt.h |  2 ++
>>> net/sunrpc/clnt.c           | 18 ++++++++++++++++++
>>> 2 files changed, 20 insertions(+)
>>>
>>> diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
>>> index 99410bb..ebc83df 100644
>>> --- a/include/linux/sunrpc/clnt.h
>>> +++ b/include/linux/sunrpc/clnt.h
>>> @@ -189,6 +189,8 @@ int 		rpc_clnt_test_and_add_xprt(struct rpc_clnt *clnt,
>>> 			struct rpc_xprt_switch *xps,
>>> 			struct rpc_xprt *xprt,
>>> 			void *dummy);
>>> +int		rpc_clnt_test_xprt(struct rpc_clnt *clnt,
>>> +			struct rpc_xprt *xprt);
>>> int		rpc_clnt_add_xprt(struct rpc_clnt *, struct xprt_create *,
>>> 			int (*setup)(struct rpc_clnt *,
>>> 				struct rpc_xprt_switch *,
>>> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
>>> index 459f9b1..822060f 100644
>>> --- a/net/sunrpc/clnt.c
>>> +++ b/net/sunrpc/clnt.c
>>> @@ -2614,6 +2614,24 @@ int rpc_clnt_test_and_add_xprt(struct rpc_clnt *clnt,
>>> }
>>> EXPORT_SYMBOL_GPL(rpc_clnt_test_and_add_xprt);
>>>
>>> +int rpc_clnt_test_xprt(struct rpc_clnt *clnt, struct rpc_xprt *xprt)
>>
>> Looks like rpc_clnt_test_and_add_xprt() runs the same testing code.  Can you swap the order of these functions in clnt.c and then have test_and_add_xprt() call test_xprt()?
> 
> rpc_clnt_test_xprt uses a SYNC null call while test_and_add_xprt uses an ASYNC call. Futhermore, while both test_xprt and test_and_add_xprt return an error if the rpc_call_null_helper task cannot be allocated (ERR_PTR(task) in rpc_new_task), test_and_add_xprt ignores the tk_status and returns 1 while test_xprt returns the tk_status.

Ah, I missed that one is sync and the other isn't.  Thanks for pointing that out!  I still wish there was a common function they both could tall to handle the cred lookup, but maybe that's not as easy as it seems.

Anna

> 
> For these reasons I think it is cleaner and easier to read to keep them separate functions.
> 
> —>Andy
> :
>>
>> Thanks,
>> Anna
>>
>>> +{
>>> +	struct rpc_cred *cred;
>>> +	struct rpc_task *task;
>>> +	int status;
>>> +
>>> +	cred = authnull_ops.lookup_cred(NULL, NULL, 0);
>>> +	task = rpc_call_null_helper(clnt, xprt, cred,
>>> +				RPC_TASK_SOFT | RPC_TASK_SOFTCONN, NULL, NULL);
>>> +	put_rpccred(cred);
>>> +	if (IS_ERR(task))
>>> +		return PTR_ERR(task);
>>> +	status = task->tk_status;
>>> +	rpc_put_task(task);
>>> +	return status;
>>> +}
>>> +EXPORT_SYMBOL_GPL(rpc_clnt_test_xprt);
>>> +
>>> /**
>>>  * rpc_clnt_add_xprt - Add a new transport to a rpc_clnt
>>>  * @clnt: pointer to struct rpc_clnt
> 

