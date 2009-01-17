From: "H. Peter Anvin" <hpa@kernel.org>
Subject: Re: [GIT PULL -tip] fix 33 make headers_check warnings
Date: Sat, 17 Jan 2009 14:26:38 -0800
Message-ID: <49725B1E.604@kernel.org>
References: <1232223441.3966.22.camel@localhost.localdomain> <1232228261.27094.0.camel@macbook.infradead.org> <20090117221932.GA4956@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Woodhouse <dwmw2@infradead.org>,
	Jaswinder Singh Rajput <jaswinder@kernel.org>,
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
To: Sam Ravnborg <sam@ravnborg.org>
Return-path: <linux-media-owner@vger.kernel.org>
In-Reply-To: <20090117221932.GA4956@uranus.ravnborg.org>
Sender: linux-media-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sam Ravnborg wrote:
>>>  
>> That patch looks wrong, and unnecessary. It was fine before.
> Nope - include/linux/dvb/audio.h failed to include linux/types.h
> despite the fact that is uses __u32 etc.
> 
> But why the _kernel_ should include a userspace header is
> much more questionable.
> 

<stdint.h> is one of a handful of headers provided by gcc itself.

	-hpa
