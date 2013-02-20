Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51107 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751909Ab3BTXDk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Feb 2013 18:03:40 -0500
Date: Wed, 20 Feb 2013 18:03:37 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Simo Sorce <simo@redhat.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: synchronous AF_LOCAL connect
Message-ID: <20130220230337.GC3575@fieldses.org>
References: <20130218225424.GD3391@fieldses.org>
 <20130220154751.GH14606@fieldses.org>
 <2F275139-9861-4414-8C9F-BD74544C9AD7@oracle.com>
 <20130220160350.GJ14606@fieldses.org>
 <EA9EE56A-73BB-4866-AA86-1EE4150AFE87@oracle.com>
 <20130220163424.GK14606@fieldses.org>
 <FB21B277-FA7D-490C-B389-58A91C46B490@oracle.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9235D7E49@SACEXCMBX04-PRD.hq.netapp.com>
 <1361381561.12328.441.camel@willson.li.ssimo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1361381561.12328.441.camel@willson.li.ssimo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 20, 2013 at 12:32:41PM -0500, Simo Sorce wrote:
> On Wed, 2013-02-20 at 17:27 +0000, Myklebust, Trond wrote:
> > On Wed, 2013-02-20 at 12:04 -0500, Chuck Lever wrote:
> > 
> > > Yes, but AF_LOCAL is supposed to be a generic transport for RPC.  This is not a feature we just made up, it's actually a well-defined API that exists on other platforms (it's even specified in RFCs).  Right now I would hesitate to restrict the use of AF_LOCAL upcalls to only synchronous contexts, because eventually we may want to use the transport in asynchronous contexts.
> > 
> > The whole problem is that it is a piss-poorly defined feature in an
> > asynchronous kernel context.
> > 
> > Sockets carry around a well defined net namespace context that allow
> > them to resolve IP addresses. However they carry none of the file
> > namespace context information that is required to make sense of AF_LOCAL
> > "addresses".
> > 
> > IOW we have 3 options:
> > 
> >      1. Drop AF_LOCAL support altogether
> >      2. Add file namespace context to the RPC or socket layers
> >      3. Drop asynchronous support, so that we have a reliable
> >         userspace-defined context.
> > 
> > 1) involves a user space api change, which will bring down the iron fist
> > of the Finn.
> > 2) involves cooperation from the VFS and socket folks which doesn't seem
> > to be happening.
> > 
> > so that leaves (3), which is perfectly doable since we do _not_ want to
> > expose the rpc layer to anything outside the kernel. It's not intended
> > as a generic libtirpc...
> > 
> > > If we were to go with using a synchronous connect, however, I think there should be some kind of safety check to make sure the xs connect function is not being invoked from an asynchronous context.  This is a restriction that does not exist for other transports supported by the kernel RPC client, so it should be underscored in the code.
> > 
> > void xs_connect_local(struct rpc_task *task)
> > {
> > 	if (RPC_IS_ASYNC(task))
> > 		rpc_exit(task, -ENOTCONN);
> > .....
> > }
> > 
> > ...done.
> > 
> 
> This seems the most reasonable approach to me too, and makes the code
> simpler for now.

OK, I've added that check and fixed some other bugs (thanks to Chuck for
some help in IRC).

I think that gets rpcbind working in containers fine.

gss-proxy has one more problem: it needs to do upcalls from nfsd threads
which won't have the right filesystem namespace.

I get a write from gss-proxy when it starts and can do an initial
connect then using its context.  But if we disconnect after that I'm
stuck.

Does it cause any problems if I just set the idle_timeout to 0 for
AF_LOCAL?

--b.
