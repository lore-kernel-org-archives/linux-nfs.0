Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:25920 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759471Ab1JGC1N convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Oct 2011 22:27:13 -0400
Subject: Re: [nfsv4] back channel flags, CREATE_SESSION, BIND_CONN_TO_SESSION
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: "Matt W. Benjamin" <matt@linuxbox.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>,
        nfs-ganesha-devel <nfs-ganesha-devel@lists.sourceforge.net>,
        nfsv4 <nfsv4@ietf.org>
Date: Thu, 06 Oct 2011 22:27:11 -0400
In-Reply-To: <1412123218.108.1317931966754.JavaMail.root@thunderbeast.private.linuxbox.com>
References: <1412123218.108.1317931966754.JavaMail.root@thunderbeast.private.linuxbox.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1317954431.9466.27.camel@lade.trondhjem.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2011-10-06 at 16:12 -0400, Matt W. Benjamin wrote: 
> Hi Trond,
> 
> > For whom? We have already implemented a callback model that is working
> > fine for us. I have yet to see any evidence of the callback
> > scalability breakdown scenario that you claim as a motivation. What I
> > have (frequently) seen is scalability issues due to clients and
> > servers running out of free TCP ports.
> 
> For whom?  Well, I work primarily on servers.  I have worked experimentally on the Linux v41 client.  I am pretty sure I wasn't speaking of a "callback scalability breakdown."  I was discussing a tradeoff of ports for reduced overhead of flow control, lock contention, etc.  I wasn't trying to start an inflated theory discussion about these, I don't feel fully at ease doing so.  Still, I don't intuit that potential for port exhaustion trumps other considerations, it is one consideration among several.  I also mentioned some potential benefit for server implementations, such as the one we have been collaborating on.  I'd like to maximize its potential for success.
> 
> ----- "Trond Myklebust" <Trond.Myklebust@netapp.com> wrote:
> >
> > My objection is to the lack of a consensus on a single system for
> > implementing features. I'm tired of being told that the spec allows
> > you to do the same thing in 10 different ways, with an expectation
> > that we should implement all 10 ways.
> > If we can't find a single good way of implementing a feature, then my
> > preference is to drop support for that feature altogether (or to
> > choose one implementation and to stick with it). My expectation for a
> > standard is that it should aim to _reduce_ the number of different
> > implementations so that we can concentrate our development and testing
> > efforts. (BTW: pNFS is definitely not beyond criticism in this
> > respect.)
> 
> You think the standard should influence, so as to reduce, the number of competing implementations?  Maybe you meant 'implementation choices for <x> feature.'

I meant to say exactly what I said above: that a standard should reduce
the number of _different_ ways to implement the exact same feature. Find
something that works, and then add it to the standard. Do not waste my
time by adding experimental features and then coming back 9 months after
the standard has been published and stating that 'I just discovered that
feature A is better implemented using method X rather than method Y'.
That's not a standard: it's an experiment in progress.

> My expectation from NFSv4 is that there is some room for innovation and experimentation.  I don't think we can avoid this if we wish to compete effectively with ad hoc storage protocols.

I'm not trying to compete with ad-hoc storage protocols: they can always
find a niche market to peddle their ideas. Once somebody starts talking
about a standard, then the main concept is that there is room for
cooperation in order to achieve mutual benefit. I see no benefit here.

> > IOW: I can see valid reasons for why we should test the case where the
> > server refuses a mixed fore+back channel, but I don't see that as a
> > reason to implement a second back channel model. That requires us to
> > add code + tests (and perform regular regression tests) for that back
> > channel mode, as well as dealing with the case where that model of
> > operation too is rejected by the server.
> 
> I find I need to keep reminding my self what "assume" does.  But I assumed that the 5661 language for negotiating a back channel was in the draft (standard) because it added value to someone, and perhaps was implemented in some environment.  If so, perhaps such a person will chime in with an opinion.

Then you need to communicate that value to me. I never signed an
agreement to implement all of RFC5661.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

