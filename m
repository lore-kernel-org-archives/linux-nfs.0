Return-Path: linux-nfs-owner@vger.kernel.org
Received: from gate.crashing.org ([63.228.1.57]:39594 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751142Ab2JBA75 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Oct 2012 20:59:57 -0400
Message-ID: <1349139509.3847.2.camel@pasglop>
Subject: Re: [REGRESSION] nfsd crashing with 3.6.0-rc7 on PowerPC
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: Alexander Graf <agraf@suse.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        LKML List <linux-kernel@vger.kernel.org>,
        linuxppc-dev <linuxppc-dev@lists.ozlabs.org>,
        linux-nfs@vger.kernel.org, Jan Kara <jack@suse.cz>,
        skinsbursky@parallels.com, bfields@redhat.com, anton@samba.org
Date: Tue, 02 Oct 2012 10:58:29 +1000
In-Reply-To: <2A52FC96-148C-4F7A-9950-E152E0C6698D@suse.de>
References: <3BDA9E62-7031-42D6-8CA9-5327B61700F5@suse.de>
	 <CA+55aFyXwB1QcXE4Z_FAGnXROSgvP2x2+wjnX9OWPa4Dfaaf0A@mail.gmail.com>
	 <DC545CD9-8745-47DD-B13B-3385C0EB5B27@suse.de>
	 <20120928151043.GA19102@fieldses.org>
	 <2A52FC96-148C-4F7A-9950-E152E0C6698D@suse.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2012-10-01 at 16:03 +0200, Alexander Graf wrote:
> Phew. Here we go :). It looks to be more of a PPC specific problem than it appeared as at first:

Ok, so I suspect the problem is the pushing down of the locks which
breaks with iommu backends that have a separate flush callback. In
that case, the flush moves out of the allocator lock.

Now we do call flush before we return, still, but it becomes racy
I suspect, but somebody needs to give it a closer look. I'm hoping
Anton or Nish will later today.

Cheers,
Ben.

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


