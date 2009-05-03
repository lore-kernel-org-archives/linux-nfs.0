From: Robert Schwebel <r.schwebel@pengutronix.de>
Subject: [patch] use ioctl.h instead of ttycom.h on Linux
Date: Sun, 3 May 2009 12:58:29 +0200
Message-ID: <20090503105829.GS15802@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: crossdev-iOHc7L4DgpLFDiOEh+KS6A@public.gmane.org
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:59970 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753468AbZECK6a (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 May 2009 06:58:30 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When compiling nfs-utils-1.1.6, I get this error:

arm-iwmmx-linux-gnueabi-gcc -DHAVE_CONFIG_H -I. -I../../support/include -isystem /home/rsc/svn/oselas/bsp/OSELAS.BSP-Pengutronix-AllYes-trunk/platform-phyCORE-PXA270.PCM990/sysroot-target/include -isystem /home/rsc/svn/oselas/bsp/OSELAS.BSP-Pengutronix-AllYes-trunk/platform-phyCORE-PXA270.PCM990/sysroot-target/usr/include -D_GNU_SOURCE -Wall -Wstrict-prototypes  -pipe -g -O2 -MT sm_inter_svc.o -MD -MP -MF .deps/sm_inter_svc.Tpo -c -o sm_inter_svc.o sm_inter_svc.c
sm_inter_svc.c:10:39: error: sys/ttycom.h: No such file or directory

Use sys/ioctl.h instead.

Signed-off-by: Robert Schwebel <r.schwebel@pengutronix.de>

---
 tools/rpcgen/rpc_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: nfs-utils-1.1.6/tools/rpcgen/rpc_main.c
===================================================================
--- nfs-utils-1.1.6.orig/tools/rpcgen/rpc_main.c
+++ nfs-utils-1.1.6/tools/rpcgen/rpc_main.c
@@ -550,7 +550,7 @@ s_output(int argc, char **argv, char *in
 	  f_print(fout, "#include <sys/ttycom.h>/* TIOCNOTTY */\n");
 #else
 	if( !tirpcflag )
-	  f_print(fout, "#include <sys/ttycom.h>/* TIOCNOTTY */\n");
+	  f_print(fout, "#include <sys/ioctl.h>/* TIOCNOTTY */\n");
 #endif
 	if( Cflag && (inetdflag || pmflag ) ) {
 	  f_print(fout, "#ifdef __cplusplus\n");

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
