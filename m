Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:38012 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750872AbcGMUVG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Jul 2016 16:21:06 -0400
Date: Wed, 13 Jul 2016 16:21:04 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Benjamin Coddington <bcodding@redhat.com>, xfs@oss.sgi.com,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v2] xfs: abstract block export operations from nfsd
 layouts
Message-ID: <20160713202104.GA10734@fieldses.org>
References: <6c1549ee874431c8293cad72c5f7382095277822.1467985684.git.bcodding@redhat.com>
 <20160710094540.GA19392@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160710094540.GA19392@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jul 10, 2016 at 11:45:40AM +0200, Christoph Hellwig wrote:
> On Fri, Jul 08, 2016 at 09:53:20AM -0400, Benjamin Coddington wrote:
> > Instead of creeping pnfs layout configuration into filesystems, move the
> > definition of block-based export operations under a more abstract
> > configuration.
> > 
> > Changes from v1:
> > 	- dropped the first patch in the first posting
> > 	- renamed the config to EXPORTFS_BLOCK_OPS from BLOCK_EXPORT_OPS
> > 	- add an explicit default to no for EXPORTFS_BLOCK_OPS
> > 	- add some help and menu text
> > 
> > Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> > ---
> >  fs/Kconfig          | 7 +++++++
> >  fs/nfsd/Kconfig     | 2 ++
> >  fs/xfs/Makefile     | 3 +--
> >  fs/xfs/xfs_export.c | 2 +-
> >  fs/xfs/xfs_pnfs.h   | 4 ++--
> >  5 files changed, 13 insertions(+), 5 deletions(-)
> > 
> > diff --git a/fs/Kconfig b/fs/Kconfig
> > index 6725f59c18e6..ac6d3b36600c 100644
> > --- a/fs/Kconfig
> > +++ b/fs/Kconfig
> > @@ -66,6 +66,13 @@ config FS_POSIX_ACL
> >  config EXPORTFS
> >  	tristate
> >  
> > +config EXPORTFS_BLOCK_OPS
> > +	bool "Enable filesystem export operations for block IO"
> > +	default n
> 
> default n is the default, no need to add it.
> 
> Otherwise looks fine:
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>

Thanks.  Applied, with that one "default n" line dropped.

An ACK from Dave might also help reassure Linus I'm not stepping on
anybody's toes.

--b.
