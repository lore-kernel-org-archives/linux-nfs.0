From: Kyle McMartin <kyle@infradead.org>
Subject: Re: [GIT PULL -tip] fix 33 make headers_check warnings
Date: Sat, 17 Jan 2009 22:33:39 -0500
Message-ID: <20090118033339.GA671@bombadil.infradead.org>
References: <1232223441.3966.22.camel@localhost.localdomain> <1232228261.27094.0.camel@macbook.infradead.org> <20090117221932.GA4956@uranus.ravnborg.org> <1232247901.3097.12.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sam Ravnborg <sam@ravnborg.org>,
	David Woodhouse <dwmw2@infradead.org>,
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
To: Jaswinder Singh Rajput <jaswinder@kernel.org>
Return-path: <linux-media-owner@vger.kernel.org>
In-Reply-To: <1232247901.3097.12.camel@localhost.localdomain>
Sender: linux-media-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jan 18, 2009 at 08:35:01AM +0530, Jaswinder Singh Rajput wrote:
> Hello Sam, David,
> 
> /home/jaswinder/jaswinder-git/linux-2.6-tip/usr/include/mtd/jffs2-user.h:20: extern's make no sense in userspace
> 

This file is for userspace only, and it makes sense where it's used
(mtd-utils.)

In general though, this file doesn't actually depend on the kernel and
could be entirely provided from the userspace library.

http://lkml.org/lkml/2006/12/1/180

