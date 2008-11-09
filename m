From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Make sm-notify faster if there are no servers to notify
Date: Sun, 9 Nov 2008 14:25:28 -0500
Message-ID: <20081109192528.GE25568@fieldses.org>
References: <20081029173750.GD31936@fieldses.org> <1225302305994@dmwebmail.dmwebmail.chezphil.org> <20081029184153.GE31936@fieldses.org> <5AB39614-D03F-43DF-BCD2-2B2501A79D65@oracle.com> <20081029211145.GE1406@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Phil Endecott <phil_bnaqb_endecott-wZDNlLIRyE5g9hUCZPvPmw@public.gmane.org>,
	linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:53157 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755647AbYKITZd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 9 Nov 2008 14:25:33 -0500
In-Reply-To: <20081029211145.GE1406@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 29, 2008 at 05:11:45PM -0400, bfields wrote:
> On Wed, Oct 29, 2008 at 04:30:32PM -0400, Chuck Lever wrote:
> > I assume sync() is required because this logic performs a rename as well 
> > as a simple write?
> 
> I think an fsync() on the containing directory (together with an fsync()
> of the file itself) would do the job if you wanted to avoid the globaly
> sync().  I don't think ext3 is capable of doing anything finer-grained
> than a whole-filesystem sync, though, so this doesn't help many people
> in practice right now.
> 
> In any case, the rename adds an extra level of safety by ensuring the
> nsm state is updated atomically, so we shouldn't get rid of it.
> 
> >> Anyway, I think the nsm state updating shouldn't matter if you don't
> >> even have any peers to notify.
> >
> > It probably does matter.
> >
> > When a system is initially installed, it likely does not have a state  
> > file in /var/lib/nfs.  This may be harmless if it's not present;  
> > rpc.statd probably does the right thing in this case.
> 
> The "right thing" in that case would be, I guess, to create a state file
> with "0" in it.  It doesn't do that.  So this patch *does* break stuff.
> Oops!
> 
> So should we revert it and do something else, or patch statd to create
> a new state file if necessary?

It looks like this still needs to be fixed?  I think it would be good
enough just to teach rpc.nfsd to create the file if it doesn't exist.

--b.

> 
> > However, the rest of the logic in nsm_get_state() is needed to bump the 
> > system's state value properly after every reboot.  It may be  
> > inconsequential if there were no mounts or no NFS clients during the  
> > last reboot, but this is subtle.  I wouldn't bet on it.
> 
> If the state is only every communicated to hosts by notifications, then
> if we're not notifying, the update of the state can't matter.
> 
> (So is that premise correct?)
> 
> --b.
