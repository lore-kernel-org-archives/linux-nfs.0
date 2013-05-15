Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipmail05.adl6.internode.on.net ([150.101.137.143]:61736 "EHLO
	ipmail05.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758286Ab3EOBBR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 May 2013 21:01:17 -0400
Date: Wed, 15 May 2013 11:01:13 +1000
From: Dave Chinner <david@fromorbit.com>
To: Zach Brown <zab@redhat.com>
Cc: "Martin K. Petersen" <martin.petersen@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [RFC v0 0/4] sys_copy_range() rough draft
Message-ID: <20130515010113.GN29466@dastard>
References: <1368566126-17610-1-git-send-email-zab@redhat.com>
 <20130514214251.GK29466@dastard>
 <20130514220440.GN16385@lenny.home.zabbo.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130514220440.GN16385@lenny.home.zabbo.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 14, 2013 at 03:04:40PM -0700, Zach Brown wrote:
> On Wed, May 15, 2013 at 07:42:51AM +1000, Dave Chinner wrote:
> > On Tue, May 14, 2013 at 02:15:22PM -0700, Zach Brown wrote:
> > > I'm going to keep hacking away at this.  My next step is to get ext4
> > > supporting .copy_range, probably with a quick hack to copy the
> > > contents of bios.  Hopefully that'll give enough time to also integrate
> > > review feedback.
> > 
> > Wouldn't the easiest "support all filesystems" hack just be to add
> > a destination offset parameter to do_splice_direct() and call that
> > when the filesystem doesn't supply a ->copy_range method? i.e. use
> > the mechanisms we already have for copying from one file to another
> > via the page cache as efficiently as possible?
> 
> Probably; and this in-kernel buffered fallback is particularly desirable
> for nfsd when the exported fs doesn't provide .copy_range.  Having nfsd
> service the COPY op is still a significant win over having the client
> move the data backand forth over the wire.

Sure. That's kind of what I was thinking to make it easy to test and
have widespread support up front.

> But in that quote above I was talking about implementing .copy_range in
> ext4 as though it could use XCOPY today.  I'd like to get a feel for how
> bad it's going to be to juggle the bio XCOPY IO with unwritten extent
> conversion, RMW with overlapping existing blocks, i_size advancing, etc.
> (It's so much like O_DIRECT that I'm already crying a little.)

Toss anything that is hard back to the page cache path. Overlapping
blocks, partial blocks and so can be handled by the slow path
without making the offload path complex.

Make the offload do the simple stuff fast - the mapping and
completion callbacks should be no different to the direct IO bits we
have now, and if you only handle filesystem block aligned ranges in
the offload (rather than sector alignment) most of the grot that DIO
code has to handle goes away....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
