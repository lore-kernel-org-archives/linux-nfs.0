From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Make sm-notify faster if there are no servers to notify
Date: Thu, 4 Dec 2008 16:10:57 -0500
Message-ID: <20081204211057.GC9593@fieldses.org>
References: <20081029173750.GD31936@fieldses.org> <1225302305994@dmwebmail.dmwebmail.chezphil.org> <20081029184153.GE31936@fieldses.org> <5AB39614-D03F-43DF-BCD2-2B2501A79D65@oracle.com> <20081029211145.GE1406@fieldses.org> <49183A12.7010707@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chuck Lever <chuck.lever@oracle.com>,
	Phil Endecott <phil_bnaqb_endecott-wZDNlLIRyE5g9hUCZPvPmw@public.gmane.org>,
	linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:54284 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754016AbYLDVLV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Dec 2008 16:11:21 -0500
In-Reply-To: <49183A12.7010707-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 10, 2008 at 08:41:38AM -0500, Steve Dickson wrote:
> J. Bruce Fields wrote:
> > On Wed, Oct 29, 2008 at 04:30:32PM -0400, Chuck Lever wrote:
> >> I assume sync() is required because this logic performs a rename as well 
> >> as a simple write?
> > 
> > I think an fsync() on the containing directory (together with an fsync()
> > of the file itself) would do the job if you wanted to avoid the globaly
> > sync().  I don't think ext3 is capable of doing anything finer-grained
> > than a whole-filesystem sync, though, so this doesn't help many people
> > in practice right now.
> > 
> > In any case, the rename adds an extra level of safety by ensuring the
> > nsm state is updated atomically, so we shouldn't get rid of it.
> > 
> >>> Anyway, I think the nsm state updating shouldn't matter if you don't
> >>> even have any peers to notify.
> >> It probably does matter.
> >>
> >> When a system is initially installed, it likely does not have a state  
> >> file in /var/lib/nfs.  This may be harmless if it's not present;  
> >> rpc.statd probably does the right thing in this case.
> > 
> > The "right thing" in that case would be, I guess, to create a state file
> > with "0" in it.  It doesn't do that.  So this patch *does* break stuff.
> > Oops!
> > 
> > So should we revert it and do something else, or patch statd to create
> > a new state file if necessary?
> I have to agree with Chuck, that managing the state file from one 
> place is desirable... Although does it make sense to move that management
> into a init script? Maybe insuring the state is different before any
> daemons are started? Would we still need the sync()? 
>   
> > 
> >> However, the rest of the logic in nsm_get_state() is needed to bump the 
> >> system's state value properly after every reboot.  It may be  
> >> inconsequential if there were no mounts or no NFS clients during the  
> >> last reboot, but this is subtle.  I wouldn't bet on it.
> > 
> > If the state is only every communicated to hosts by notifications, then
> > if we're not notifying, the update of the state can't matter.
> I had the same notion... If there are no clients to notify, why would 
> any clients care if our state changed??  With that said.... I do have a
> sinking feeling that this patch will come back to bite us... 
> It was just too easy of a fix... :-)

Any progress on this?  I don't think we can release in the current
state, since as far as I can tell that means on a new system, unless the
install scripts create /var/lib/nfs/state, neither sm-notify nor statd
ever writes to /proc/sys/fs/nfs/nsm_local_state, and (without testing)
it looks to me like that means lockd defaults to a state of 0, which is
nonsense?

One possible compromise that I think would be correct might be to skip
the sync in the case where there are no peers to notify, instead of
exiting early in that case.  As long as a sync happens at some point
before we grant any locks (which statd can guarantee), I think that will
work....

--b.
