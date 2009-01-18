From: Jaswinder Singh Rajput <jaswinder@kernel.org>
Subject: Re: [GIT PULL -tip] fix 33 make headers_check warnings
Date: Sun, 18 Jan 2009 08:16:20 +0530
Message-ID: <1232246780.3097.4.camel@localhost.localdomain>
References: <1232223441.3966.22.camel@localhost.localdomain>
	 <1232228261.27094.0.camel@macbook.infradead.org>
	 <20090117221932.GA4956@uranus.ravnborg.org>
	 <1232230980.27094.15.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sam Ravnborg <sam-uyr5N9Q2VtJg9hUCZPvPmw@public.gmane.org>, Ingo Molnar <mingo@elte.hu>,
	x86 maintainers <x86@kernel.org>, urs.thuermann-l29pVbxQd1IUtdQbppsyvg@public.gmane.org,
	oliver.hartkopp-l29pVbxQd1IUtdQbppsyvg@public.gmane.org, linux-media@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	bfields@fieldses.org, neilb@suse.de, linux-nfs@vger.kernel.org,
	linux-raid@vger.kernel.org, dbrownell@users.sourceforge.net,
	spi-devel-general@lists.sourceforge.net, netdev@vger.kernel.org,
	greg@kroah.com, linux-usb@vger.kernel.org,
	linux-mtd@lists.infradead.org, tiwai@suse.de,
	mchehab@infradead.org, LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:42364 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753598AbZARCrr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 17 Jan 2009 21:47:47 -0500
In-Reply-To: <1232230980.27094.15.camel-uXGAPMMVk8bAQYKIod7YupZV94DADvEd@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello David,

On Sun, 2009-01-18 at 09:23 +1100, David Woodhouse wrote:
> On Sat, 2009-01-17 at 23:19 +0100, Sam Ravnborg wrote:
> > Nope - include/linux/dvb/audio.h failed to include linux/types.h
> > despite the fact that is uses __u32 etc.
> 
> Er, good point. I saw the <stdint.h> and assumed it was using only
> proper C types... but then it wouldn't have triggered the warning, would
> it? Too much time in tin cans and not enough sleep...
> 

Here is the list of 33  warnings this patchset solves:

  CHECK   include/linux/can (3 files)
/home/jaswinder/jaswinder-git/linux-2.6-tip/usr/include/linux/can/bcm.h:29: found __[us]{8,16,32,64} type without #include <linux/types.h>
  CHECK   include/linux/dvb (8 files)
/home/jaswinder/jaswinder-git/linux-2.6-tip/usr/include/linux/dvb/audio.h:133: found __[us]{8,16,32,64} type without #include <linux/types.h>
/home/jaswinder/jaswinder-git/linux-2.6-tip/usr/include/linux/dvb/dmx.h:27: include of <linux/types.h> is preferred over <asm/types.h>
/home/jaswinder/jaswinder-git/linux-2.6-tip/usr/include/linux/dvb/dmx.h:90: found __[us]{8,16,32,64} type without #include <linux/types.h>
/home/jaswinder/jaswinder-git/linux-2.6-tip/usr/include/linux/dvb/frontend.h:29: include of <linux/types.h> is preferred over <asm/types.h>
/home/jaswinder/jaswinder-git/linux-2.6-tip/usr/include/linux/dvb/frontend.h:76: found __[us]{8,16,32,64} type without #include <linux/types.h>
/home/jaswinder/jaswinder-git/linux-2.6-tip/usr/include/linux/dvb/net.h:27: include of <linux/types.h> is preferred over <asm/types.h>
/home/jaswinder/jaswinder-git/linux-2.6-tip/usr/include/linux/dvb/net.h:31: found __[us]{8,16,32,64} type without #include <linux/types.h>
/home/jaswinder/jaswinder-git/linux-2.6-tip/usr/include/linux/dvb/video.h:29: include of <linux/types.h> is preferred over <asm/types.h>
/home/jaswinder/jaswinder-git/linux-2.6-tip/usr/include/linux/dvb/video.h:102: found __[us]{8,16,32,64} type without #include <linux/types.h>
  CHECK   include/linux/hdlc (1 files)
  CHECK   include/linux/isdn (1 files)
  CHECK   include/linux/netfilter (49 files)
/home/jaswinder/jaswinder-git/linux-2.6-tip/usr/include/linux/netfilter/xt_conntrack.h:40: found __[us]{8,16,32,64} type without #include <linux/types.h>
  CHECK   include/linux/netfilter_arp (2 files)
  CHECK   include/linux/netfilter_bridge (16 files)
  CHECK   include/linux/netfilter_ipv4 (46 files)
  CHECK   include/linux/netfilter_ipv6 (20 files)
  CHECK   include/linux/nfsd (6 files)
