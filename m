Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:36060 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751651Ab1LOO7I convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Dec 2011 09:59:08 -0500
Message-ID: <1323961140.14317.2.camel@lade.trondhjem.org>
Subject: Re: copy offload support in Linux - new system call needed?
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Ric Wheeler <ricwheeler@gmail.com>, Al Viro <viro@ZenIV.linux.org.uk>,
        "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Hannes Reinecke <hare@suse.de>,
        Andrew Morton <akpm@linux-foundation.org>, linux-nfs@vger.kernel.org,
        Joel Becker <jlbec@evilplan.org>,
        James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Thu, 15 Dec 2011 09:59:00 -0500
In-Reply-To: <20111214222723.GD7623@fieldses.org>
References: <4EE8F75F.6070800@gmail.com>
	 <20111214192739.GN2203@ZenIV.linux.org.uk> <4EE8FC2E.3010207@gmail.com>
	 <20111214222723.GD7623@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2011-12-14 at 17:27 -0500, J. Bruce Fields wrote: 
> On Wed, Dec 14, 2011 at 02:42:38PM -0500, Ric Wheeler wrote:
> > On 12/14/2011 02:27 PM, Al Viro wrote:
> > >On Wed, Dec 14, 2011 at 02:22:07PM -0500, Ric Wheeler wrote:
> > >
> > >>We had an active thread a couple of years back that came out of the
> > >>reflink work and, at the time, there seemed to be moderately
> > >>positive support for adding a new system call that would fit this
> > >>use case (Joel Becker's copyfile()).
> > >>
> > >>Can we resurrect this effort? Is copyfile() still a good way to go,
> > >>or should we look at other hooks?
> > >copyfile(2) is probably a good way to go, provided that we do _not_
> > >go baroque as it had happened the last time syscall had been discussed.
> > >
> > >IOW, to hell with progress reports, etc. - just a fastpath kind of
> > >thing, in the same kind of relationship to cp(1) as rename(2) is to mv(1).
> > >If it works - fine, if not - caller has to be ready to deal with handling
> > >cross-device case anyway.
> > 
> > I think that this approach makes a lot of sense. Most of the
> > devices/targets that support the copy offload, will do it in very
> > reasonable amounts of time.
> 
> The current NFSv4.2 draft rolls both the "fast" and "slow" cases into
> one operation:
> 
> 	http://tools.ietf.org/html/draft-ietf-nfsv4-minorversion2-06#section-2
>  
> Perhaps we should ask for separate operations for the two cases.  (Or at
> least a "please don't bother if this is going to take 8 hours" flag....)

How would the server know? I suggest we deal with this by adding an
ioctl() to allow the application to poll for progress: I'm assuming now
that we don't expect more than 1 copyfile() system call at a time per
file descriptor...

Cheers
   Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

