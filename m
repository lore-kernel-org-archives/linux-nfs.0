From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [patch] fix statd -n
Date: Mon, 21 Apr 2008 07:01:07 -0400
Message-ID: <20080421070107.454cfad2@tleilax.poochiereds.net>
References: <24c1515f0804170938s23fe3ea3pfe77355ed01d8bbf@mail.gmail.com>
	<20080418173646.GC19038@fieldses.org>
	<480902CA.1070805@redhat.com>
	<48090356.9020703@redhat.com>
	<20080418203225.GD28277@fieldses.org>
	<24c1515f0804181346g5867fa1fqfbbcd13af25027cb@mail.gmail.com>
	<20080421000214.GA5453@fieldses.org>
	<24c1515f0804201749x47bee916y9970fe1102bfb5@mail.gmail.com>
	<20080421021153.GC5453@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Janne Karhunen <janne.karhunen@gmail.com>,
	Peter Staubach <staubach@redhat.com>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:41504 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754488AbYDULBM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Apr 2008 07:01:12 -0400
In-Reply-To: <20080421021153.GC5453@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 20 Apr 2008 22:11:53 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Sun, Apr 20, 2008 at 08:49:52PM -0400, Janne Karhunen wrote:
> > On Sun, Apr 20, 2008 at 8:02 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > 
> > >  > I didn't get the idea. So the idea is to use multiple sockets,
> > >  > one bound to LOOPBACK and one to external interface?
> > >
> > >  I suppose so.  One socket would be for communication for the local
> > >  kernel nfsd, one for communication with statd peers.
> > 
> > Ok, but that's really quite intrusive - my goal with that
> > patch was to minimize the amount of changes. Sure,
> > we can rework larger part of it if you think is better
> > that way.
> 
> Yes.  Hopefully it's not too bad....
> 
> > >  > Complicated and unclean in my opinion: one address
> > >  > should suffice.
> > >
> > >  The advantage is that it would require no changes to the kernel or
> > >  kernel interfaces, and would also solve the problem for people that
> > >  don't want to upgrade their kernels.
> > 
> > Right, but that's hardly an issue with Linux. You need
> > to do that twice per week anyway ;)
> > 
> > 
> > >  The "rpc over lo" interface to the kernel's lockd is simple enough, and
> > >  I'd rather not replace it with "rpc over either lo or the interface
> > >  specified via sysctl" unless there's a really clear advantage.
> > >
> > >  (Also, would your patch mean lockd could accept requests that could have
> > >  spoofed source addresses?)
> > 
> > Yes, but loopback can also be spoofed.
> 
> Is that true?  I thought the kernel discarded packets from interfaces
> other than lo claiming to be from 127.*.*.*.
> 

I think that's the case only if you have rp_filter turned on. It
usually is these days, but there are some situations where it doesn't
do what's expected (vlans, for instance), and has to be disabled.

-- 
Jeff Layton <jlayton@redhat.com>
