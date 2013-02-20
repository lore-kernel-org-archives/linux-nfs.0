Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:35343 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756216Ab3BTRjt convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Feb 2013 12:39:49 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Subject: Re: synchronous AF_LOCAL connect
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9235D7E49@SACEXCMBX04-PRD.hq.netapp.com>
Date: Wed, 20 Feb 2013 12:39:38 -0500
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "simo@redhat.com" <simo@redhat.com>
Message-Id: <07128F08-BE73-401E-B765-710F43A60558@oracle.com>
References: <20130218225424.GD3391@fieldses.org> <20130220154751.GH14606@fieldses.org> <2F275139-9861-4414-8C9F-BD74544C9AD7@oracle.com> <20130220160350.GJ14606@fieldses.org> <EA9EE56A-73BB-4866-AA86-1EE4150AFE87@oracle.com> <20130220163424.GK14606@fieldses.org> <FB21B277-FA7D-490C-B389-58A91C46B490@oracle.com> <4FA345DA4F4AE44899BD2B03EEEC2FA9235D7E49@SACEXCMBX04-PRD.hq.netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 20, 2013, at 12:27 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Wed, 2013-02-20 at 12:04 -0500, Chuck Lever wrote:
> 
>> Yes, but AF_LOCAL is supposed to be a generic transport for RPC.  This is not a feature we just made up, it's actually a well-defined API that exists on other platforms (it's even specified in RFCs).  Right now I would hesitate to restrict the use of AF_LOCAL upcalls to only synchronous contexts, because eventually we may want to use the transport in asynchronous contexts.
> 
> The whole problem is that it is a piss-poorly defined feature in an
> asynchronous kernel context.
> 
> Sockets carry around a well defined net namespace context that allow
> them to resolve IP addresses. However they carry none of the file
> namespace context information that is required to make sense of AF_LOCAL
> "addresses".

I recognize this problem, but I fail to see how it is connected to asynchronicity in general.  The issue seems to be specifically how rpciod implements asynchronicity.

> IOW we have 3 options:
> 
>     1. Drop AF_LOCAL support altogether
>     2. Add file namespace context to the RPC or socket layers
>     3. Drop asynchronous support, so that we have a reliable
>        userspace-defined context.
> 
> 1) involves a user space api change, which will bring down the iron fist
> of the Finn.

The problem with 1) is that rpcbind uses a special feature of AF_LOCAL to protect registrations from being removed by a malicious or ignorant registrant.  That's why I added AF_LOCAL.  Somehow we would have to replace that feature.

> 2) involves cooperation from the VFS and socket folks which doesn't seem
> to be happening.

Yep, I'm aware of that.

> so that leaves (3), which is perfectly doable since we do _not_ want to
> expose the rpc layer to anything outside the kernel. It's not intended
> as a generic libtirpc...

I hoped for a better alternative, but I see that folks do not have the patience for that.  ;-)

> 
>> If we were to go with using a synchronous connect, however, I think there should be some kind of safety check to make sure the xs connect function is not being invoked from an asynchronous context.  This is a restriction that does not exist for other transports supported by the kernel RPC client, so it should be underscored in the code.
> 
> void xs_connect_local(struct rpc_task *task)
> {
> 	if (RPC_IS_ASYNC(task))
> 		rpc_exit(task, -ENOTCONN);
> .....
> }
> 
> ...done.

That's what I had in mind.  I might even add a WARN_ON_ONCE().

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