/home/jaswinder/jaswinder-git/linux-2.6-tip/usr/include/linux/nfsd/export.h:13: include of <linux/types.h> is preferred over <asm/types.h>
/home/jaswinder/jaswinder-git/linux-2.6-tip/usr/include/linux/nfsd/nfsfh.h:17: include of <linux/types.h> is preferred over <asm/types.h>
/home/jaswinder/jaswinder-git/linux-2.6-tip/usr/include/linux/nfsd/nfsfh.h:28: found __[us]{8,16,32,64} type without #include <linux/types.h>
/home/jaswinder/jaswinder-git/linux-2.6-tip/usr/include/linux/nfsd/stats.h:32: leaks CONFIG_NFSD to userspace where it is not valid
/home/jaswinder/jaswinder-git/linux-2.6-tip/usr/include/linux/nfsd/syscall.h:12: include of <linux/types.h> is preferred over <asm/types.h>
/home/jaswinder/jaswinder-git/linux-2.6-tip/usr/include/linux/nfsd/syscall.h:104: found __[us]{8,16,32,64} type without #include <linux/types.h>
  CHECK   include/linux/raid (2 files)
/home/jaswinder/jaswinder-git/linux-2.6-tip/usr/include/linux/raid/md_p.h:85: found __[us]{8,16,32,64} type without #include <linux/types.h>
  CHECK   include/linux/spi (1 files)
/home/jaswinder/jaswinder-git/linux-2.6-tip/usr/include/linux/spi/spidev.h:83: found __[us]{8,16,32,64} type without #include <linux/types.h>
  CHECK   include/linux/sunrpc (1 files)
  CHECK   include/linux/tc_act (6 files)
/home/jaswinder/jaswinder-git/linux-2.6-tip/usr/include/linux/tc_act/tc_gact.h:19: found __[us]{8,16,32,64} type without #include <linux/types.h>
/home/jaswinder/jaswinder-git/linux-2.6-tip/usr/include/linux/tc_act/tc_mirred.h:16: found __[us]{8,16,32,64} type without #include <linux/types.h>
/home/jaswinder/jaswinder-git/linux-2.6-tip/usr/include/linux/tc_act/tc_pedit.h:19: found __[us]{8,16,32,64} type without #include <linux/types.h>
  CHECK   include/linux/tc_ematch (4 files)
/home/jaswinder/jaswinder-git/linux-2.6-tip/usr/include/linux/tc_ematch/tc_em_cmp.h:8: found __[us]{8,16,32,64} type without #include <linux/types.h>
/home/jaswinder/jaswinder-git/linux-2.6-tip/usr/include/linux/tc_ematch/tc_em_meta.h:18: found __[us]{8,16,32,64} type without #include <linux/types.h>
/home/jaswinder/jaswinder-git/linux-2.6-tip/usr/include/linux/tc_ematch/tc_em_nbyte.h:8: found __[us]{8,16,32,64} type without #include <linux/types.h>
/home/jaswinder/jaswinder-git/linux-2.6-tip/usr/include/linux/tc_ematch/tc_em_text.h:11: found __[us]{8,16,32,64} type without #include <linux/types.h>
  CHECK   include/linux/usb (8 files)
/home/jaswinder/jaswinder-git/linux-2.6-tip/usr/include/linux/usb/cdc.h:50: found __[us]{8,16,32,64} type without #include <linux/types.h>
/home/jaswinder/jaswinder-git/linux-2.6-tip/usr/include/linux/usb/gadgetfs.h:21: include of <linux/types.h> is preferred over <asm/types.h>
  CHECK   include/linux/wimax (1 files)
  CHECK   include/mtd (6 files)
/home/jaswinder/jaswinder-git/linux-2.6-tip/usr/include/mtd/inftl-user.h:61: found __[us]{8,16,32,64} type without #include <linux/types.h>
  CHECK   include/rdma (1 files)
  CHECK   include/sound (9 files)
/home/jaswinder/jaswinder-git/linux-2.6-tip/usr/include/sound/hdsp.h:33: found __[us]{8,16,32,64} type without #include <linux/types.h>
  CHECK   include/video (3 files)
/home/jaswinder/jaswinder-git/linux-2.6-tip/usr/include/video/sisfb.h:25: include of <linux/types.h> is preferred over <asm/types.h>
/home/jaswinder/jaswinder-git/linux-2.6-tip/usr/include/video/sisfb.h:78: found __[us]{8,16,32,64} type without #include <linux/types.h>
/home/jaswinder/jaswinder-git/linux-2.6-tip/usr/include/video/uvesafb.h:5: found __[us]{8,16,32,64} type without #include <linux/types.h>

--
JSR

