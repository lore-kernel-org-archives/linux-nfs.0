Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:63905 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754012Ab2DXXXP convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Apr 2012 19:23:15 -0400
Received: by pbbro12 with SMTP id ro12so693128pbb.19
        for <linux-nfs@vger.kernel.org>; Tue, 24 Apr 2012 16:23:15 -0700 (PDT)
MIME-Version: 1.0
Date: Tue, 24 Apr 2012 19:23:15 -0400
Message-ID: <CA+WntOuEeVYNJbmeS9vqkTJt8+sTAc=6zDT757+KTGu7LY5eUg@mail.gmail.com>
Subject: nfs-utils-1.2.5 getpagesize error in utils/blkmpd/device-process.c
From: Super Bisquit <superbisquit@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

root@dookie-bomb:/tmp/nfs-utils-1.2.5/utils/blkmapd# make
gcc -DHAVE_CONFIG_H -I. -I../../support/include   -D_GNU_SOURCE -Wall
-Wextra -Wstrict-prototypes  -pipe -D_LARGEFILE64_SOURCE -g -O2 -MT
device-discovery.o -MD -MP -MF .deps/device-discovery.Tpo -c -o
device-discovery.o device-discovery.c
mv -f .deps/device-discovery.Tpo .deps/device-discovery.Po
gcc -DHAVE_CONFIG_H -I. -I../../support/include   -D_GNU_SOURCE -Wall
-Wextra -Wstrict-prototypes  -pipe -D_LARGEFILE64_SOURCE -g -O2 -MT
device-inq.o -MD -MP -MF .deps/device-inq.Tpo -c -o device-inq.o
device-inq.c
mv -f .deps/device-inq.Tpo .deps/device-inq.Po
gcc -DHAVE_CONFIG_H -I. -I../../support/include   -D_GNU_SOURCE -Wall
-Wextra -Wstrict-prototypes  -pipe -D_LARGEFILE64_SOURCE -g -O2 -MT
device-process.o -MD -MP -MF .deps/device-process.Tpo -c -o
device-process.o device-process.c
device-process.c: In function ‘decode_blk_volume’:
device-process.c:299: error: ‘PAGE_SIZE’ undeclared (first use in this function)
device-process.c:299: error: (Each undeclared identifier is reported only once
device-process.c:299: error: for each function it appears in.)
make: *** [device-process.o] Error 1
root@dookie-bomb:/tmp/nfs-utils-1.2.5/utils/blkmapd#

http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=223219 I looked t
this for suggestions.
