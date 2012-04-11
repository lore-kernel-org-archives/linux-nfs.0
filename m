Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54375 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756089Ab2DKSWU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Apr 2012 14:22:20 -0400
Date: Wed, 11 Apr 2012 14:22:18 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: Jeff Layton <jlayton@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH][RFC] nfsd/lockd: have locks_in_grace take a sb arg
Message-ID: <20120411182218.GB31025@fieldses.org>
References: <20120410081612.65dd25fa@tlielax.poochiereds.net>
 <4F842BAE.2010804@parallels.com>
 <20120410093900.20209d00@tlielax.poochiereds.net>
 <4F84493C.1040303@parallels.com>
 <20120410144505.58bca0b9@corrin.poochiereds.net>
 <4F855864.8050509@parallels.com>
 <20120411074822.0054eb36@tlielax.poochiereds.net>
 <4F85825E.4060104@parallels.com>
 <20120411171919.GA29903@fieldses.org>
 <4F85C15D.5060408@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <4F85C15D.5060408@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 11, 2012 at 09:37:33PM +0400, Stanislav Kinsbursky wrote:
> 11.04.2012 21:19, J. Bruce Fields пишет:
> >On Wed, Apr 11, 2012 at 05:08:46PM +0400, Stanislav Kinsbursky wrote:
> >>11.04.2012 15:48, Jeff Layton пишет:
> >>>>>>>One thing that puzzles me at the moment. We have two namespaces to deal
> >>>>>>>with -- the network and the mount namespace. With nfs client code,
> >>>>>>>everything is keyed off of the net namespace. That's not really the
> >>>>>>>case here since we have to deal with a local fs tree as well.
> >>>>>>>
> >>>>>>>When an nfsd running in a container receives an RPC, how does it
> >>>>>>>determine what mount namespace it should do its operations in?
> >>>>>>>
> >>>>>>
> >>>>>>We don't use mount namespaces, so that's why I wasn't thinking about it...
> >>>>>>But if we have 2 types of namespaces, then we have to tie  mount namesapce to
> >>>>>>network. I.e we can get desired mount namespace from per-net NFSd data.
> >>>>>>
> >>>>>
> >>>>>One thing that Bruce mentioned to me privately is that we could plan to
> >>>>>use whatever mount namespace mountd is using within a particular net
> >>>>>namespace. That makes some sense since mountd is the final arbiter of
> >>>>>who gets access to what.
> >>>>>
> >>>>
> >>>>Could you, please, give some examples? I don't get the idea.
> >>>>
> >>>
> >>>When nfsd gets an RPC call, it needs to decide in what mount namespace
> >>>to do the fs operations. How do we decide this?
> >>>
> >>>Bruce's thought was to look at what mount namespace rpc.mountd is using
> >>>and use that, but now that I consider it, it's a bit of a chicken and
> >>>egg problem really... nfsd talks to mountd via files in /proc/net/rpc/.
> >>>In order to talk to the right mountd, might you need to know what mount
> >>>namespace it's operating in?
> >>>
> >>
> >>Not really... /proc itself depens on pid namespace. /proc/net
> >>depends on current (!) network namespace. So we can't just lookup
> >>for this dentry.
> >>
> >>But, in spite of nfsd works in initial (init_net and friends)
> >>environment, we can get network namespace from RPC request. Having
> >>this, we can easily get desired proc entry (proc_net_rpc in
> >>sunrpc_net). So it looks like we can actually don't care about mount
> >>namespaces - we have our own back door.
> >
> >OK, good, that's what I was hoping for.  Then we call up to whatever
> >mountd is running in our network namespace, and for path lookups it's
> >whatever fs namespace that mountd is running in that's going to matter.
> >
> 
> The problem here, is that mountd is running in pid namespace - not net.

Every process runs in some pid namespace, and in some net namespace, so
I don't understand what you mean by that.

> What would happen, if we will have situation like below:
> 
> 	mountd A	mountd B
> 
> 	pid_ns		pid_ns
> 	  |		  |
> 	mnt_ns		mnt_ns
> 	  |		  |
> 	  -----	net_ns ----
> 
> Is it possible, BTW?
> It yes, that is such construction valid?

Looks like a mess, no.  I'd expect there to be only one rpc.mountd
running per network namespace.

--b.
