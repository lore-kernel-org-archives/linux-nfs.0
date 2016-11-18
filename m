Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:51772 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752693AbcKRUrz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 18 Nov 2016 15:47:55 -0500
Date: Fri, 18 Nov 2016 15:47:54 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Ulrich Gemkow <ulrich.gemkow@ikr.uni-stuttgart.de>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: NFS Server prevents access to files on different scenarios (lock
 problem?)
Message-ID: <20161118204754.GG5424@fieldses.org>
References: <201611172132.47523.ulrich.gemkow@ikr.uni-stuttgart.de>
 <201611172234.20638.ulrich.gemkow@ikr.uni-stuttgart.de>
 <20161118165828.GA5424@fieldses.org>
 <201611181955.51758.ulrich.gemkow@ikr.uni-stuttgart.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <201611181955.51758.ulrich.gemkow@ikr.uni-stuttgart.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 18, 2016 at 07:55:50PM +0100, Ulrich Gemkow wrote:
> On Friday 18 November 2016, J. Bruce Fields wrote:
> > On Thu, Nov 17, 2016 at 10:34:20PM +0100, Ulrich Gemkow wrote:
> > > I found the 90sec lease time period but the timeout is sometimes
> > > much longer than 90 sec, often up to 3minutes or longer. Is there
> > > something which may cause these longer delays (I played with the
> > > 90sec constant and it did not help :-)
> > 
> > A delegation is the only thing that I can think of that would prevent a
> > file from being deleted on the server (by that you mean, not even a "rm
> > blockfiled" run from a terminal on the server works?)  Delegations
> > should definitely be forcibly revoked after the lease period passes.
> > Note that you need to reboot (well, restart the nfs server) after
> > changing the lease period, or the change will not take effect.
> 
> Thanks for this hint, I will disable delegations. But - the timeout
> is for sure longer than 90 seconds in many cases. Can the reason be
> a bad interaction between dropped tcp-connections (which may require
> some time to be noticed) and the nfs server state(s)?

If the problem is a delegation, then what happens is essentially:

	- you try to modify (or rename, or remove) the delated file.
	- the server sets a timer for the lease time (90s by default).
	- at the same time, the server notifies the client that it
	  should return the delegation.
	- if the timer expires then the server gives up and forcibly
	  removes the delegation, allowing your original operation to
	  proceed.

So tcp connections and stuff are details, what matters to the server is
how much time has elapsed since you attempted an operation that
conflicts with the delegation.  If that's significantly more than the
lease period, then something's wrong.  So if you have a case where
that's reliably too long, that would be interesting.

> > > > For example, if the client held some delegations that it didn't return
> > > > on unmount, and then it denied knowledge of them when the server tried
> > > > to recall them, then the server would have to wait a lease period to
> > > > forcibly remove them.  But, the client should be returning delegations
> > > > on unmount, so I don't see how this happens.
> > > > 
> > > > For locks and opens and other state, again the client should be
> > > > returning them on unmount.  And anyway the server isn't going to
> > > > forcibly remove those ever, unless the entire client goes away
> > > > completely, e.g. in a client crash or network partition.
> > > > 
> > > > So, I don't know.  Are you sure there aren't client crashes or network
> > > > problems?
> > > 
> > > It happens that clients crash
> > 
> > I'm not sure what you mean there--do you mean clients are involved in
> > all of these cases, or some of them?
> 
> Cause for the client reboots are impatient users which switch power
> off-and-on when a hang happens. So the crashes (reboots) are not
> directly related but the hangs happen often after such unwanted
> reboots.

Hm.  So their stale state should be cleared out either 90 seconds after
the client turned off, or as soon as the client comes back up and
remounts, whichever comes first.  If that's not happening, again that
sounds like a potentially interesting bug.

--b.
