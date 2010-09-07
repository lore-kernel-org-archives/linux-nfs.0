Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:51296 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753136Ab0IGSdi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Sep 2010 14:33:38 -0400
Message-ID: <4C86857A.8040903@candelatech.com>
Date: Tue, 07 Sep 2010 11:33:30 -0700
From: Ben Greear <greearb@candelatech.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: RFC:  support srcaddr= option to bind to local IPs.
References: <4C81449B.4010900@candelatech.com> <1283882166.2788.48.camel@heimdal.trondhjem.org>
In-Reply-To: <1283882166.2788.48.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 09/07/2010 10:56 AM, Trond Myklebust wrote:
> On Fri, 2010-09-03 at 11:55 -0700, Ben Greear wrote:
>> This patch lets one bind the local side of NFS sockets to a particular
>> IP address.  This can be useful for users on multi-homed systems.
>>
>> This patch must be on top of the previous patch to fix the IPv6 address
>> comparison or it will not work.
>>
>> Comments and suggestions welcome...I'll incorporate those and post an
>> official signed-off patch after that.
>>
>> Thanks,
>> Ben
>>
>
> The code in nfs_callback_authenticate is going to break NFSv4 callbacks.
> Callbacks are sent to the -oclientaddr address, not srcaddr (btw, I
> really dislike that new boolean argument to nfs_find_client(). If you
> don't want to compare the source address, then have the caller pass a
> NULL pointer).

It would break things to have clientaddr different than srcaddr, but as
long as they are the same (or either is not specified), I think my patch
will be fine.  I have tested NFS without specifying srcaddr and it seems
to work fine, for instance.

I think if one were to pass a flag that said 'bind-to-clientaddr' that
would also solve my needs, but I don't think it would make the patch
much less intrusive.

I'm fine with getting rid of the boolean.

> As has been pointed out to you before, all this is very intrusive, and
> you have yet to give a description of why it is useful, and better than
> using private socket namespaces (which is what container virtualised
> systems will be wanting). The latter can even ensure that it all works
> for userspace applications (such as rpc.statd) too.

Namespaces can be difficult to manage and relatively heavy weight,
so they are no good for my use.  This srcaddr patch is useful because
it allows multiple mounts on different network adapters or IP addresses,
(virtual or otherwise).  My particular use for this is to do load testing
on NFS servers, but I'm sure other folks with have other uses.

I really don't see how it's so intrusive.  It does add some arguments to some
methods, but the overall logic change is quite small.

It should be simple enough to fix rpc.statd to bind to IPs properly,
but I haven't looked at that code.

> IOW: I'd be quite happy to take patches to support private namespaces
> properly: afaics, we do need to make nfs_find_client aware of them, and
> ditto for lockd and the NFSv4 callback channel.
> I remain less than convinced that we need to be able to specify
> per-mountpoint source addresses...

I got my hopes up because the cifs guys were interested in supporting srcaddr,
so I thought maybe NFS folks were now of similar mind.  If you still see no use in
it, I'll wait a few more years and try again.

In the meantime, I'll fix the boolean issue and work to fix any other
technical issues that come up.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

