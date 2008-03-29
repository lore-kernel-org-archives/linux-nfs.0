From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] SUNRPC: have soft RPC tasks return -ETIMEDOUT instead
 of -EIO on major connect timeout
Date: Sat, 29 Mar 2008 16:53:20 -0400
Message-ID: <20080329165320.52860c8a@tleilax.poochiereds.net>
References: <1206794957-17010-1-git-send-email-jlayton@redhat.com>
	<1206809051.8480.33.camel@heimdal.trondhjem.org>
	<20080329152424.6857ee86@tleilax.poochiereds.net>
	<1206821149.8455.13.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
	linux-kernel@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:34019 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754431AbYC2Uxb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 29 Mar 2008 16:53:31 -0400
In-Reply-To: <1206821149.8455.13.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 29 Mar 2008 16:05:49 -0400
Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> 
> On Sat, 2008-03-29 at 15:24 -0400, Jeff Layton wrote:
> > On Sat, 29 Mar 2008 12:44:11 -0400
> > Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> > > Userland has the clnt_geterr() function that returns more detailed 'RPC
> > > level' errors. While that 'error function call' approach doesn't work in
> > > a multi-threaded environment, we might still be able to add the
> > > equivalent of a pointer to an 'rpc_err' structure to the rpc_task, and
> > > then have functions like call_timeout() (and especially call_verify()!)
> > > fill in more detailed error info if that pointer is non-zero?
> > >
> > 
> > I'm not sure we really need this, do we?
> > 
> > Should it really be the business of the RPC layer to sanitize the
> > tk_status like this? It seems like the NFS layer ought to be
> > translating "illegal" errors from the RPC layer into more generic ones
> > where needed rather than relying on the RPC layer to do it, though
> > maybe I'm not thinking about the RPC layer in the right way here...
> 
> Yes and no. The RPC error reports are sometimes more complex than what
> we can fit into a single 32-bit error code. I'm thinking in particular
> of the RPC_AUTH_* errors (EACCESS just doesn't do them justice), and
> RPC_PROG_MISMATCH error.
> 
> In the case of RPC_PROG_MISMATCH, it would, for instance, be really
> useful for the in-kernel mount code to be able to also retrieve the
> 'mismatch_info' structure (see RFC1831), which tells you exactly which
> program versions are actually supported on that port.
> 
> An extra optional pointer to a structure in the rpc_task won't cost us
> much, but could possibly provide a lot of interesting information that
> we are currently ignoring.
> 

Ok, that makes sense. Yes, adding a new pointer to the rpc_task doesn't
sound too costly. The hard part is getting this pointer from the higher
layers that would interpret this info to the correct RPC functions that
could populate it.

I don't really have a good feel for how we'd populate this new pointer
as well. For instance, you'd want to hang a mismatch_info struct on it 
for the case of RPC_PROG_MISMATCH, but in the case I was trying to fix
above, we'd just want a simple 32-bit error code. How will the RPC
engine know what this pointer points to? Or should we just make it a
new struct that has fields for each possibility?

-- 
Jeff Layton <jlayton@redhat.com>
