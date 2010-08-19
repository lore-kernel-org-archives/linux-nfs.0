Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:44556 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750863Ab0HSCKS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Aug 2010 22:10:18 -0400
Date: Wed, 18 Aug 2010 22:08:03 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Neil Brown <neilb@suse.de>
Cc: Chuck Lever <chuck.lever@oracle.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>,
        "Patrick J. LoPresti" <lopresti@gmail.com>,
        Andi Kleen <andi@firstfloor.org>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>
Subject: Re: Proposal: Use hi-res clock for file timestamps
Message-ID: <20100819020803.GA30151@fieldses.org>
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
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100819105218.7620ec29@notabene>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Aug 19, 2010 at 10:52:18AM +1000, Neil Brown wrote:
> On Thu, 19 Aug 2010 09:41:36 +1000
> Neil Brown <neilb@suse.de> wrote:
> 
> > So I agree that this is probably more of an issue for directories than for
> > files, and that implementing it just for directories would be a sensible
> > first step with lower expected overhead - just my reasoning seems to be a bit
> > different.
> 
> Just to be sure we are on the same page:
>   file_update_time would always refer to current_nfsd_time, but nfsd would
>   only update current_nfsd_time when a directory was examined (and the other
>   conditions were met).
> 
> 
> So my current thinking on how this would look - names have been changed:
> 
>  - global timespec 'current_fs_precise_time' is zeroed when
>    current_kernel_time moves backwards and is protected by a seqlock
> 
>  - current_fs_time would be
>          now = max(current_kernel_time(), current_fs_precise_time)
>          return timespec_trunc(now, sb->s_time_gran)
>    (with appropriate seqlock protection)
> 
>  - new function in fs/inode.c
>          get_precise_time(timestamp)

Odd name for something that returns nothing of interest;
bump_precise_time() might be closer?

And unique_time might be better than precise_time, since the property
we're asking for is that mtime on a changed file by new?  (Or
versioned_time?)

>                 cft = current_fs_time()
>                 if (timestamp == cft)
		     /*
		      * Make sure the next mtime stored will be
		      * something different from timestamp:
		      */
>                    write_seqlock()
>                    if cft == current_fs_precise_time
>                         current_fs_precise_time.tv_nsec++
>                    else if cft > current_fs_precise_time

What's the cft < current_fs_precise_time case?

--b.

>                         current_fs_precise_time = cft
>                    write_sequnlock()
>                 return timestamp
> 
>   - nfsd xdr response routine does
>              ts = inode->i_mtime
>              if (S_ISDIR(inode->i_mode))
>                 ts = get_precise_time(ts)
>              xdr_encode_timespec(ts)
> 
> 
> get_precise_time() probably needs a bit more subtlety to handle different
> s_time_gran values and possible races, but I think it is fairly close.
> 
> Then if we ever had an xstat or similar that could ask for precise
> timestamps, it just makes a similar call to get_precise_time.
> Also if we added code later to use a hires timer on hardware where it was
> efficient, get_precise_time could test for that and become a no-op
> 
> Yes, I should probably turn this into a patch ... maybe another day.
> 
> NeilBrown
