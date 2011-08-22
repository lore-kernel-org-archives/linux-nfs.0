Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:18244 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753508Ab1HVTpb convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Aug 2011 15:45:31 -0400
Subject: Re: [PATCH] sunrpc: Add scope id to svc_addr_u for IPv6 LINKLOCAL address
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20110822153939.14d0a6ac@tlielax.poochiereds.net>
Date: Mon, 22 Aug 2011 15:44:39 -0400
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Mi Jinlong <mijinlong@cn.fujitsu.com>, NFS <linux-nfs@vger.kernel.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Message-Id: <73D17319-3FDB-4278-872A-FF488E1C88DD@oracle.com>
References: <4E4F8B5D.6060404@cn.fujitsu.com> <20110822192348.GA16261@fieldses.org> <20110822153939.14d0a6ac@tlielax.poochiereds.net>
To: Jeff Layton <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Aug 22, 2011, at 3:39 PM, Jeff Layton wrote:

> On Mon, 22 Aug 2011 15:23:48 -0400
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
>> On Sat, Aug 20, 2011 at 06:24:29PM +0800, Mi Jinlong wrote:
>>> For IPv6 local address, lockd can not callback to client for 
>>> missing scope id when binding address at inet6_bind:
>>> 
>>> 324       if (addr_type & IPV6_ADDR_LINKLOCAL) {
>>> 325               if (addr_len >= sizeof(struct sockaddr_in6) &&
>>> 326                   addr->sin6_scope_id) {
>>> 327                       /* Override any existing binding, if another one
>>> 328                        * is supplied by user.
>>> 329                        */
>>> 330                       sk->sk_bound_dev_if = addr->sin6_scope_id;
>>> 331               }
>>> 332 
>>> 333               /* Binding to link-local address requires an interface */
>>> 334               if (!sk->sk_bound_dev_if) {
>>> 335                       err = -EINVAL;
>>> 336                       goto out_unlock;
>>> 337               }
>>> 
>>> This patch adds scope id to svc_addr_u for IPv6 address, and copy scope from
>>> xprt->xpt_local to rqstp->rq_daddr for use.
>>> 
>>> With this patch, lockd can callback to client success.
>> 
>> I guess this makes sense to me, but someone who understands IPv6 better
>> should comment... Chuck?  Jeff?
>> 
> 
> Sounds like a reasonable explanation. Link-local addresses all have the
> same prefix, so we need a scopeid (aka interface ID# for linux) to know
> which interface we should send a call on.
> 
> When I did the patches to allow NFSv4 callbacks to go over IPv6, I
> did something similar, but used the rq_addr. From gen_callback:
> 
>        struct sockaddr *sa = svc_addr(rqstp);
>        u32 scopeid = rpc_get_scope_id(sa);
> 
> ...and the scopeid was used to populate the scopeid of the callback
> address. The rq_daddr should be equivalent though. The _addr and _daddr
> must have the same scopeid or something is very wrong...

Sure, that would preclude the need to upgrade the field to a struct sockaddr_storage.

> That said, on a semi-related note...
> 
> I have to wonder about statd in conjunction with link-local addresses.
> I have a hard time understanding how you'd ever get reboot
> notifications in such a setup.

The only way that could work is if DNS was able to look at a local hostname, and provide the correct scope ID.  Doubtful.  I wonder if mDNS might provide such ability.

> You might be able to make it work if /etc/hosts allowed you to put in a
> scopeid for an address, but even then it sounds sketchy...

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




