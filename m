Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:38634 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756034Ab3GKPUm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Jul 2013 11:20:42 -0400
Date: Thu, 11 Jul 2013 11:20:36 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Malahal Naineni <malahal@us.ibm.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>
Subject: Re: corruption due to loss of lock
Message-ID: <20130711112036.03ffe1cc@tlielax.poochiereds.net>
In-Reply-To: <1373553181.9207.2.camel@leira.trondhjem.org>
References: <20130613184737.GA25713@us.ibm.com>
	<20130711071346.03b946bd@corrin.poochiereds.net>
	<1373552348.2871.2.camel@leira.trondhjem.org>
	<20130711102840.272ce3fa@tlielax.poochiereds.net>
	<1373553181.9207.2.camel@leira.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 11 Jul 2013 14:33:02 +0000
"Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Thu, 2013-07-11 at 10:28 -0400, Jeff Layton wrote:
> > On Thu, 11 Jul 2013 14:19:10 +0000
> > "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
> > 
> > > On Thu, 2013-07-11 at 07:13 -0400, Jeff Layton wrote:
> > > > On Thu, 13 Jun 2013 13:47:37 -0500
> > > > Malahal Naineni <malahal@us.ibm.com> wrote:
> > > > 
> > > > > Hi Trond,
> > > > > 
> > > > > I saw Bryan's patches here https://patchwork.kernel.org/patch/987402/
> > > > > that fix issues after loss of a lock.  What is the status on this patch
> > > > > set? Do they need more work? We have an application that uses range
> > > > > locks on a file. Two threads from two different clients end up writing
> > > > > to the same a file due to this bug after a lease expiry from a client.
> > > > > 
> > > > > Regards, Malahal.
> > > > 
> > > > (cc'ing Bryan since he did the original set)
> > > > 
> > > > Yeah, this set would be a nice thing to have. A couple of comments:
> > > > 
> > > > - I still think it would be best to make SIGLOST its own signal, but as
> > > >   Bryan points out, it would need to be larger than SIGRTMAX. I'm
> > > >   not sure that's possible on all arches with the way the RT signals
> > > >   were done. It's probably worth investigating that though before
> > > >   settling on SIGIO since it would be hard to change that retroactively.
> > > > 
> > > > - This is not really a v4.1 specific thing. It should also be done for
> > > >   v4.0 and v2/3, though the latter two really need to be done within
> > > >   lockd.
> > > 
> > > SIGLOST is not part of any standard. It is a hack that has been adopted
> > > by IBM and Solaris.
> > > 
> > > The POSIXly correct way to do this is to use EBADF to warn the
> > > application that the file descriptor is no longer valid (in the sense
> > > that the server is no longer honouring the lock) and EIO in order to
> > > warn it that data may have been lost.
> > > 
> > 
> > It is a hack...I won't argue there
> > 
> > I'm not sure that returning errors is really the best approach though.
> > In some cases, the fd may be fine. It may only be the lock that has
> > been lost.
> > 
> > With a signal, the program has more of a choice as to whether it cares
> > about lost locks and is more immediate when the problem occurs. An
> > error code seems like it might cause a lot of grief for programs that
> > aren't expecting that sort of behavior.
> 
> EBADF is a error that has an obvious meaning in POSIX: you need to
> reopen the file and re-establish any locks.

Well, EBADF means "Bad file descriptor". Consider the v2/3 case -- the
fd might still be usable, it's only my lock that has been lost. One
might consider that to mean that we shouldn't use that fd anymore, but
that's a behavioral change any way you slice it...

> How is that not better than
> receiving a signal they won't be expecting? Consider that we'd have to
> overload SIGIO, which has a completely different meaning in POSIX...
> 

That's the main reason that I think we want a new signal for this. The
default on SIGLOST should be to ignore it, and then that would allow
processes to opt-in to paying attention to it.

-- 
Jeff Layton <jlayton@redhat.com>
