From: Sam Ravnborg <sam-uyr5N9Q2VtJg9hUCZPvPmw@public.gmane.org>
Subject: Re: [GIT PULL -tip] fix 33 make headers_check warnings
Date: Sun, 18 Jan 2009 11:10:29 +0100
Message-ID: <20090118101029.GA31461@uranus.ravnborg.org>
References: <1232223441.3966.22.camel@localhost.localdomain> <1232228261.27094.0.camel@macbook.infradead.org> <20090117221932.GA4956@uranus.ravnborg.org> <20090118091300.GA24849@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Woodhouse <dwmw2@infradead.org>,
	Jaswinder Singh Rajput <jaswinder@kernel.org>,
	x86 maintainers <x86@kernel.org>, urs.thuermann-l29pVbxQd1IUtdQbppsyvg@public.gmane.org,
	oliver.hartkopp-l29pVbxQd1IUtdQbppsyvg@public.gmane.org, linux-media@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	bfields@fieldses.org, neilb@suse.de, linux-nfs@vger.kernel.org,
	linux-raid@vger.kernel.org, dbrownell@users.sourceforge.net,
	spi-devel-general@lists.sourceforge.net, netdev@vger.kernel.org,
	greg@kroah.com, linux-usb@vger.kernel.org,
	linux-mtd@lists.infradead.org, tiwai@suse.de,
	mchehab@infradead.org, LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pfepa.post.tele.dk ([195.41.46.235]:44748 "EHLO
	pfepa.post.tele.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759119AbZARKIu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 18 Jan 2009 05:08:50 -0500
In-Reply-To: <20090118091300.GA24849@elte.hu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jan 18, 2009 at 10:13:00AM +0100, Ingo Molnar wrote:
> 
> * Sam Ravnborg <sam-uyr5N9Q2VtJg9hUCZPvPmw@public.gmane.org> wrote:
> 
> > On Sun, Jan 18, 2009 at 08:37:41AM +1100, David Woodhouse wrote:
> > > On Sun, 2009-01-18 at 01:47 +0530, Jaswinder Singh Rajput wrote:
> > > > --- a/include/linux/dvb/audio.h
> > > > +++ b/include/linux/dvb/audio.h
> > > > @@ -24,9 +24,8 @@
> > > >  #ifndef _DVBAUDIO_H_
> > > >  #define _DVBAUDIO_H_
> > > >  
> > > > -#ifdef __KERNEL__
> > > >  #include <linux/types.h>
> > > > -#else
> > > > +#ifndef __KERNEL__
> > > >  #include <stdint.h>
> > > >  #endif
> > > >  
> > > 
> > > That patch looks wrong, and unnecessary. It was fine before.
> > Nope - include/linux/dvb/audio.h failed to include linux/types.h
> > despite the fact that is uses __u32 etc.
> > 
> > But why the _kernel_ should include a userspace header is
> > much more questionable.
> 
> ok, i dropped this one for the time being.
> 
> Sam, Andrew, et al, i've got the commit lineup below, to fix the ~200 new 
> CONFIG_HEADERS_CHECK=y warnings we have in current -git, on x86 
> allyesconfig.
> 
> Note that i have restructured the tree and the commits so that this effort 
> can be tracked more easily: each commit has a "headers_check fix" subject 
> line prefix. So you can go back later and revisit these things - for 
> example whether a header really needs to be exported to user-space, via:
> 
>   git log --grep='headers_check fix:' --pretty=format:"%h: %s"
> 
> to get an overview and a historic track record. We can follow this 
> notation in the future too.
> 
> So if there are no objections, i'll send this to Linus tomorrow-ish and 
> we'll have the worst of the fallout behind us and can embark on a much 
> more fluid (and per maintainer) headers_check related workflow.

Thanks for taking care of this Ingo and please push towards Linus.
And thanks to all the contributors too - it was great to see this dealt
with soo quickly!

	Sam
