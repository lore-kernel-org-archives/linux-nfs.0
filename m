Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:6841 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750892Ab1ITNfQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Sep 2011 09:35:16 -0400
Message-ID: <4E789679.1060601@parallels.com>
Date: Tue, 20 Sep 2011 17:34:49 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Pavel Emelianov <xemul@parallels.com>, "neilb@suse.de" <neilb@suse.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "davem@davemloft.net" <davem@davemloft.net>
Subject: Re: [PATCH v4 1/8] SUNRPC: introduce helpers for reference counted
 rpcbind clients
References: <20110920101031.9861.18444.stgit@localhost6.localdomain6> <20110920101341.9861.51453.stgit@localhost6.localdomain6> <4E788F8C.20103@netapp.com> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B47FD10@SACMVEXC2-PRD.hq.netapp.com>
In-Reply-To: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B47FD10@SACMVEXC2-PRD.hq.netapp.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

20.09.2011 17:15, Myklebust, Trond пишет:
>> -----Original Message-----
>> From: Schumaker, Bryan
>> Sent: Tuesday, September 20, 2011 9:05 AM
>> To: Stanislav Kinsbursky
>> Cc: Myklebust, Trond; linux-nfs@vger.kernel.org; xemul@parallels.com;
>> neilb@suse.de; netdev@vger.kernel.org; linux-kernel@vger.kernel.org;
>> bfields@fieldses.org; davem@davemloft.net
>> Subject: Re: [PATCH v4 1/8] SUNRPC: introduce helpers for reference
>> counted rpcbind clients
>>
>> On 09/20/2011 06:13 AM, Stanislav Kinsbursky wrote:
>>> This helpers will be used for dynamical creation and destruction of
>>> rpcbind clients.
>>> Variable rpcb_users is actually a counter of lauched RPC services. If
>>> rpcbind clients has been created already, then we just increase rpcb_users.
>>>
>>> Signed-off-by: Stanislav Kinsbursky<skinsbursky@parallels.com>
>>>
>>> ---
>>>   net/sunrpc/rpcb_clnt.c |   50
>> ++++++++++++++++++++++++++++++++++++++++++++++++
>>>   1 files changed, 50 insertions(+), 0 deletions(-)
>>>
>>> diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c index
>>> e45d2fb..8724780 100644
>>> --- a/net/sunrpc/rpcb_clnt.c
>>> +++ b/net/sunrpc/rpcb_clnt.c
>>> @@ -114,6 +114,9 @@ static struct rpc_program	rpcb_program;
>>>   static struct rpc_clnt *	rpcb_local_clnt;
>>>   static struct rpc_clnt *	rpcb_local_clnt4;
>>>
>>> +DEFINE_SPINLOCK(rpcb_clnt_lock);
>>> +unsigned int			rpcb_users;
>>> +
>>>   struct rpcbind_args {
>>>   	struct rpc_xprt *	r_xprt;
>>>
>>> @@ -161,6 +164,53 @@ static void rpcb_map_release(void *data)
>>>   	kfree(map);
>>>   }
>>>
>>> +static int rpcb_get_local(void)
>>> +{
>>> +	spin_lock(&rpcb_clnt_lock);
>>> +	if (rpcb_users)
>>> +		rpcb_users++;
>>> +	spin_unlock(&rpcb_clnt_lock);
>>> +
>>> +	return rpcb_users;
>>          ^^^^^^^^^^^^^^^^^^
>> Is it safe to use this variable outside of the rpcb_clnt_lock?
>>
> Nope. If rpcb_users was zero in the protected section above, nothing guarantees that it will still be zero here, and so the caller may get the (wrong) impression that the counter was incremented.
>

Yep, you right. Will fix this races.

>>> +}
>>> +
>>> +void rpcb_put_local(void)
>>> +{
>>> +	struct rpc_clnt *clnt = rpcb_local_clnt;
>>> +	struct rpc_clnt *clnt4 = rpcb_local_clnt4;
>>> +	int shutdown;
>>> +
>>> +	spin_lock(&rpcb_clnt_lock);
>>> +	if (--rpcb_users == 0) {
>>> +		rpcb_local_clnt = NULL;
>>> +		rpcb_local_clnt4 = NULL;
>>> +	}
>>> +	shutdown = !rpcb_users;
>>> +	spin_unlock(&rpcb_clnt_lock);
>>> +
>>> +	if (shutdown) {
>>> +		/*
>>> +		 * cleanup_rpcb_clnt - remove xprtsock's sysctls, unregister
>>> +		 */
>>> +		if (clnt4)
>>> +			rpc_shutdown_client(clnt4);
>>> +		if (clnt)
>>> +			rpc_shutdown_client(clnt);
>>> +	}
>>> +	return;
>>> +}
>>> +
>>> +static void rpcb_set_local(struct rpc_clnt *clnt, struct rpc_clnt
>>> +*clnt4) {
>>> +	/* Protected by rpcb_create_local_mutex */
>
> Doesn't it  need to be protected by rpcb_clnt_lock too?
>

Nope from my pow. It's protected by rpcb_create_local_mutex. I.e. no one will 
change rpcb_users since it's zero. If it's non zero - we willn't get to 
rpcb_set_local().

>>> +	rpcb_local_clnt = clnt;
>>> +	rpcb_local_clnt4 = clnt4;
>>> +	rpcb_users++;
> ^^^^^^^^^^^^^^^^^^^
>
>>> +	dprintk("RPC:       created new rpcb local clients (rpcb_local_clnt: "
>>> +			"%p, rpcb_local_clnt4: %p)\n", rpcb_local_clnt,
>>> +			rpcb_local_clnt4);
>>> +}
>>> +
>>>   /*
>>>    * Returns zero on success, otherwise a negative errno value
>>>    * is returned.
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs"
>>> in the body of a message to majordomo@vger.kernel.org More
>> majordomo
>>> info at  http://vger.kernel.org/majordomo-info.html
>
> �{.n�+�������+%��lzwm��b�맲��r��zX��߲)���w*jg��������ݢj/���z�ޖ��2�ޙ���&�)ߡ�a�����G���h��j:+v���w�٥


-- 
Best regards,
Stanislav Kinsbursky
