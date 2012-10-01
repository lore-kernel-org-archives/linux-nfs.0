Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50830 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751408Ab2JAPV3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Oct 2012 11:21:29 -0400
Date: Mon, 1 Oct 2012 11:21:20 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Alexander Graf <agraf@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        LKML List <linux-kernel@vger.kernel.org>,
        linuxppc-dev <linuxppc-dev@lists.ozlabs.org>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        linux-nfs@vger.kernel.org, Jan Kara <jack@suse.cz>,
        skinsbursky@parallels.com, bfields@redhat.com, anton@samba.org
Subject: Re: [REGRESSION] nfsd crashing with 3.6.0-rc7 on PowerPC
Message-ID: <20121001152120.GC18400@fieldses.org>
References: <3BDA9E62-7031-42D6-8CA9-5327B61700F5@suse.de>
 <CA+55aFyXwB1QcXE4Z_FAGnXROSgvP2x2+wjnX9OWPa4Dfaaf0A@mail.gmail.com>
 <DC545CD9-8745-47DD-B13B-3385C0EB5B27@suse.de>
 <20120928151043.GA19102@fieldses.org>
 <2A52FC96-148C-4F7A-9950-E152E0C6698D@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <2A52FC96-148C-4F7A-9950-E152E0C6698D@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 01, 2012 at 04:03:06PM +0200, Alexander Graf wrote:
> 
> On 28.09.2012, at 17:10, J. Bruce Fields wrote:
> 
> > On Fri, Sep 28, 2012 at 04:19:55AM +0200, Alexander Graf wrote:
> >> 
> >> On 28.09.2012, at 04:04, Linus Torvalds wrote:
> >> 
> >>> On Thu, Sep 27, 2012 at 6:55 PM, Alexander Graf <agraf@suse.de> wrote:
> >>>> 
> >>>> Below are OOPS excerpts from different rc's I tried. All of them crashed - all the way up to current Linus' master branch. I haven't cross-checked, but I don't remember any such behavior from pre-3.6 releases.
> >>> 
> >>> Since you seem to be able to reproduce it easily (and apparently
> >>> reliably), any chance you could just bisect it?
> >>> 
> >>> Since I assume v3.5 is fine, and apparently -rc1 is already busted, a simple
> >>> 
> >>>  git bisect start
> >>>  git bisect good v3.5
> >>>  git bisect bad v3.6-rc1
> >>> 
> >>> will get you started on your adventure..
> >> 
> >> Heh, will give it a try :). The thing really does look quite bisectable.
> >> 
> >> 
> >> It might take a few hours though - the machine isn't exactly fast by today's standards and it's getting late here. But I'll keep you updated.
> > 
> > I doubt it's anything special about that workload, but just for kicks I
> > tried a "git clone -ls" (cloning my linux tree to another directory on
> > the same nfs filesystem), with server on 3.6.0-rc7, and didn't see
> > anything interesting (just an xfs lockdep warning that looks like this
> > one jlayton already reported:
> > http://oss.sgi.com/archives/xfs/2012-09/msg00088.html
> > )
> > 
> > Any (even partial) bisection results would certainly be useful, thanks.
> 
> Phew. Here we go :). It looks to be more of a PPC specific problem than it appeared as at first:

Yep, thanks--I'll assume this is somebody else's problem until somebody
tells me otherwise!

--b.

> 
> 
> b4c3a8729ae57b4f84d661e16a192f828eca1d03 is first bad commit
> commit b4c3a8729ae57b4f84d661e16a192f828eca1d03
> Author: Anton Blanchard <anton@samba.org>
> Date:   Thu Jun 7 18:14:48 2012 +0000
> 
>     powerpc/iommu: Implement IOMMU pools to improve multiqueue adapter performance
>     
>     At the moment all queues in a multiqueue adapter will serialise
>     against the IOMMU table lock. This is proving to be a big issue,
>     especially with 10Gbit ethernet.
>     
>     This patch creates 4 pools and tries to spread the load across
>     them. If the table is under 1GB in size we revert back to the
>     original behaviour of 1 pool and 1 largealloc pool.
>     
>     We create a hash to map CPUs to pools. Since we prefer interrupts to
>     be affinitised to primary CPUs, without some form of hashing we are
>     very likely to end up using the same pool. As an example, POWER7
>     has 4 way SMT and with 4 pools all primary threads will map to the
>     same pool.
>     
>     The largealloc pool is reduced from 1/2 to 1/4 of the space to
>     partially offset the overhead of breaking the table up into pools.
>     
>     Some performance numbers were obtained with a Chelsio T3 adapter on
>     two POWER7 boxes, running a 100 session TCP round robin test.
>     
>     Performance improved 69% with this patch applied.
>     
>     Signed-off-by: Anton Blanchard <anton@samba.org>
>     Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> 
> :040000 040000 039ae3cbdcfded9c6b13e58a3fc67609f1b587b0 6755a8c4a690cc80dcf834d1127f21db925476d6 M	arch
> 
> 
> Alex
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
