Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:54129 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753677Ab3KLRll (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Nov 2013 12:41:41 -0500
Date: Tue, 12 Nov 2013 12:41:33 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Weston Andros Adamson <dros@netapp.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>, bfields@fieldses.org
Subject: Re: Thread overran stack, or stack corrupted BUG on mount
Message-ID: <20131112124133.7e9be6ea@tlielax.poochiereds.net>
In-Reply-To: <6EF1AA2E-18B4-42F9-8ADD-8BBF86A9FD4A@oracle.com>
References: <2C73011F-0939-434C-9E4D-13A1EB1403D7@netapp.com>
	<20131112105539.4f804fc6@tlielax.poochiereds.net>
	<20131112112021.1a0a60ca@tlielax.poochiereds.net>
	<E4B641E5-34C5-4779-8FAB-DCB6C74D1546@oracle.com>
	<1384277451.4779.24.camel@leira.trondhjem.org>
	<6EF1AA2E-18B4-42F9-8ADD-8BBF86A9FD4A@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 12 Nov 2013 12:33:28 -0500
Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On Nov 12, 2013, at 12:30 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
> 
> > On Tue, 2013-11-12 at 11:23 -0500, Chuck Lever wrote:
> >> On Nov 12, 2013, at 11:20 AM, Jeff Layton <jlayton@redhat.com> wrote:
> >>> Ok, I think I see the problem. The looping comes from this block in
> >>> nfs4_discover_server_trunking:
> >>> 
> >>> -----------------[snip]-----------------
> >>>       case -NFS4ERR_CLID_INUSE:
> >>>       case -NFS4ERR_WRONGSEC:
> >>>               clnt = rpc_clone_client_set_auth(clnt, RPC_AUTH_UNIX);
> >>>               if (IS_ERR(clnt)) {
> >>>                       status = PTR_ERR(clnt);
> >>>                       break;
> >>>               }
> >>>               /* Note: this is safe because we haven't yet marked the
> >>>                * client as ready, so we are the only user of
> >>>                * clp->cl_rpcclient
> >>>                */
> >>>               clnt = xchg(&clp->cl_rpcclient, clnt);
> >>>               rpc_shutdown_client(clnt);
> >>>               clnt = clp->cl_rpcclient;
> >>>               goto again;
> >>> -----------------[snip]-----------------
> >>> 
> >>> ...so in the case of the reproducer, we get back -NFS4ERR_CLID_IN_USE,
> >>> at that point we call rpc_clone_client_set_auth(), which creates a new
> >>> rpc_clnt, but it's created as a child of the original.
> >>> 
> >>> When rpc_shutdown_client is called, the original clnt is not destroyed
> >>> because the child still holds a reference to it. So, we go and try the
> >>> call again and it fails with the same error over and over again, and we
> >>> end up with a long chain of rpc_clnt's.
> >>> 
> >>> How that ends up smashing the stack, I'm not sure though. I'm also not
> >>> sure of the remedy. It seems like we might ought to have some upper
> >>> bound on the number of SETCLIENTID attempts?
> >> 
> >> CLID_INUSE is supposed to be a permanent error now.  I think one retry, if any, is all that is appropriate.
> > 
> > Right. If we hit CLID_INUSE in nfs4_discover_server_trunking then
> > 
> > a) we know this is a server that we've already mounted
> > b) we know that either nfs4_init_client set us up with RPC_AUTH_UNIX to
> > begin with, or that rpc.gssd was started only after we'd already sent a
> > SETCLIENTID/EXCHANGE_ID using RPC_AUTH_UNIX to this server
> > 
> > so the correct thing to do is to retry once if we know that we're not
> > already using AUTH_SYS, and then to EPERM.
> 
> Agree.  Sorry I didn't spell that out.
> 
> 
> > Now that said, I agree that this should not be able to trigger a stack
> > overflow. Is this NFSv4 or NFSv4.1/NFSv4.2? Have either of you (Jeff and
> > Dros) tried enabling DEBUG_STACKOVERFLOW?
> > 

My kernel says it's on -- but the comments on stack_overflow_check
aren't encouraging for finding this sort of thing:

/*
 * Probabilistic stack overflow check:
 *
 * Only check the stack in process context, because everything else
 * runs on the big interrupt stacks. Checking reliably is too expensive,
 * so we just check from interrupts.
 */


...as to Bruce's earlier question, the recursion in how this stuff is
freed does seem a bit spooky...

Perhaps we could try doing this iteratively somehow such that it
doesn't recurse

...and/or maybe we should BUG() or WARN() if you create a chain of
clients more than 10-20 deep?

-- 
Jeff Layton <jlayton@redhat.com>
