From: Adrian Bunk <bunk@kernel.org>
Subject: Re: [1/2] 2.6.23-rc3: known regressions with patches
Date: Mon, 13 Aug 2007 23:29:47 +0200
Message-ID: <20070813212947.GK18945@stusta.de>
References: <46C09C1A.7050706@googlemail.com> <20070813184204.GA6071@one.firstfloor.org> <6bffcb0e0708131324x29211ef5sd5154d44f0c2e79f@mail.gmail.com> <20070813205653.GA7069@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Gabriel C <nix.or.die@googlemail.com>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Jan Engelhardt <jengelh@linux01.gwdg.de>,
	Satyam Sharma <satyam.sharma@gmail.com>,
	Vitaly Bordug <vitb@kernel.crashing.org>,
	Dan Merillat <dan.merillat@gmail.com>,
	Paolo Ornati <ornati@fastwebnet.it>,
	Rusty Russell <rusty@rustcorp.com.au>,
	linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net,
	Jeff Garzik <jeff@garzik.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070813205653.GA7069@one.firstfloor.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Mon, Aug 13, 2007 at 10:56:53PM +0200, Andi Kleen wrote:
> On Mon, Aug 13, 2007 at 10:24:52PM +0200, Michal Piotrowski wrote:
> > On 13/08/07, Andi Kleen <andi@firstfloor.org> wrote:
> > > > Unclassified
> > > >
> > > > Subject         : reset during bootup - 2.6.23-rc2 (git d23cf676)
> > >
> > > This is already fixed in mainline
> > 
> > commit b8d3f2448b8f4ba24f301e23585547ba1acc1f04
> > 
> > >
> > > There is a real regression with failing builds on some old binutils on
> > > x86-64 know, but I don't know how to fix it.
> > 
> > Did you mean this?
> 
> Yes. Anyways it be likely a WONT-FIX -- aka document newer binutils
> version required. We haven't had any other reports so likely
> that version is not too widely used.

IOW: Either the Linux binutils >= 2.17.50.0.3 or the not yet released 
GNU binutils 2.18 are now required.

Debian 4.0 has older ones, and all distributions released more than a 
year ago for sure also have older ones (the required patch went into 
binutils CVS on 2006-05-30 and 2.17.50.0.3 was released on 2006-07-15).

Isn't that a bit too recent?

> -Andi

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

