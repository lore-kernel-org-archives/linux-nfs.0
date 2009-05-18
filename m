From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [patch] use ioctl.h instead of ttycom.h on Linux
Date: Mon, 18 May 2009 11:37:56 -0400
Message-ID: <4A1180D4.4010305@RedHat.com>
References: <20090503105829.GS15802@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Cc: linux-nfs@vger.kernel.org, crossdev-iOHc7L4DgpLFDiOEh+KS6A@public.gmane.org
To: Robert Schwebel <r.schwebel@pengutronix.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:39242 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753450AbZERPk7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 May 2009 11:40:59 -0400
In-Reply-To: <20090503105829.GS15802@pengutronix.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Robert Schwebel wrote:
> When compiling nfs-utils-1.1.6, I get this error:
> 
> arm-iwmmx-linux-gnueabi-gcc -DHAVE_CONFIG_H -I. -I../../support/include -isystem /home/rsc/svn/oselas/bsp/OSELAS.BSP-Pengutronix-AllYes-trunk/platform-phyCORE-PXA270.PCM990/sysroot-target/include -isystem /home/rsc/svn/oselas/bsp/OSELAS.BSP-Pengutronix-AllYes-trunk/platform-phyCORE-PXA270.PCM990/sysroot-target/usr/include -D_GNU_SOURCE -Wall -Wstrict-prototypes  -pipe -g -O2 -MT sm_inter_svc.o -MD -MP -MF .deps/sm_inter_svc.Tpo -c -o sm_inter_svc.o sm_inter_svc.c
> sm_inter_svc.c:10:39: error: sys/ttycom.h: No such file or directory
> 
> Use sys/ioctl.h instead.
> 
> Signed-off-by: Robert Schwebel <r.schwebel@pengutronix.de>
> 
> ---
Committed... 
