Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60512 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750952Ab1HXH4a (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Aug 2011 03:56:30 -0400
Message-ID: <4E54AFA0.7050202@cn.fujitsu.com>
Date: Wed, 24 Aug 2011 16:00:32 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: Jeff Layton <jlayton@redhat.com>
CC: Chuck Lever <chuck.lever@oracle.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        NFS <linux-nfs@vger.kernel.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] sunrpc: Add scope id to svc_addr_u for IPv6 LINKLOCAL
 address
References: <4E4F8B5D.6060404@cn.fujitsu.com>	<20110822192348.GA16261@fieldses.org>	<20110822153939.14d0a6ac@tlielax.poochiereds.net>	<73D17319-3FDB-4278-872A-FF488E1C88DD@oracle.com> <20110823104323.0da02307@corrin.poochiereds.net>
In-Reply-To: <20110823104323.0da02307@corrin.poochiereds.net>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Jeff Layton :
> On Mon, 22 Aug 2011 15:44:39 -0400
> Chuck Lever <chuck.lever@oracle.com> wrote:
> 
>> On Aug 22, 2011, at 3:39 PM, Jeff Layton wrote:
>>
>>> On Mon, 22 Aug 2011 15:23:48 -0400
>>> "J. Bruce Fields" <bfields@fieldses.org> wrote:
>>>
>>>> On Sat, Aug 20, 2011 at 06:24:29PM +0800, Mi Jinlong wrote:
>>>>> For IPv6 local address, lockd can not callback to client for 
>>>>> missing scope id when binding address at inet6_bind:
>>>>>
>>>>> 324       if (addr_type & IPV6_ADDR_LINKLOCAL) {
>>>>> 325               if (addr_len >= sizeof(struct sockaddr_in6) &&
>>>>> 326                   addr->sin6_scope_id) {
>>>>> 327                       /* Override any existing binding, if another one
>>>>> 328                        * is supplied by user.
>>>>> 329                        */
>>>>> 330                       sk->sk_bound_dev_if = addr->sin6_scope_id;
>>>>> 331               }
>>>>> 332 
>>>>> 333               /* Binding to link-local address requires an interface */
>>>>> 334               if (!sk->sk_bound_dev_if) {
>>>>> 335                       err = -EINVAL;
>>>>> 336                       goto out_unlock;
>>>>> 337               }
>>>>>
>>>>> This patch adds scope id to svc_addr_u for IPv6 address, and copy scope from
>>>>> xprt->xpt_local to rqstp->rq_daddr for use.
>>>>>
>>>>> With this patch, lockd can callback to client success.
>>>> I guess this makes sense to me, but someone who understands IPv6 better
>>>> should comment... Chuck?  Jeff?
>>>>
>>> Sounds like a reasonable explanation. Link-local addresses all have the
>>> same prefix, so we need a scopeid (aka interface ID# for linux) to know
>>> which interface we should send a call on.
>>>
>>> When I did the patches to allow NFSv4 callbacks to go over IPv6, I
>>> did something similar, but used the rq_addr. From gen_callback:
>>>
>>>        struct sockaddr *sa = svc_addr(rqstp);
>>>        u32 scopeid = rpc_get_scope_id(sa);
>>>
>>> ...and the scopeid was used to populate the scopeid of the callback
>>> address. The rq_daddr should be equivalent though. The _addr and _daddr
>>> must have the same scopeid or something is very wrong...
>> Sure, that would preclude the need to upgrade the field to a struct sockaddr_storage.
>>
>>> That said, on a semi-related note...
>>>
>>> I have to wonder about statd in conjunction with link-local addresses.
>>> I have a hard time understanding how you'd ever get reboot
>>> notifications in such a setup.
>> The only way that could work is if DNS was able to look at a local hostname, and provide the correct scope ID.  Doubtful.  I wonder if mDNS might provide such ability.
>>
> 
> I haven't looked closely at the mDNS protocol, but regular DNS does not
> support scopeids on AAAA records.
> 
> It does seem somewhat plausible that this could work "accidentally".
> The reboot notifications could end up going via routable addresses
> instead of the link-local ones if you set nsm_use_hostnames.
> 
> NSM is a shaky protocol at best though, so I'd make sure to test this
> before relying on it. Mi, if you get this working (including reboot
> notifications), please let us know how you solved this...

Hi Jeff,

  I'm not working on NSM. It seems there are some problem of the 
  latest statd from Steve's git tee.

  If having time, I will check the latest statd and sm-notify.
 

thanks,
Mi Jinlong

