Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:40837 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751764Ab1LOQ2J (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Dec 2011 11:28:09 -0500
Date: Thu, 15 Dec 2011 11:16:49 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Chris Mason <chris.mason@oracle.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Ric Wheeler <ricwheeler@gmail.com>, Al Viro <viro@ZenIV.linux.org.uk>,
        "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Hannes Reinecke <hare@suse.de>,
        Andrew Morton <akpm@linux-foundation.org>, linux-nfs@vger.kernel.org,
        Joel Becker <jlbec@evilplan.org>,
        James Bottomley <James.Bottomley@HansenPartnership.com>
Subject: Re: copy offload support in Linux - new system call needed?
Message-ID: <20111215111649.19af23c1@barsoom.rdu.redhat.com>
In-Reply-To: <1323965176.14317.11.camel@lade.trondhjem.org>
References: <4EE8F75F.6070800@gmail.com>
	<20111214192739.GN2203@ZenIV.linux.org.uk>
	<4EE8FC2E.3010207@gmail.com>
	<20111214222723.GD7623@fieldses.org>
	<1323961140.14317.2.camel@lade.trondhjem.org>
	<20111215155213.GF18252@shiny>
	<20111215110330.33aed3a6@barsoom.rdu.redhat.com>
	<1323965176.14317.11.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 15 Dec 2011 11:06:16 -0500
Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> On Thu, 2011-12-15 at 11:03 -0500, Jeff Layton wrote: 
> > On Thu, 15 Dec 2011 10:52:13 -0500
> > Chris Mason <chris.mason@oracle.com> wrote:
> > 
> > > On Thu, Dec 15, 2011 at 09:59:00AM -0500, Trond Myklebust wrote:
> > > > On Wed, 2011-12-14 at 17:27 -0500, J. Bruce Fields wrote: 
> > > > > On Wed, Dec 14, 2011 at 02:42:38PM -0500, Ric Wheeler wrote:
> > > > > > On 12/14/2011 02:27 PM, Al Viro wrote:
> > > > > > >On Wed, Dec 14, 2011 at 02:22:07PM -0500, Ric Wheeler wrote:
> > > > > > >
> > > > > > >>We had an active thread a couple of years back that came out of the
> > > > > > >>reflink work and, at the time, there seemed to be moderately
> > > > > > >>positive support for adding a new system call that would fit this
> > > > > > >>use case (Joel Becker's copyfile()).
> > > > > > >>
> > > > > > >>Can we resurrect this effort? Is copyfile() still a good way to go,
> > > > > > >>or should we look at other hooks?
> > > > > > >copyfile(2) is probably a good way to go, provided that we do _not_
> > > > > > >go baroque as it had happened the last time syscall had been discussed.
> > > > > > >
> > > > > > >IOW, to hell with progress reports, etc. - just a fastpath kind of
> > > > > > >thing, in the same kind of relationship to cp(1) as rename(2) is to mv(1).
> > > > > > >If it works - fine, if not - caller has to be ready to deal with handling
> > > > > > >cross-device case anyway.
> > > > > > 
> > > > > > I think that this approach makes a lot of sense. Most of the
> > > > > > devices/targets that support the copy offload, will do it in very
> > > > > > reasonable amounts of time.
> > > > > 
> > > > > The current NFSv4.2 draft rolls both the "fast" and "slow" cases into
> > > > > one operation:
> > > > > 
> > > > > 	http://tools.ietf.org/html/draft-ietf-nfsv4-minorversion2-06#section-2
> > > > >  
> > > > > Perhaps we should ask for separate operations for the two cases.  (Or at
> > > > > least a "please don't bother if this is going to take 8 hours" flag....)
> > > > 
> > > > How would the server know? I suggest we deal with this by adding an
> > > > ioctl() to allow the application to poll for progress: I'm assuming now
> > > > that we don't expect more than 1 copyfile() system call at a time per
> > > > file descriptor...
> > > 
> > > If we're using this to copy VM image files, I could easily imagine
> > > wanting to clone multiple copies of the VM in parallel.
> > > 
> > > -chris
> > > 
> > 
> > Not really a problem is it? Just dup() the fd before you issue the
> > copyfile()? Or even simpler, just do periodic stat() on the destination
> > file if you want a progress report.
> > 
> > Regardless, I like the simple approach that Al is suggesting here.
> 
> Periodic stat() isn't good enough if you are copying subranges of a
> file. Part of the application here (as I understood it) is to initialise
> specific disk volumes on existing VM images when doing thin
> provisioning. In that case, the reported image size won't ever change...
> 

If they were sparse files then st_blocks would presumably change, but
that's not necessarily going to be the case. So, ok stat() is out for
this...

What's the use-case for these sorts of progress reports anyway?
Progress meters in GUI apps?

Either way, I think adding as simple an interface as possible to begin
with makes sense. If you want to add progress reports or other
doohickeys later, then that can be done in a separate set of patches...

-- 
Jeff Layton <jlayton@redhat.com>
