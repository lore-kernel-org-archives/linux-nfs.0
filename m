Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ipmail07.adl2.internode.on.net ([150.101.137.131]:43403 "EHLO
	ipmail07.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752518AbcGHXaU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Jul 2016 19:30:20 -0400
Date: Sat, 9 Jul 2016 09:30:03 +1000
From: Dave Chinner <david@fromorbit.com>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: xfs@oss.sgi.com, linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Christoph Hellwig <hch@lst.de>, bfields@fieldses.org
Subject: Re: [PATCH 2/2] abstract block export operations from nfsd layouts
Message-ID: <20160708233003.GO27480@dastard>
References: <5ff05b585226b689866f4604adddffc94910f63f.1467889001.git.bcodding@redhat.com>
 <073be10a55e5e952adbfd320abcce075fb3958ae.1467889001.git.bcodding@redhat.com>
 <20160707223809.GH12670@dastard>
 <EAD93DB0-20FD-4EC5-9232-F12671E21630@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <EAD93DB0-20FD-4EC5-9232-F12671E21630@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 08, 2016 at 09:24:27AM -0400, Benjamin Coddington wrote:
> On 7 Jul 2016, at 18:38, Dave Chinner wrote:
> 
> > On Thu, Jul 07, 2016 at 07:02:32AM -0400, Benjamin Coddington wrote:
> >> Instead of creeping pnfs layout configuration into filesystems, move the
> >> definition of block-based export operations under a more abstract
> >> configuration.
> >>
> >> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> >> ---
> >>  fs/Kconfig          | 3 +++
> >>  fs/nfsd/Kconfig     | 2 ++
> >>  fs/xfs/Makefile     | 3 +--
> >>  fs/xfs/xfs_export.c | 2 +-
> >>  fs/xfs/xfs_pnfs.h   | 4 ++--
> >>  5 files changed, 9 insertions(+), 5 deletions(-)
> >>
> >> diff --git a/fs/Kconfig b/fs/Kconfig
> >> index 6725f59c18e6..6e57b4237d72 100644
> >> --- a/fs/Kconfig
> >> +++ b/fs/Kconfig
> >> @@ -66,6 +66,9 @@ config FS_POSIX_ACL
> >>  config EXPORTFS
> >>  	tristate
> >>
> >> +config BLOCK_EXPORT_OPS
> >> +	bool
> >> +
> >
> > default n, help text?
> 
> Not set is n, and as it isn't visible or intended to be set by a user, I
> left out the help text.  I'll add both for completeness.
> 
> > Also, BLOCK_* prefix config options are for block layer
> > functionality, hence I suspect this will confuse people because it's
> > a filesystem config option. EXPORTFS_BLOCK_OPS seems more obvious
> > and correct to me, as the block mapping ops are part of the exportfs
> > operations interface....
> 
> OK. I agree - that is better.
> 
> >>  xfs-$(CONFIG_SYSCTL)		+= xfs_sysctl.o
> >>  xfs-$(CONFIG_COMPAT)		+= xfs_ioctl32.o
> >> -xfs-$(CONFIG_NFSD_BLOCKLAYOUT)	+= xfs_pnfs.o
> >> -xfs-$(CONFIG_NFSD_SCSILAYOUT)	+= xfs_pnfs.o
> >> +xfs-$(CONFIG_BLOCK_EXPORT_OPS)	+= xfs_pnfs.o
> >
> > Why do we need the first patch to XFS anymore? Just convert it
> > straight to using CONFIG_EXPORTFS_BLOCK_OPS....
> 
> Doing this in a single patch would combine two changes in a single commit:
>  - the definition of the extra operations for a config of only SCSI_LAYOUT
>  - the addition of CONFIG_EXPORTFS_BLOCK_OPS.
> 
> Since the first is the originally intended behavior, and the second fixes it
> up, I'll just send it along in a single patch if that's preferred.
