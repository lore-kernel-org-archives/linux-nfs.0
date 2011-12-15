Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55269 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751452Ab1LORoh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Dec 2011 12:44:37 -0500
Date: Thu, 15 Dec 2011 12:44:27 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Ric Wheeler <ricwheeler@gmail.com>, Al Viro <viro@ZenIV.linux.org.uk>,
        "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Hannes Reinecke <hare@suse.de>,
        Andrew Morton <akpm@linux-foundation.org>, linux-nfs@vger.kernel.org,
        Joel Becker <jlbec@evilplan.org>,
        James Bottomley <James.Bottomley@HansenPartnership.com>
Subject: Re: copy offload support in Linux - new system call needed?
Message-ID: <20111215174427.GA14614@fieldses.org>
References: <4EE8F75F.6070800@gmail.com>
 <20111214192739.GN2203@ZenIV.linux.org.uk>
 <4EE8FC2E.3010207@gmail.com>
 <20111214222723.GD7623@fieldses.org>
 <1323961140.14317.2.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1323961140.14317.2.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 15, 2011 at 09:59:00AM -0500, Trond Myklebust wrote:
> On Wed, 2011-12-14 at 17:27 -0500, J. Bruce Fields wrote: 
> > On Wed, Dec 14, 2011 at 02:42:38PM -0500, Ric Wheeler wrote:
> > > On 12/14/2011 02:27 PM, Al Viro wrote:
> > > >On Wed, Dec 14, 2011 at 02:22:07PM -0500, Ric Wheeler wrote:
> > > >
> > > >>We had an active thread a couple of years back that came out of the
> > > >>reflink work and, at the time, there seemed to be moderately
> > > >>positive support for adding a new system call that would fit this
> > > >>use case (Joel Becker's copyfile()).
> > > >>
> > > >>Can we resurrect this effort? Is copyfile() still a good way to go,
> > > >>or should we look at other hooks?
> > > >copyfile(2) is probably a good way to go, provided that we do _not_
> > > >go baroque as it had happened the last time syscall had been discussed.
> > > >
> > > >IOW, to hell with progress reports, etc. - just a fastpath kind of
> > > >thing, in the same kind of relationship to cp(1) as rename(2) is to mv(1).
> > > >If it works - fine, if not - caller has to be ready to deal with handling
> > > >cross-device case anyway.
> > > 
> > > I think that this approach makes a lot of sense. Most of the
> > > devices/targets that support the copy offload, will do it in very
> > > reasonable amounts of time.
> > 
> > The current NFSv4.2 draft rolls both the "fast" and "slow" cases into
> > one operation:
> > 
> > 	http://tools.ietf.org/html/draft-ietf-nfsv4-minorversion2-06#section-2
> >  
> > Perhaps we should ask for separate operations for the two cases.  (Or at
> > least a "please don't bother if this is going to take 8 hours" flag....)
> 
> How would the server know?

Sorry, "8 hours" was a joke--no, you can't require the server to predict
whether an operation will take more or less than some precise duration.

I'm assuming the "fast" case that Al's proposing we do as a first step
cover CoW operations?  (So O(1) or close to it, users typically won't be
asking for progress reports, operation may be atomic (with no
partial-failure case), ?)

--b.
