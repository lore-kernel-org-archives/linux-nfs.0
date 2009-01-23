From: Jaswinder Singh Rajput <jaswinder@kernel.org>
Subject: Re: [GIT PULL -tip] fix 33 make headers_check warnings
Date: Fri, 23 Jan 2009 22:58:37 +0530
Message-ID: <1232731717.3504.36.camel@localhost.localdomain>
References: <1232223441.3966.22.camel@localhost.localdomain>
	 <1232228261.27094.0.camel@macbook.infradead.org>
	 <20090117221932.GA4956@uranus.ravnborg.org> <49725B1E.604@kernel.org>
	 <1232498319.3123.34.camel@localhost.localdomain>
	 <1232726359.3504.18.camel@localhost.localdomain>
	 <1232726658.3504.22.camel@localhost.localdomain>
	 <alpine.LSU.2.00.0901231710350.15413@fbirervta.pbzchgretzou.qr>
	 <20090123162153.GA25766@uranus.ravnborg.org>
	 <1232728304.3504.28.camel@localhost.localdomain>
	 <20090123170904.GA26083@uranus.ravnborg.org>
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
Return-path: <linux-media-owner@vger.kernel.org>
In-Reply-To: <20090123170904.GA26083@uranus.ravnborg.org>
Sender: linux-media-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-01-23 at 18:09 +0100, Sam Ravnborg wrote:
> On Fri, Jan 23, 2009 at 10:01:44PM +0530, Jaswinder Singh Rajput wrote:

> > So is this OK:
> > 
> > -#ifdef __KERNEL__
> >  #include <linux/types.h>
> > -#else
> > -#include <stdint.h>
> > -#endif
> 
> That was what I expected the final change to look like.
> If you want then combine it in one patch.
> 

Ok, thanks.

--
JSR

