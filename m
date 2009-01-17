From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [GIT PULL -tip] fix 33 make headers_check warnings
Date: Sat, 17 Jan 2009 23:19:32 +0100
Message-ID: <20090117221932.GA4956@uranus.ravnborg.org>
References: <1232223441.3966.22.camel@localhost.localdomain> <1232228261.27094.0.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jaswinder Singh Rajput <jaswinder@kernel.org>,
	Ingo Molnar <mingo@elte.hu>, x86 maintainers <x86@kernel.org>,
	urs.thuermann@volkswagen.de, oliver.hartkopp@volkswagen.de,
	linux-media@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, bfields@fieldses.org, neilb@suse.de,
	linux-nfs@vger.kernel.org, linux-raid@vger.kernel.org,
	dbrownell@users.sourceforge.net,
	spi-devel-general@lists.sourceforge.net, netdev@vger.kernel.org,
	greg@kroah.com, linux-usb@vger.kernel.org,
	linux-mtd@lists.infradead.org, tiwai@suse.de,
	mchehab@infradead.org, LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1232228261.27094.0.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jan 18, 2009 at 08:37:41AM +1100, David Woodhouse wrote:
> On Sun, 2009-01-18 at 01:47 +0530, Jaswinder Singh Rajput wrote:
> > --- a/include/linux/dvb/audio.h
> > +++ b/include/linux/dvb/audio.h
> > @@ -24,9 +24,8 @@
> >  #ifndef _DVBAUDIO_H_
> >  #define _DVBAUDIO_H_
> >  
> > -#ifdef __KERNEL__
> >  #include <linux/types.h>
> > -#else
> > +#ifndef __KERNEL__
> >  #include <stdint.h>
> >  #endif
> >  
> 
> That patch looks wrong, and unnecessary. It was fine before.
Nope - include/linux/dvb/audio.h failed to include linux/types.h
despite the fact that is uses __u32 etc.

But why the _kernel_ should include a userspace header is
much more questionable.

	Sam
