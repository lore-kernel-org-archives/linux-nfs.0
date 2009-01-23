From: Jaswinder Singh Rajput <jaswinder@kernel.org>
Subject: Re: [GIT PULL -tip] fix 33 make headers_check warnings
Date: Fri, 23 Jan 2009 22:01:44 +0530
Message-ID: <1232728304.3504.28.camel@localhost.localdomain>
References: <1232223441.3966.22.camel@localhost.localdomain>
	 <1232228261.27094.0.camel@macbook.infradead.org>
	 <20090117221932.GA4956@uranus.ravnborg.org> <49725B1E.604@kernel.org>
	 <1232498319.3123.34.camel@localhost.localdomain>
	 <1232726359.3504.18.camel@localhost.localdomain>
	 <1232726658.3504.22.camel@localhost.localdomain>
	 <alpine.LSU.2.00.0901231710350.15413@fbirervta.pbzchgretzou.qr>
	 <20090123162153.GA25766@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Jan Engelhardt <jengelh@medozas.de>,
	"H. Peter Anvin" <hpa@kernel.org>,
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
To: Sam Ravnborg <sam@ravnborg.org>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20090123162153.GA25766@uranus.ravnborg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-01-23 at 17:21 +0100, Sam Ravnborg wrote:
> On Fri, Jan 23, 2009 at 05:11:13PM +0100, Jan Engelhardt wrote:
> > 
> > On Friday 2009-01-23 17:04, Jaswinder Singh Rajput wrote:
> > >> > diff --git a/include/linux/dvb/audio.h b/include/linux/dvb/audio.h
> > >> > index 89412e1..758a48c 100644
> > >> > --- a/include/linux/dvb/audio.h
> > >> > +++ b/include/linux/dvb/audio.h
> > >> > @@ -24,9 +24,8 @@
> > >> >  #ifndef _DVBAUDIO_H_
> > >> >  #define _DVBAUDIO_H_
> > >> >  
> > >> > -#ifdef __KERNEL__
> > >> >  #include <linux/types.h>
> > >> > -#else
> > >> > +#ifndef __KERNEL__
> > >> >  #include <stdint.h>
> > >> >  #endif
> > >> > 
> > >> 
> > >> It seems one have objection for this. So I will again insert this in my
> > >> new patchset.
> > >> 
> > >
> > >oops, s/seems one/seems no one ;-)
> > 
> > I had an objection as previously stated -- namely that
> > <stdint.h> should be included to remain friendly to C++0x
> > programs which should use <cstdint> instead. Forcing
> > stdint.h is therefore not nice.
> 
> This is fully agreed.
> Jaswinder - can I ask you to do this change (remove of the stdint.h include)
> in a follow-up patch. It is two independent changes.
> You original patch is fine as is.

So is this OK:

-#ifdef __KERNEL__
 #include <linux/types.h>
-#else
-#include <stdint.h>
-#endif
-

--
JSR

