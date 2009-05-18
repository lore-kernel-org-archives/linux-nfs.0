From: Robert Schwebel <r.schwebel@pengutronix.de>
Subject: Re: [patch] use ioctl.h instead of ttycom.h on Linux
Date: Mon, 18 May 2009 17:53:13 +0200
Message-ID: <20090518155313.GK19843@pengutronix.de>
References: <20090503105829.GS15802@pengutronix.de> <4A1180D4.4010305@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: linux-nfs@vger.kernel.org, crossdev-iOHc7L4DgpLFDiOEh+KS6A@public.gmane.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:56637 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752648AbZERPxN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 May 2009 11:53:13 -0400
In-Reply-To: <4A1180D4.4010305-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 18, 2009 at 11:37:56AM -0400, Steve Dickson wrote:
> Robert Schwebel wrote:
> > When compiling nfs-utils-1.1.6, I get this error:
> > 
> > arm-iwmmx-linux-gnueabi-gcc -DHAVE_CONFIG_H -I. -I../../support/include -isystem /home/rsc/svn/oselas/bsp/OSELAS.BSP-Pengutronix-AllYes-trunk/platform-phyCORE-PXA270.PCM990/sysroot-target/include -isystem /home/rsc/svn/oselas/bsp/OSELAS.BSP-Pengutronix-AllYes-trunk/platform-phyCORE-PXA270.PCM990/sysroot-target/usr/include -D_GNU_SOURCE -Wall -Wstrict-prototypes  -pipe -g -O2 -MT sm_inter_svc.o -MD -MP -MF .deps/sm_inter_svc.Tpo -c -o sm_inter_svc.o sm_inter_svc.c
> > sm_inter_svc.c:10:39: error: sys/ttycom.h: No such file or directory
> > 
> > Use sys/ioctl.h instead.
> > 
> > Signed-off-by: Robert Schwebel <r.schwebel@pengutronix.de>
> > 
> > ---
> Committed... 

Great, thanks!

rsc
-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
