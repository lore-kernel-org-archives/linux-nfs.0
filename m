Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:50749 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750970Ab0HSCo2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Aug 2010 22:44:28 -0400
Date: Thu, 19 Aug 2010 12:44:13 +1000
From: Neil Brown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Chuck Lever <chuck.lever@oracle.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>,
        "Patrick J. LoPresti" <lopresti@gmail.com>,
        Andi Kleen <andi@firstfloor.org>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>
Subject: Re: Proposal: Use hi-res clock for file timestamps
Message-ID: <20100819124413.77ca8baf@notabene>
In-Reply-To: <20100819020803.GA30151@fieldses.org>
References: <20100817182920.GD18161@basil.fritz.box>
	<20100817190447.GA28049@fieldses.org>
	<AANLkTi=w1UA5ZZDBigpxMiL7A7DnbnQhLkg62JZpC6Ri@mail.gmail.com>
	<20100817203941.729830b7@lxorguk.ukuu.org.uk>
	<20100817192937.GD26609@fieldses.org>
	<20100818155359.66b9ddb6@notabene>
	<20100818173203.GC32430@fieldses.org>
	<0F91AB9D-0E14-4384-ADD6-0A467C3ABFAC@oracle.com>
	<20100819094136.24fef59b@notabene>
	<20100819105218.7620ec29@notabene>
	<20100819020803.GA30151@fieldses.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 18 Aug 2010 22:08:03 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Thu, Aug 19, 2010 at 10:52:18AM +1000, Neil Brown wrote:
> > On Thu, 19 Aug 2010 09:41:36 +1000
> > Neil Brown <neilb@suse.de> wrote:
> > 
> > > So I agree that this is probably more of an issue for directories than for
> > > files, and that implementing it just for directories would be a sensible
> > > first step with lower expected overhead - just my reasoning seems to be a bit
> > > different.
> > 
> > Just to be sure we are on the same page:
> >   file_update_time would always refer to current_nfsd_time, but nfsd would
> >   only update current_nfsd_time when a directory was examined (and the other
> >   conditions were met).
> > 
> > 
> > So my current thinking on how this would look - names have been changed:
> > 
> >  - global timespec 'current_fs_precise_time' is zeroed when
> >    current_kernel_time moves backwards and is protected by a seqlock
> > 
> >  - current_fs_time would be
> >          now = max(current_kernel_time(), current_fs_precise_time)
> >          return timespec_trunc(now, sb->s_time_gran)
> >    (with appropriate seqlock protection)
> > 
> >  - new function in fs/inode.c
> >          get_precise_time(timestamp)
> 
> Odd name for something that returns nothing of interest;
> bump_precise_time() might be closer?
> 
> And unique_time might be better than precise_time, since the property
> we're asking for is that mtime on a changed file by new?  (Or
> versioned_time?)

Agreed on both counts, tough I'm not keen on 'bump' myself.
  got_unique_time()
because that it what we just did...  I prefer the name to reflect why the
function is called, rather than what the function is expected to do about it.
  never_use_this_timestamp_again(timestamp)
:-?


> 
> >                 cft = current_fs_time()
> >                 if (timestamp == cft)
> 		     /*
> 		      * Make sure the next mtime stored will be
> 		      * something different from timestamp:
> 		      */
> >                    write_seqlock()
> >                    if cft == current_fs_precise_time
> >                         current_fs_precise_time.tv_nsec++
> >                    else if cft > current_fs_precise_time
> 
> What's the cft < current_fs_precise_time case?

The current_fs_precise_time has been incremented with a resolution higher
than s_time_gran.  i.e. s_time_gran > 1.
I'm not really sure what we want to do about that.
Maybe we should be incrementing tv_nsec by s_time_gran as long as that is
significantly less than jiffies_to_usec(1)*1000, but I don't know what I mean
by 'significantly'.

The only values I can find for s_time_gran in current code are 1, 100, 1000
and 1000000000.
All those are either way bigger than a jiffie or significantly smaller, but
suppose a filesystem came along that chose 1000000 (i.e. millisecond
timestamps) - should we increment tv_nsec by 1000000, or not, or cross that
bridge when we come to it?

For reference:
  default is 1000000000  (this would cover ext2, ext3, reiserfs, fat, sysv, ...)
  cifs, smbfs, ntfs are 100
  udf, ceph are 1000
  rest (btrfs, ext4, gfs2, jfs, nilfs, ocfs2, xfs and virtual filesystems) are 1

NeilBrown

