Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:39092 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755376Ab1H2XMM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Aug 2011 19:12:12 -0400
Date: Tue, 30 Aug 2011 09:11:50 +1000
From: NeilBrown <neilb@suse.de>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Ben Hutchings <ben@decadent.org.uk>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org
Subject: Re: [PATCH] All Arch: remove linkage for sys_nfsservctl system call
Message-ID: <20110830091150.176cd08c@notabene.brown>
In-Reply-To: <20110830085752.6db1ffa600f4c82135b3f3eb@canb.auug.org.au>
References: <1312810169.2591.1153.camel@deadeye>
	<20110808155538.GB904@fieldses.org>
	<20110808180658.GC29924@decadent.org.uk>
	<20110826220311.GA18140@fieldses.org>
	<20110830085752.6db1ffa600f4c82135b3f3eb@canb.auug.org.au>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 30 Aug 2011 08:57:52 +1000 Stephen Rothwell <sfr@canb.auug.org.au>
wrote:

> Hi Bruce,
> 
> On Fri, 26 Aug 2011 18:03:11 -0400 "J. Bruce Fields" <bfields@fieldses.org> wrote:
> >
> > From: NeilBrown <neilb@suse.de>
> > 
> > The nfsservctl system call is now gone, so we should remove all
> > linkage for it.
> > 
> > Signed-off-by: NeilBrown <neilb@suse.de>
> > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > ---
> > 
> > I don't normally have to deal with this kind of cross-architecture
> > patch; is this the right etiquette for it?
> 
> It turns out (with hindsight) that my reaction to this patch should have
> been:
> 
> If you haven't built this on all architectures (an noone expects you to
> actually do that), then it should spend a day or two in linux-next before
> being sent to Linus.
> 

Hi Stephen,
 Thanks for your help in sorting this out.  I have no idea how I missed those
 few nfsservctl references but I clearly did and you and -next have proved
 valuable yet again.

 And really *everything* should spend a few days in linux-next before going
 to Linus.  We all know that but it sometimes seem hard to *do* that ....
 until we have learnt the hard way a couple of times :-(

Thanks,
NeilBrown
