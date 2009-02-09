From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC PATCH 0/1] nfsd: Improve NFS server performance
Date: Mon, 9 Feb 2009 14:06:48 -0500
Message-ID: <20090209190648.GA13636@fieldses.org>
References: <20081230104245.9409.30030.sendpatchset@localhost.localdomain> <20090204231958.GB20917@fieldses.org> <OF46E14C36.93250375-ON65257554.0050CEC8-65257554.005328DC@in.ibm.com> <20090205202401.GH9200@fieldses.org> <OFC7146FC3.ABEF6E81-ON65257556.001EB1D9-65257556.0032B679@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:59378 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751784AbZBITGp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Feb 2009 14:06:45 -0500
In-Reply-To: <OFC7146FC3.ABEF6E81-ON65257556.001EB1D9-65257556.0032B679@in.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Feb 07, 2009 at 02:43:55PM +0530, Krishna Kumar2 wrote:
> Hi Bruce,
> 
> > > I used to have counters in nfsd_open - something like dbg_num_opens,
> > > dbg_open_jiffies, dgb_close_jiffies, dbg_read_jiffies,
> > > dgb_cache_jiffies, etc.  I can reintroduce those debugs and get a run
> > > and see how those numbers looks like, is that what you are looking
> > > for?
> >
> > I'm not sure what you mean by dbg_open_jiffies--surely a single open of
> > a file already in the dentry cache is too fast to be measurable in
> > jiffies?
> 
> When dbg_number_of_opens is very high, I see a big difference in the open
> times
> for original vs new (almost zero) code. I am running 8, 64, 256, etc,
> processes and each of them reads files upto 500MB (a lot of open/read/close
> per file per process), so the jiffies adds up (contention between parallel
> opens, some processing in open, etc). To clarify this, I will reintroduce
> the debugs and get some values (it was done a long time back and I don't
> remember how much difference was there), and post it along with what the
> debug code is doing.
> 
> > OK, yeah, I just wondered whether you could end up with a reference to a
> > file hanging around indefinitely even after it had been deleted, for
> > example.
> 
> If client deletes a file, the server immediately locates and removes the
> cached
> entry. If server deletes a file, my original intention was to use inotify
> to
> inform NFS server to delete the cache but that ran into some problems. So
> my
> solution was to fallback to the cache getting deleted by the daemon after
> the
> short timeout, till then the space for the inode is not freed. So in both
> cases,
> references to the file will not hang around indefinitely.
> 
> > I've heard of someone updating read-only block snapshots by stopping
> > mountd, flushing the export cache, unmounting the old snapshot, then
> > mounting the new one and restarting mountd.  A bit of a hack, but I
> > guess it works, as long as no clients hold locks or NFSv4 opens on the
> > filesystem.
> >
> > An open cache may break that by holding references to the filesystem
> > they want to unmount.  But perhaps we should give such users a proper
> > interface that tells nfsd to temporarily drop state it holds on a
> > filesystem, and tell them to use that instead.
> 
> I must admit that I am lost in this scenario - I was assuming that the
> filesystem can be unmounted only after nfs services are stopped, hence I
> added
> cache cleanup on nfsd_shutdown. Is there some hook to catch for the unmount
> where I should clean the cache for that filesystem?

No.  People have talked about doing that, but it hasn't happened.

But I think I'd prefer some separate operation (probably just triggered
by a write to a some new file in the nfsd filesystem) that told nfsd to
release all its references to a given filesystem.  An administrator
would have to know to do this before unmounting (or maybe mount could be
patched to do this).

Since we don't have a way to tell clients (at least v2/v3 clients) that
we've lost their state on just one filesystem, we'd have to save nfsd's
state internally but drop any hard references to filesystem objects,
then reacquire them afterward.

I'm not sure how best to do that.

That's not necessarily a prerequisite for this change; it depends on how
common that sort of use is.

--b.

> 
> > > Please let me know if you would like me to write up a small text about
> how
> > > this patch works.
> >
> > Any explanation always welcome.
> 
> Sure. I will send this text soon, along with test program.
> 
> > > The other details are:
> > >       #Clients: 1
> > >       Hardware Configuration (both systems):
> > >             Two Dual-Core AMD Opteron (4 cpus) at 3GH.
> > >             1GB memory
> > >             10gbps private network
> > >       Filesystem: ext3 (one filesystem)
> >
> > OK, thanks!  And what sort of disk on the server?
> 
> 133 GB ServeRAID (I think ST9146802SS  Seagate disk), containing 256 files,
> each
> of 500MB size.
> 
> Thanks,
> 
> - KK
> 
