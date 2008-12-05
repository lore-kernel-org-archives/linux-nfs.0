From: Neil Brown <neilb@suse.de>
Subject: Re: Make sm-notify faster if there are no servers to notify
Date: Fri, 5 Dec 2008 14:34:54 +1100
Message-ID: <18744.41310.635618.148281@notabene.brown>
References: <20081029173750.GD31936@fieldses.org>
	<1225302305994@dmwebmail.dmwebmail.chezphil.org>
	<20081029184153.GE31936@fieldses.org>
	<5AB39614-D03F-43DF-BCD2-2B2501A79D65@oracle.com>
	<20081029211145.GE1406@fieldses.org>
	<49183A12.7010707@RedHat.com>
	<20081204211057.GC9593@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Dickson <SteveD@redhat.com>,
	Chuck Lever <chuck.lever@oracle.com>,
	Phil Endecott <phil_bnaqb_endecott-wZDNlLIRyE5g9hUCZPvPmw@public.gmane.org>,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:58372 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750720AbYLEDex (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Dec 2008 22:34:53 -0500
In-Reply-To: message from J. Bruce Fields on Thursday December 4
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thursday December 4, bfields@fieldses.org wrote:
> 
> Any progress on this?  I don't think we can release in the current
> state, since as far as I can tell that means on a new system, unless the
> install scripts create /var/lib/nfs/state, neither sm-notify nor statd
> ever writes to /proc/sys/fs/nfs/nsm_local_state, and (without testing)
> it looks to me like that means lockd defaults to a state of 0, which is
> nonsense?

Why is '0' nonsense?
The only real requirement on 'state' is that it changes when the host
reboots while some peer is monitoring it.  Even if it got reset to
zero every time the sm and sm.bak became empty it would still work
just fine.  If we reboot and find that both sm and sm.bak are empty
there is really no point in changing 'state'.


I think it would still be valuable to replace the 'sync' with two
'fsync's, one of the file, one on the directory.
This may not be a win on ext3 today (I'm not 100% certain about that)
but there are other filesystems and more seem to be coming.

NeilBrown
