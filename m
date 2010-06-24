From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] Improve support for exporting btrfs subvolumes.
Date: Wed, 23 Jun 2010 20:15:23 -0400
Message-ID: <20100624001523.GB8500@fieldses.org>
References: <19481.43625.476833.275104@notabene.brown> <20100623182837.GB28346@fieldses.org> <20100624073157.743983ec@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org,
	linux-btrfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59277 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753006Ab0FXAP3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Jun 2010 20:15:29 -0400
In-Reply-To: <20100624073157.743983ec-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 24, 2010 at 07:31:57AM +1000, Neil Brown wrote:
> On Wed, 23 Jun 2010 14:28:38 -0400
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Thu, Jun 17, 2010 at 02:54:01PM +1000, Neil Brown wrote:
> > > 
> > > If you export two subvolumes of a btrfs filesystem, they will both be
> > > given the same uuid so lookups will be confused.
> > > blkid cannot differentiate the two, so we must use the fsid from
> > > statfs64 to identify the filesystem.
> > > 
> > > We cannot tell if blkid or statfs is best without knowing internal
> > > details of the filesystem in question, so we need to encode specific
> > > knowledge of btrfs in mountd.  This is unfortunate.
> > > 
> > > To ensure smooth handling of this and possible future changes in uuid
> > > generation, we add infrastructure for multiple different uuids to be
> > > recognised on old filehandles, but only the preferred on is used on
> > > new filehandles.
> > 
> > Could you just contatenate the two (or hash them somehow)?  Or does that
> > just use up too much space in the filehandle?
> 
> I did consider xoring them together but came to the conclusion that would
> actually be a regression.
> If you look down at the comment that I included in uuid_by_path, you will see
> that some filesystems (e.g. VFAT) just use the major/minor device number for
> the f_fsid from statfs.  As you know that is not necessarily stable over
> reboots, while the UUID that blkid gives is.
> So if we always adding the two uuids somehow, it would be an improvement for
> btrfs, no change for e.g. ext3/XFS, and a regression for VFAT (and others I
> think).  Not good.

OK, got it.

--b.
