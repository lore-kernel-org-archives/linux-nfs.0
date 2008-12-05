From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Make sm-notify faster if there are no servers to notify
Date: Thu, 4 Dec 2008 22:58:03 -0500
Message-ID: <20081205035803.GC15115@fieldses.org>
References: <20081029173750.GD31936@fieldses.org> <1225302305994@dmwebmail.dmwebmail.chezphil.org> <20081029184153.GE31936@fieldses.org> <5AB39614-D03F-43DF-BCD2-2B2501A79D65@oracle.com> <20081029211145.GE1406@fieldses.org> <49183A12.7010707@RedHat.com> <20081204211057.GC9593@fieldses.org> <18744.41310.635618.148281@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Dickson <SteveD@redhat.com>,
	Chuck Lever <chuck.lever@oracle.com>,
	Phil Endecott <phil_bnaqb_endecott-wZDNlLIRyE5g9hUCZPvPmw@public.gmane.org>,
	linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:41276 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750847AbYLED6Q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Dec 2008 22:58:16 -0500
In-Reply-To: <18744.41310.635618.148281-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 05, 2008 at 02:34:54PM +1100, Neil Brown wrote:
> On Thursday December 4, bfields@fieldses.org wrote:
> > 
> > Any progress on this?  I don't think we can release in the current
> > state, since as far as I can tell that means on a new system, unless the
> > install scripts create /var/lib/nfs/state, neither sm-notify nor statd
> > ever writes to /proc/sys/fs/nfs/nsm_local_state, and (without testing)
> > it looks to me like that means lockd defaults to a state of 0, which is
> > nonsense?
> 
> Why is '0' nonsense?

Even numbers are supposed to mean that a host is down, odd that it's up.
In practice noone ever uses that fact--they only ever advertise odd
numbers.  So we might get away with using an even number.  But then
again a peer would be in its rights to check the parity and complain,
and some may well do that.

> The only real requirement on 'state' is that it changes when the host
> reboots while some peer is monitoring it.  Even if it got reset to
> zero every time the sm and sm.bak became empty it would still work
> just fine.

Hm, I don't know; it might be that an inconveniently timed network
partition combined with nsm states that repeat themselves could prevent
a client from knowing about some reboot that it should have known about.

It's safer to keep a counter and ensure that the state never repeats
(well, anyway, not until it overflows after a few billion reboots).

> If we reboot and find that both sm and sm.bak are empty
> there is really no point in changing 'state'.

I think I've convinced myself of that, yes.  For the purposes of
locking, a reboot which didn't require notifying any client may as well
have not been a reboot, since no state was lost.

But we should at least make sure that the state is properly initialized
and nondecreasing.

> I think it would still be valuable to replace the 'sync' with two
> 'fsync's, one of the file, one on the directory.

Sure, may as well.--b.

> This may not be a win on ext3 today (I'm not 100% certain about that)
> but there are other filesystems and more seem to be coming.
