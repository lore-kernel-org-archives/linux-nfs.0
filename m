From: Jaswinder Singh Rajput <jaswinder@kernel.org>
Subject: Re: [GIT PULL -tip] fix 33 make headers_check warnings
Date: Wed, 21 Jan 2009 06:08:39 +0530
Message-ID: <1232498319.3123.34.camel@localhost.localdomain>
References: <1232223441.3966.22.camel@localhost.localdomain>
	 <1232228261.27094.0.camel@macbook.infradead.org>
	 <20090117221932.GA4956@uranus.ravnborg.org>  <49725B1E.604@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sam Ravnborg <sam-uyr5N9Q2VtJg9hUCZPvPmw@public.gmane.org>,
	David Woodhouse <dwmw2@infradead.org>,
	Ingo Molnar <mingo@elte.hu>, x86 maintainers <x86@kernel.org>,
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
To: "H. Peter Anvin" <hpa@kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:55336 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756875AbZAUAkE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Jan 2009 19:40:04 -0500
In-Reply-To: <49725B1E.604@kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2009-01-17 at 14:26 -0800, H. Peter Anvin wrote:
> Sam Ravnborg wrote:
> >>>  
> >> That patch looks wrong, and unnecessary. It was fine before.
> > Nope - include/linux/dvb/audio.h failed to include linux/types.h
> > despite the fact that is uses __u32 etc.
> > 
> > But why the _kernel_ should include a userspace header is
> > much more questionable.
> > 
> 
> <stdint.h> is one of a handful of headers provided by gcc itself.
> 

Should I reintroduce my patch to solve this warning of 'make headers_check':
 usr/include/linux/dvb/audio.h:133: found __[us]{8,16,32,64} type without #include <linux/types.h>

diff --git a/include/linux/dvb/audio.h b/include/linux/dvb/audio.h
index 89412e1..758a48c 100644
--- a/include/linux/dvb/audio.h
+++ b/include/linux/dvb/audio.h
@@ -24,9 +24,8 @@
 #ifndef _DVBAUDIO_H_
 #define _DVBAUDIO_H_
 
-#ifdef __KERNEL__
 #include <linux/types.h>
-#else
+#ifndef __KERNEL__
 #include <stdint.h>
 #endif

Or you guys have some better plan.

Thanks,

--
JSR


