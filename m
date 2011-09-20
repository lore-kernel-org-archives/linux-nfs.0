Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:33630 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750890Ab1ITP7D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Sep 2011 11:59:03 -0400
Message-ID: <4E78B825.4020803@parallels.com>
Date: Tue, 20 Sep 2011 19:58:29 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Jeff Layton <jlayton@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Pavel Emelianov <xemul@parallels.com>, "neilb@suse.de" <neilb@suse.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "davem@davemloft.net" <davem@davemloft.net>
Subject: Re: [PATCH v5 1/8] SUNRPC: introduce helpers for reference counted
 rpcbind clients
References: <20110920101031.9861.18444.stgit@localhost6.localdomain6><20110920101341.9861.51453.stgit@localhost6.localdomain6><4E7899E7.9090809@parallels.com> <20110920102431.58ca1d96@tlielax.poochiereds.net> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B47FD2C@SACMVEXC2-PRD.hq.netapp.com>
In-Reply-To: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B47FD2C@SACMVEXC2-PRD.hq.netapp.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

20.09.2011 18:41, Myklebust, Trond пишет:
>> -----Original Message-----
>> From: Jeff Layton [mailto:jlayton@redhat.com]
>> Sent: Tuesday, September 20, 2011 10:25 AM
>> To: Stanislav Kinsbursky
>> Cc: Myklebust, Trond; linux-nfs@vger.kernel.org; Pavel Emelianov;
>> neilb@suse.de; netdev@vger.kernel.org; linux-kernel@vger.kernel.org;
>> bfields@fieldses.org; davem@davemloft.net
>> Subject: Re: [PATCH v5 1/8] SUNRPC: introduce helpers for reference
>> counted rpcbind clients
>>
>> On Tue, 20 Sep 2011 17:49:27 +0400
>> Stanislav Kinsbursky<skinsbursky@parallels.com>  wrote:
>>
>>> v5: fixed races with rpcb_users in rpcb_get_local()
>>>
>>> This helpers will be used for dynamical creation and destruction of
>>> rpcbind clients.
>>> Variable rpcb_users is actually a counter of lauched RPC services.
> If
>>> rpcbind clients has been created already, then we just increase
> rpcb_users.
>>>
>>> Signed-off-by: Stanislav Kinsbursky<skinsbursky@parallels.com>
>>>
>>> ---
>>>    net/sunrpc/rpcb_clnt.c |   53
>> ++++++++++++++++++++++++++++++++++++++++++++++++
>>>    1 files changed, 53 insertions(+), 0 deletions(-)
>>>
>>> diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c index
>>> e45d2fb..5f4a406 100644
>>> --- a/net/sunrpc/rpcb_clnt.c
>>> +++ b/net/sunrpc/rpcb_clnt.c
>>> @@ -114,6 +114,9 @@ static struct rpc_program	rpcb_program;
>>>    static struct rpc_clnt *	rpcb_local_clnt;
>>>    static struct rpc_clnt *	rpcb_local_clnt4;
>>>    +DEFINE_SPINLOCK(rpcb_clnt_lock);
>>> +unsigned int			rpcb_users;
>>> +
>>>    struct rpcbind_args {
>>>    	struct rpc_xprt *	r_xprt;
>>>    @@ -161,6 +164,56 @@ static void rpcb_map_release(void *data)
>>>    	kfree(map);
>>>    }
>>>    +static int rpcb_get_local(void)
>>> +{
>>> +	int cnt;
>>> +
>>> +	spin_lock(&rpcb_clnt_lock);
>>> +	if (rpcb_users)
>>> +		rpcb_users++;
>>> +	cnt = rpcb_users;
>>> +	spin_unlock(&rpcb_clnt_lock);
>>> +
>>> +	return cnt;
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
>>
>> In the function below, you mention that the above pointers are
> protected by
>> rpcb_create_local_mutex, but it looks like they get reset here without
> that
>> being held?
>>
>> Might it be simpler to just protect rpcb_users with the
>> rpcb_create_local_mutex and ensure that it's held whenever you call
> one of
>> these routines? None of these are codepaths are particularly hot.
>
> Alternatively, if you do
>
> 	if (rpcb_users == 1) {
> 		rpcb_local_clnt = NULL;
> 		rpcb_local_clnt4 = NULL;
> 		smp_wmb();
> 		rpcb_users = 0;
> 	} else
> 		rpcb_users--;
>
> then the spinlock protection in rpbc_get_local() is still good enough to
> guarantee correctness.

I don't understand the idea of this code. It guarantees, that if rpcb_users == 
0, then rpcb_local_clnt == NULL and rpcb_local_clnt4 == NULL.
But we don't need such guarantee from my pow.
I.e. if rpcb_users == 0, then it means, that no services running right now.

For example, processes, destroying those clients, is running on CPU#0.
On CPU#1, for example, we have another process trying to get those clients and 
waiting on spinlock. When this process will gain the spinlock, it will see 0 
users, gain mutex and then try to create new clients. We still have no users on 
this clients yet. And this process will just reassign whose rpcbind clients 
pointers (and here we need memmory barrier for sure).

-- 
Best regards,
Stanislav Kinsbursky
