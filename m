From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [GIT PULL -tip] fix 33 make headers_check warnings
Date: Sun, 18 Jan 2009 08:37:41 +1100
Message-ID: <1232228261.27094.0.camel@macbook.infradead.org>
References: <1232223441.3966.22.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ingo Molnar <mingo@elte.hu>, x86 maintainers <x86@kernel.org>,
	urs.thuermann-l29pVbxQd1IUtdQbppsyvg@public.gmane.org, oliver.hartkopp-l29pVbxQd1IUtdQbppsyvg@public.gmane.org,
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
Return-path: <linux-usb-owner@vger.kernel.org>
In-Reply-To: <1232223441.3966.22.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-usb-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 2009-01-18 at 01:47 +0530, Jaswinder Singh Rajput wrote:
> --- a/include/linux/dvb/audio.h
> +++ b/include/linux/dvb/audio.h
> @@ -24,9 +24,8 @@
>  #ifndef _DVBAUDIO_H_
>  #define _DVBAUDIO_H_
>  
> -#ifdef __KERNEL__
>  #include <linux/types.h>
> -#else
> +#ifndef __KERNEL__
>  #include <stdint.h>
>  #endif
>  

That patch looks wrong, and unnecessary. It was fine before.

-- 
dwmw2

