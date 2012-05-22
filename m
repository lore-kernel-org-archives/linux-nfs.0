Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:58075 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932158Ab2EVPXM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 May 2012 11:23:12 -0400
Message-ID: <4FBBAF59.5070000@parallels.com>
Date: Tue, 22 May 2012 19:23:05 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: Simo Sorce <simo@redhat.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        "bfields@redhat.com" <bfields@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/4] SUNRPC: Add RPC based upcall mechanism for RPCGSS
 auth
References: <1337087550-9821-1-git-send-email-simo@redhat.com>  <1337087550-9821-4-git-send-email-simo@redhat.com>  <20120522124728.GB891@fieldses.org>  <1337691607.16840.178.camel@willson.li.ssimo.org>  <4FBB91EE.3010307@parallels.com>  <1337692966.16840.181.camel@willson.li.ssimo.org>  <4FBB9551.9010407@parallels.com>  <1337698684.16840.184.camel@willson.li.ssimo.org>  <4FBBAC68.60406@parallels.com> <1337699906.16840.192.camel@willson.li.ssimo.org>
In-Reply-To: <1337699906.16840.192.camel@willson.li.ssimo.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 22.05.2012 19:18, Simo Sorce wrote:
> On Tue, 2012-05-22 at 19:10 +0400, Stanislav Kinsbursky wrote:
>> On 22.05.2012 18:58, Simo Sorce wrote:
>>> On Tue, 2012-05-22 at 17:32 +0400, Stanislav Kinsbursky wrote:
>>>> It actually means, that no hard-coded init_net references should appear - and
>>>> that's all. Required network context have to be taken from currently existent
>>>> objects (like RPC client, RPC service, etc) and, if not available (it's very
>>>> rare case - like NFS mount call), from current->nsproxy->net_ns.
>>>> You don't need to do anything special except this.
>>>> There will be a problem with your patches in container, because you are using
>>>> unix socket. But this problem is not in your patches but in unix sockets
>>>> themselves. So don't worry about it.
>>>
>>> Can you tell me if the attached patches are all you think is needed ?
>>> If they are, I'll squash them in with other fixes and will send out a
>>> new patch set.
>>>
>>
>> Yep, looks good.
>> Would be great, if you'll fix a couple of minor issues:
>> 1) rename "xprt_net" to "net" in prototypes (just to make things look in one
>> style with other places in SUNRPC layer)
>
> TBH, I thikn using 'net' is the worst name you guys could come up with,
> try to 'git grep net' to see what I mean, but whatever, the damage is
> already done, I'll change it.
>

The reason for the simple name was that we don't care, where we gained this net: 
was it transport or whatever.
IOW, "xprt_net" doesn't carrying any required information comparing to "net" in 
this case.

>> 2) define net variable on stack in svcauth_gss_proxy_init() (looks simpler):
>>
>> +static int svcauth_gss_proxy_init(struct svc_rqst *rqstp,
>> +                       struct rpc_gss_wire_cred *gc, __be32 *authp)
>> ....
>> +       struct net *net = rqstp->rq_xprt->xpt_net;
>> +       struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
>> ....
>> +       status = gssp_accept_sec_context_upcall(net,&ud);
>
> Heh, that is what I did at first, then changed. Works for me, I'll
> include these changes in the new patchset.
>

Thanks, Simo.

> Simo.
>


-- 
Best regards,
Stanislav Kinsbursky
