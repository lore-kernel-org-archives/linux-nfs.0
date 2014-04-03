Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37765 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752713AbaDCVgL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Apr 2014 17:36:11 -0400
Date: Thu, 3 Apr 2014 17:36:10 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: Boaz Harrosh <openosd@gmail.com>, NFS <linux-nfs@vger.kernel.org>
Subject: Re: Should exportfs/mountd cope with case-insensitive directory
 names.
Message-ID: <20140403213610.GF8343@fieldses.org>
References: <20140403164652.5d7770ad@notabene.brown>
 <20140403130909.GA24700@fieldses.org>
 <533D8629.10907@gmail.com>
 <20140403171625.GA5884@fieldses.org>
 <20140403172431.GB5884@fieldses.org>
 <20140404082154.4cfdab5a@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140404082154.4cfdab5a@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 04, 2014 at 08:21:54AM +1100, NeilBrown wrote:
> On Thu, 3 Apr 2014 13:24:31 -0400 "J. Bruce Fields" <bfields@fieldses.org>
> wrote:
> 
> > On Thu, Apr 03, 2014 at 01:16:25PM -0400, J. Bruce Fields wrote:
> > > In the presence of bind mounts it's definitely possible for two
> > > different paths to reach the same directory.
> > > 
> > > I don't know if that's actually a problem here....
> > 
> > Without testing: if we've got the same filesystem mounted at /foo/bar
> > and /foo/baz, but only export /foo/bar, will this change make that
> > export show up at /foo/baz as well?
> > 
> > (Since we'll now consider /foo/bar and /foo/baz to match where
> > previously they didn't?)
> 
> Good question.  I should test, but I suspect "yes".  I'm not really happy
> about that.

Yeah.

> Maybe we could use name_to_handle_at().  That returns the mnt_id
> which is different for different bind mounts.
> So if the mnt_id and the handle are the same, it is the same directory.  If
> not, then not.
> 
> I did worry a bit about all the extra stat calls, but as you say: they are
> cached so it shouldn't be a big problem.
> 
> It would  make sense to stat (or name_to_handle_at) the name from the kernel
> just once, then compare the value against everything in the export table.
> 
> We could possible store handles in the export table, but then we would need
> to check for changes to mountinfo (I think 'poll' can do that) and clear out
> the cache whenever a mount changes.
> 
> I might play with some code if I find time...

Sounds reasonable.  But also getting a bit more involved for an uncommon
case (path to the root on a case-insensitive filesystem).

--b.

(BTW:  I also noticed the other day that systemd is calling
name_to_handle_at to get a mount id.  Seems like overkill in both
cases--shouldn't there be a simpler way to get just the mount id?)
