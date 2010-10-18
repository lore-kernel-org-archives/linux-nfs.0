Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:39703 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932154Ab0JRP7l (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Oct 2010 11:59:41 -0400
Received: by pxi16 with SMTP id 16so174729pxi.19
        for <linux-nfs@vger.kernel.org>; Mon, 18 Oct 2010 08:59:40 -0700 (PDT)
From: Peng Tao <bergwolf@gmail.com>
Date: Mon, 18 Oct 2010 23:55:59 +0800
Message-ID: <AANLkTin3xF4+QbG8G2pgiUxv9mUMmFOnQOUD2C1ocVrA@mail.gmail.com>
Subject: pnfs-nfs-utils compile errors
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi, Benny and Jim,

I fail to compile with pnfs-nfs-utils master branch (commit
48a8d6b13b2f0b720267b1af104addb7426e7cc9). It fails in blkmapd
directory. Are the files cfg.c and cfg.h missing or deleted?

from pnfs-nfs-utils/utils/blkmapd/Makefile
259 blkmapd_SOURCES = \
260         atomicio.c \
261         cfg.c \
262         device-discovery.c \
263         device-inq.c \
264         device-process.c \
265         dm-device.c \
266         \
267         cfg.h \
268         device-discovery.h
[SID@blkmapd]$pwd
/home/bergwolf/src/pnfs-nfs-utils/utils/blkmapd
[SID@blkmapd]$ls
atomicio.c  device-discovery.c  device-inq.c      dm-device.c
Makefile     Makefile.in
atomicio.o  device-discovery.h  device-process.c  etc          Makefile.am

[SID@pnfs-nfs-utils]$./configure --enable-nfsv41
[SID@pnfs-nfs-utils]$make
<snip>
make[2]: Entering directory `/home/bergwolf/src/pnfs-nfs-utils/utils/blkmapd'
gcc -DHAVE_CONFIG_H -I. -I../../support/include  -I/usr/include/tirpc
-D_GNU_SOURCE -Wall -Wstrict-prototypes  -pipe -D_LARGEFILE64_SOURCE
-g -O2 -MT atomicio.o -MD -MP -MF .deps/atomicio.Tpo -c -o atomicio.o
atomicio.c
mv -f .deps/atomicio.Tpo .deps/atomicio.Po
make[2]: *** No rule to make target `cfg.o', needed by `blkmapd'.  Stop.
make[2]: Leaving directory `/home/bergwolf/src/pnfs-nfs-utils/utils/blkmapd'
make[1]: *** [all-recursive] Error 1
make[1]: Leaving directory `/home/bergwolf/src/pnfs-nfs-utils/utils'
make: *** [all-recursive] Error 1

-- 
Thanks,
-Bergwolf
