From: Jaswinder Singh Rajput <jaswinder@kernel.org>
Subject: Re: [GIT PULL -tip] fix 33 make headers_check warnings
Date: Sun, 18 Jan 2009 08:35:01 +0530
Message-ID: <1232247901.3097.12.camel@localhost.localdomain>
References: <1232223441.3966.22.camel@localhost.localdomain>
	 <1232228261.27094.0.camel@macbook.infradead.org>
	 <20090117221932.GA4956@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Woodhouse <dwmw2@infradead.org>, Ingo Molnar <mingo@elte.hu>,
	x86 maintainers <x86@kernel.org>, urs.thuermann@volkswagen.de,
	oliver.hartkopp@volkswagen.de, linux-media@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	bfields@fieldses.org, neilb@suse.de, linux-nfs@vger.kernel.org,
	linux-raid@vger.kernel.org, dbrownell@users.sourceforge.net,
	spi-devel-general@lists.sourceforge.net, netdev@vger.kernel.org,
	greg@kroah.com, linux-usb@vger.kernel.org,
	linux-mtd@lists.infradead.org, tiwai@suse.de,
	mchehab@infradead.org, LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Sam Ravnborg <sam@ravnborg.org>
Return-path: <linux-raid-owner@vger.kernel.org>
In-Reply-To: <20090117221932.GA4956@uranus.ravnborg.org>
Sender: linux-raid-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello Sam, David,

On Sat, 2009-01-17 at 23:19 +0100, Sam Ravnborg wrote:
> On Sun, Jan 18, 2009 at 08:37:41AM +1100, David Woodhouse wrote:
> > On Sun, 2009-01-18 at 01:47 +0530, Jaswinder Singh Rajput wrote:
> > > --- a/include/linux/dvb/audio.h
> > > +++ b/include/linux/dvb/audio.h
> > > @@ -24,9 +24,8 @@
> > >  #ifndef _DVBAUDIO_H_
> > >  #define _DVBAUDIO_H_
> > >  
> > > -#ifdef __KERNEL__
> > >  #include <linux/types.h>
> > > -#else
> > > +#ifndef __KERNEL__
> > >  #include <stdint.h>
> > >  #endif
> > >  
> > 
> > That patch looks wrong, and unnecessary. It was fine before.
> Nope - include/linux/dvb/audio.h failed to include linux/types.h
> despite the fact that is uses __u32 etc.
> 

  CHECK   include/mtd (6 files)
/home/jaswinder/jaswinder-git/linux-2.6-tip/usr/include/mtd/jffs2-user.h:20: extern's make no sense in userspace

--
include/mtd/jffs2-user.h:

extern int target_endian;

#define t16(x) ({ uint16_t __b = (x); (target_endian==__BYTE_ORDER)?__b:bswap_16(__b); })
#define t32(x) ({ uint32_t __b = (x); (target_endian==__BYTE_ORDER)?__b:bswap_32(__b); })
--

In above case extern is OK or not ?

Do we have some better alternative.

Thanks
--
JSR

