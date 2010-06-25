Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35660 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752897Ab0FYRsF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jun 2010 13:48:05 -0400
Date: Fri, 25 Jun 2010 13:47:54 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org, trond.myklebust@fys.uio.no,
        Staubach_Peter@emc.com, bfields@fieldses.org
Subject: Re: [PATCH 1/2] sunrpc: split the vs_hidden flag into TCP and UDP
 variants (try #2)
Message-ID: <20100625134754.51e313fa@tlielax.poochiereds.net>
In-Reply-To: <4C24D95F.6090301@oracle.com>
References: <1277480946-23844-1-git-send-email-jlayton@redhat.com>
	<4C24D057.4090403@oracle.com>
	<20100625120710.2ead8998@tlielax.poochiereds.net>
	<4C24D95F.6090301@oracle.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 25 Jun 2010 12:29:19 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

> On 06/25/10 12:07 PM, Jeff Layton wrote:
> > On Fri, 25 Jun 2010 11:50:47 -0400
> > Chuck Lever<chuck.lever@oracle.com>  wrote:
> >
> >> So this may be a dumb question, but why can't you just change the NFSv4
> >> server not to create an RPC listener for UDP?
> >>
> >
> > Unless I'm misunderstanding the code, it's not really structured to do
> > what you suggest. We don't really create version-specific listeners. We
> > create listeners for nfsd. We then hook a svc_program to nfsd that has
> > multiple svc_version structs attached to it. Requests come into nfsd,
> > it parses them and dispatches them to the appropriate version handlers.
> >
> > Now that I think about it though...it may be a little cleaner to create
> > a nfsd4_dispatch routine that does this check and then calls the generic
> > nfsd_dispatch. That way we wouldn't penalize NFSv2/3 with this check. I
> > may respin this patch and do it that way once others have a chance to
> > comment.
> 
> Alright, I thought that we had the same issue for NFS/RMDA.  Basically 
> we want to allow NFSv3 over RDMA, but we don't want to allow NFSv4 over 
> RDMA (yet).
> 
> Apparently there's nothing in rpc.nfsd or other parts of user space that 
> allow fine-grained selection of NFSD transports.  Maybe we should 
> consider that.
> 
> Allowing UDP for legacy NFSv2 clients, but accepting only TCP for NFSv3 
> and NFSv4, is a configuration that might be desirable, for example.
> 

This just seems overblown to me...I really don't think any of this is
worth changing the userspace interfaces for.

We have a rather simple problem that needs to be solved -- we want to
reject NFSv4 over UDP since it's not RFC compliant.

nfsd shares the same sockets between all NFS versions. We can't change
that since you don't know what NFS version you're getting a call for
until you read in the data. There's really no way around this.

Once we read in the RPC, we can deal with it in several different
ways. I have one here, a simple check for IPPROTO_UDP (assuming I
change the patch do add a new vs_dispatch wrapper routine for NFSv4).

We could try to do this in different ways -- maybe add some new per-xprt
abstraction that sits between the svc_program and svc_version.
Abstraction layers have a cost too though and I'm not at all convinced
that cost will be lower than what I'm proposing here.

-- 
Jeff Layton <jlayton@redhat.com>
