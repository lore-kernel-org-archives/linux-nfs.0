Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e33.co.us.ibm.com ([32.97.110.151]:46919 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756196Ab3GKPkG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Jul 2013 11:40:06 -0400
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Thu, 11 Jul 2013 15:40:05 -0000
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 7FEF61FF002B
	for <linux-nfs@vger.kernel.org>; Thu, 11 Jul 2013 09:34:44 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6BFe24W107940
	for <linux-nfs@vger.kernel.org>; Thu, 11 Jul 2013 09:40:02 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6BFe2sA008338
	for <linux-nfs@vger.kernel.org>; Thu, 11 Jul 2013 09:40:02 -0600
Date: Thu, 11 Jul 2013 10:39:59 -0500
From: Malahal Naineni <malahal@us.ibm.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>
Subject: Re: corruption due to loss of lock
Message-ID: <20130711153959.GA15010@us.ibm.com>
References: <20130613184737.GA25713@us.ibm.com>
 <20130711071346.03b946bd@corrin.poochiereds.net>
 <1373552348.2871.2.camel@leira.trondhjem.org>
 <20130711102840.272ce3fa@tlielax.poochiereds.net>
 <1373553181.9207.2.camel@leira.trondhjem.org>
 <20130711112036.03ffe1cc@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130711112036.03ffe1cc@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff Layton [jlayton@redhat.com] wrote:
> On Thu, 11 Jul 2013 14:33:02 +0000
> "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
> 
> > On Thu, 2013-07-11 at 10:28 -0400, Jeff Layton wrote:
> > > On Thu, 11 Jul 2013 14:19:10 +0000
> > > "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
> > > 
> > > > On Thu, 2013-07-11 at 07:13 -0400, Jeff Layton wrote:
> > > > > On Thu, 13 Jun 2013 13:47:37 -0500
> > > > > Malahal Naineni <malahal@us.ibm.com> wrote:
> > > > > 
> > > > > > Hi Trond,
> > > > > > 
> > > > > > I saw Bryan's patches here https://patchwork.kernel.org/patch/987402/
> > > > > > that fix issues after loss of a lock.  What is the status on this patch
> > > > > > set? Do they need more work? We have an application that uses range
> > > > > > locks on a file. Two threads from two different clients end up writing
> > > > > > to the same a file due to this bug after a lease expiry from a client.
> > > > > > 
> > > > > > Regards, Malahal.
> > > > > 
> > > > > (cc'ing Bryan since he did the original set)
> > > > > 
> > > > > Yeah, this set would be a nice thing to have. A couple of comments:
> > > > > 
> > > > > - I still think it would be best to make SIGLOST its own signal, but as
> > > > >   Bryan points out, it would need to be larger than SIGRTMAX. I'm
> > > > >   not sure that's possible on all arches with the way the RT signals
> > > > >   were done. It's probably worth investigating that though before
> > > > >   settling on SIGIO since it would be hard to change that retroactively.
> > > > > 
> > > > > - This is not really a v4.1 specific thing. It should also be done for
> > > > >   v4.0 and v2/3, though the latter two really need to be done within
> > > > >   lockd.
> > > > 
> > > > SIGLOST is not part of any standard. It is a hack that has been adopted
> > > > by IBM and Solaris.
> > > > 
> > > > The POSIXly correct way to do this is to use EBADF to warn the
> > > > application that the file descriptor is no longer valid (in the sense
> > > > that the server is no longer honouring the lock) and EIO in order to
> > > > warn it that data may have been lost.
> > > > 
> > > 
> > > It is a hack...I won't argue there
> > > 
> > > I'm not sure that returning errors is really the best approach though.
> > > In some cases, the fd may be fine. It may only be the lock that has
> > > been lost.
> > > 
> > > With a signal, the program has more of a choice as to whether it cares
> > > about lost locks and is more immediate when the problem occurs. An
> > > error code seems like it might cause a lot of grief for programs that
> > > aren't expecting that sort of behavior.
> > 
> > EBADF is a error that has an obvious meaning in POSIX: you need to
> > reopen the file and re-establish any locks.
> 
> Well, EBADF means "Bad file descriptor". Consider the v2/3 case -- the
> fd might still be usable, it's only my lock that has been lost. One
> might consider that to mean that we shouldn't use that fd anymore, but
> that's a behavioral change any way you slice it...
> 
> > How is that not better than
> > receiving a signal they won't be expecting? Consider that we'd have to
> > overload SIGIO, which has a completely different meaning in POSIX...
> > 
> 
> That's the main reason that I think we want a new signal for this. The
> default on SIGLOST should be to ignore it, and then that would allow
> processes to opt-in to paying attention to it.

We should split that patchset into two.

1. we should return EBADF/EIO (debatable which one) for operations that
   require lock after loss of lock.
2. sending a signal (SIGIO/SIGLOST).

The first one is critical to avoid corruption, and second one is needed
for graceful recovery.

Regards, Malahal.

