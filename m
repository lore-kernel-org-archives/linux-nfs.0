From: Jaswinder Singh Rajput <jaswinder@kernel.org>
Subject: Re: [GIT PULL -tip] fix 33 make headers_check warnings
Date: Fri, 23 Jan 2009 21:34:18 +0530
Message-ID: <1232726658.3504.22.camel@localhost.localdomain>
References: <1232223441.3966.22.camel@localhost.localdomain>
	 <1232228261.27094.0.camel@macbook.infradead.org>
	 <20090117221932.GA4956@uranus.ravnborg.org>  <49725B1E.604@kernel.org>
	 <1232498319.3123.34.camel@localhost.localdomain>
	 <1232726359.3504.18.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sam Ravnborg <sam@ravnborg.org>,
	David Woodhouse <dwmw2@infradead.org>,
	Ingo Molnar <mingo@elte.hu>, x86 maintainers <x86@kernel.org>,
	urs.thuermann@volkswagen.de, oliver.hartkopp@volkswagen.de,
	linux-media@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, bfields@fieldses.org, neilb@suse.de,
	linux-nfs@vger.kernel.org, linux-raid@vger.kernel.org,
	dbrownell@users.sourceforge.net, netdev@vger.kernel.org,
	greg@kroah.com, linux-usb@vger.kernel.org,
	linux-mtd@lists.infradead.org, tiwai@suse.de,
	mchehab@infradead.org, LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: "H. Peter Anvin" <hpa@kernel.org>
Return-path: <linux-raid-owner@vger.kernel.org>
In-Reply-To: <1232726359.3504.18.camel@localhost.localdomain>
Sender: linux-raid-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-01-23 at 21:29 +0530, Jaswinder Singh Rajput wrote:
> On Wed, 2009-01-21 at 06:08 +0530, Jaswinder Singh Rajput wrote:
> > On Sat, 2009-01-17 at 14:26 -0800, H. Peter Anvin wrote:
> > > Sam Ravnborg wrote:
> > > >>>  
> > > >> That patch looks wrong, and unnecessary. It was fine before.
> > > > Nope - include/linux/dvb/audio.h failed to include linux/types.h
> > > > despite the fact that is uses __u32 etc.
> > > > 
> > > > But why the _kernel_ should include a userspace header is
> > > > much more questionable.
> > > > 
> > > 
> > > <stdint.h> is one of a handful of headers provided by gcc itself.
> > > 
> > 
> > Should I reintroduce my patch to solve this warning of 'make headers_check':
> >  usr/include/linux/dvb/audio.h:133: found __[us]{8,16,32,64} type without #include <linux/types.h>
> > 
> > diff --git a/include/linux/dvb/audio.h b/include/linux/dvb/audio.h
> > index 89412e1..758a48c 100644
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
> It seems one have objection for this. So I will again insert this in my
> new patchset.
> 

oops, s/seems one/seems no one ;-)

--
JSR

