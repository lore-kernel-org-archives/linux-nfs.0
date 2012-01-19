Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:13256 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932613Ab2ASRw3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Jan 2012 12:52:29 -0500
Message-ID: <4F18583F.1000209@parallels.com>
Date: Thu, 19 Jan 2012 21:51:59 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Pavel Emelianov <xemul@parallels.com>, "neilb@suse.de" <neilb@suse.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        James Bottomley <jbottomley@parallels.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH 3/5] SUNRPC: create GSS auth cache per network namespace
References: <20120119144517.9957.59143.stgit@localhost6.localdomain6> <20120119144922.9957.39352.stgit@localhost6.localdomain6> <20120119163149.GD527@fieldses.org> <4F184D28.3030207@parallels.com> <20120119174002.GA2907@fieldses.org>
In-Reply-To: <20120119174002.GA2907@fieldses.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

19.01.2012 21:40, J. Bruce Fields пишет:
> On Thu, Jan 19, 2012 at 09:04:40PM +0400, Stanislav Kinsbursky wrote:
>> 19.01.2012 20:31, J. Bruce Fields пишет:
>>> On Thu, Jan 19, 2012 at 06:49:23PM +0400, Stanislav Kinsbursky wrote:
>>>> @@ -1000,6 +996,7 @@ static int svcauth_gss_handle_init(struct svc_rqst *rqstp,
>>>>   	struct xdr_netobj tmpobj;
>>>>   	struct rsi *rsip, rsikey;
>>>>   	int ret;
>>>> +	struct sunrpc_net *sn = net_generic(rqstp->rq_xprt->xpt_net, sunrpc_net_id);
>>>
>>> OK, so you're getting the network namespace out of the rqstp, and, then
>>> passing it down, makes sense.  And:
>>>
>>>> @@ -1079,6 +1076,7 @@ svcauth_gss_accept(struct svc_rqst *rqstp, __be32 *authp)
>>>>   	__be32		*rpcstart;
>>>>   	__be32		*reject_stat = resv->iov_base + resv->iov_len;
>>>>   	int		ret;
>>>> +	struct sunrpc_net *sn = net_generic(rqstp->rq_xprt->xpt_net, sunrpc_net_id);
>>>
>>> ... same for the gss cache.  Looks good.
>>>
>>> How do you plan to test this?
>>>
>>
>> Do you mean something special or in general?
>> Currently I validate all my chages in container by using simple test environment.
>> I would be appreciate for any hints to tests, than can help.
>
> The server needs to be tested after these changes, and we need to make
> sure the caches affected still work.
>
> (I suspect the gid cache code will oops if it's used after these
> patches, since the table is left NULl?)
>
> And then we should also test in a container environment, with different
> instances of mountd and rpc.svcidmapd running in each container, to
> verify that the right thing happens.
>

Ok. I'll test server with 2-nd version of these patches tomorrow and reply with 
the results.
Thanks, Bruce.


-- 
Best regards,
Stanislav Kinsbursky
