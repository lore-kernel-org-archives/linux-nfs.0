From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [GIT PULL -tip] fix 33 make headers_check warnings
Date: Sun, 18 Jan 2009 09:23:00 +1100
Message-ID: <1232230980.27094.15.camel@macbook.infradead.org>
References: <1232223441.3966.22.camel@localhost.localdomain>
	 <1232228261.27094.0.camel@macbook.infradead.org>
	 <20090117221932.GA4956@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain
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
To: Sam Ravnborg <sam@ravnborg.org>
Return-path: <linux-raid-owner@vger.kernel.org>
In-Reply-To: <20090117221932.GA4956@uranus.ravnborg.org>
Sender: linux-raid-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2009-01-17 at 23:19 +0100, Sam Ravnborg wrote:
> Nope - include/linux/dvb/audio.h failed to include linux/types.h
> despite the fact that is uses __u32 etc.

Er, good point. I saw the <stdint.h> and assumed it was using only
proper C types... but then it wouldn't have triggered the warning, would
it? Too much time in tin cans and not enough sleep...

-- 
dwmw2

