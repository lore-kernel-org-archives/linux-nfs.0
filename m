From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: nfs-utils-1.1.2
Date: Wed, 19 Mar 2008 18:03:52 -0400
Message-ID: <4d569c330803191503g73ec5100y155aed65c8545fd0@mail.gmail.com>
References: <x63aqnq6vw@gzp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "Gabor Z. Papp" <gzp-2g/1Y3AqmNE@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.186]:43635 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161455AbYCSWDz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Mar 2008 18:03:55 -0400
Received: by gv-out-0910.google.com with SMTP id s4so247136gve.37
        for <linux-nfs@vger.kernel.org>; Wed, 19 Mar 2008 15:03:53 -0700 (PDT)
In-Reply-To: <x63aqnq6vw@gzp>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Yes, both idmapd and libnfsidmap have cfg.[ch] to process the config
file.  The version in idmapd has been enhanced to add a new function,
conf_get_str_with_def.

To get around the problem you're seeing, I'd suggest removing cfg.c
from the list of files in libnfsidmap.

I'll have to think about a permanent solution, which may be to have
idmapd use the code in libnfsidmap.

BTW, why do you need to statically link libnfsidmap?

K.C.

On Wed, Mar 19, 2008 at 7:40 AM, Gabor Z. Papp <gzp-2g/1Y3AqmNE@public.gmane.org> wrote:
> Hello,
>
>  I'm trying to compile nfs-utils 1.1.2 with nfs4 support, but in the
>  following environment:
>
>  Linux 2.4
>  glibc 2.3.5
>  static libevent and libnfsidmap
>
>  I'm getting the following problem:
>
>  /bin/sh ../../libtool --tag=CC   --mode=link gcc -Wall -Wstrict-prototypes  -pipe -g -O2   -o idmapd atomicio.o cfg.o idmapd.o strlcat.o strlcpy.o -lrt -levent -lnfsidmap ../../support/nfs/libnfs.a
>  gcc -Wall -Wstrict-prototypes -pipe -g -O2 -o idmapd atomicio.o cfg.o idmapd.o strlcat.o strlcpy.o  -lrt -levent -lnfsidmap ../../support/nfs/libnfs.a
>  /pkg/lib/gcc/i686-pc-linux-gnu/4.2.4/../../../libnfsidmap.a(cfg.o): In function `conf_begin':
>  /home/gzp/src/libnfsidmap-0.20/cfg.c:641: multiple definition of `conf_begin'
>  cfg.o:/home/gzp/src/nfs-utils-1.1.2/utils/idmapd/cfg.c:628: first defined here
>  /pkg/lib/gcc/i686-pc-linux-gnu/4.2.4/../../../libnfsidmap.a(cfg.o): In function `conf_decode_base64':
>  /home/gzp/src/libnfsidmap-0.20/cfg.c:558: multiple definition of `conf_decode_base64'
>  cfg.o:/home/gzp/src/nfs-utils-1.1.2/utils/idmapd/cfg.c:545: first defined here
>  /pkg/lib/gcc/i686-pc-linux-gnu/4.2.4/../../../libnfsidmap.a(cfg.o):(.rodata+0x60): multiple definition of `asc2bin'
>  cfg.o:(.rodata+0x60): first defined here
>  /pkg/lib/gcc/i686-pc-linux-gnu/4.2.4/../../../libnfsidmap.a(cfg.o): In function `conf_report':
>  /home/gzp/src/libnfsidmap-0.20/cfg.c:829: multiple definition of `conf_report'
>  cfg.o:/home/gzp/src/nfs-utils-1.1.2/utils/idmapd/cfg.c:816: first defined here
>  /pkg/lib/gcc/i686-pc-linux-gnu/4.2.4/../../../libnfsidmap.a(cfg.o): In function `conf_free_list':
>  /home/gzp/src/libnfsidmap-0.20/cfg.c:622: multiple definition of `conf_free_list'
>  cfg.o:/home/gzp/src/nfs-utils-1.1.2/utils/idmapd/cfg.c:609: first defined here
>  /pkg/lib/gcc/i686-pc-linux-gnu/4.2.4/../../../libnfsidmap.a(cfg.o): In function `conf_remove_section':
>  /home/gzp/src/libnfsidmap-0.20/cfg.c:738: multiple definition of `conf_remove_section'
>  cfg.o:/home/gzp/src/nfs-utils-1.1.2/utils/idmapd/cfg.c:725: first defined here
>  /pkg/lib/gcc/i686-pc-linux-gnu/4.2.4/../../../libnfsidmap.a(cfg.o): In function `conf_remove':
>  /home/gzp/src/libnfsidmap-0.20/cfg.c:707: multiple definition of `conf_remove'
>  cfg.o:/home/gzp/src/nfs-utils-1.1.2/utils/idmapd/cfg.c:694: first defined here
>  /pkg/lib/gcc/i686-pc-linux-gnu/4.2.4/../../../libnfsidmap.a(cfg.o): In function `conf_set':
>  /home/gzp/src/libnfsidmap-0.20/cfg.c:666: multiple definition of `conf_set'
>  cfg.o:/home/gzp/src/nfs-utils-1.1.2/utils/idmapd/cfg.c:653: first defined here
>  /pkg/lib/gcc/i686-pc-linux-gnu/4.2.4/../../../libnfsidmap.a(cfg.o): In function `conf_get_tag_list':
>  /home/gzp/src/libnfsidmap-0.20/cfg.c:524: multiple definition of `conf_get_tag_list'
>  cfg.o:/home/gzp/src/nfs-utils-1.1.2/utils/idmapd/cfg.c:509: first defined here
>  /pkg/lib/gcc/i686-pc-linux-gnu/4.2.4/../../../libnfsidmap.a(cfg.o): In function `conf_get_str':
>  /home/gzp/src/libnfsidmap-0.20/cfg.c:435: multiple definition of `conf_get_str'
>  cfg.o:/home/gzp/src/nfs-utils-1.1.2/utils/idmapd/cfg.c:435: first defined here
>  /pkg/lib/gcc/i686-pc-linux-gnu/4.2.4/../../../libnfsidmap.a(cfg.o): In function `conf_get_list':
>  /home/gzp/src/libnfsidmap-0.20/cfg.c:471: multiple definition of `conf_get_list'
>  cfg.o:/home/gzp/src/nfs-utils-1.1.2/utils/idmapd/cfg.c:454: first defined here
>  /pkg/lib/gcc/i686-pc-linux-gnu/4.2.4/../../../libnfsidmap.a(cfg.o): In function `conf_match_num':
>  /home/gzp/src/libnfsidmap-0.20/cfg.c:410: multiple definition of `conf_match_num'
>  cfg.o:/home/gzp/src/nfs-utils-1.1.2/utils/idmapd/cfg.c:410: first defined here
>  /pkg/lib/gcc/i686-pc-linux-gnu/4.2.4/../../../libnfsidmap.a(cfg.o): In function `conf_get_num':
>  /home/gzp/src/libnfsidmap-0.20/cfg.c:399: multiple definition of `conf_get_num'
>  cfg.o:/home/gzp/src/nfs-utils-1.1.2/utils/idmapd/cfg.c:399: first defined here
>  /pkg/lib/gcc/i686-pc-linux-gnu/4.2.4/../../../libnfsidmap.a(cfg.o): In function `conf_end':
>  /home/gzp/src/libnfsidmap-0.20/cfg.c:761: multiple definition of `conf_end'
>  cfg.o:/home/gzp/src/nfs-utils-1.1.2/utils/idmapd/cfg.c:748: first defined here
>  /pkg/lib/gcc/i686-pc-linux-gnu/4.2.4/../../../libnfsidmap.a(cfg.o): In function `conf_reinit':
>  /home/gzp/src/libnfsidmap-0.20/cfg.c:328: multiple definition of `conf_reinit'
>  cfg.o:/home/gzp/src/nfs-utils-1.1.2/utils/idmapd/cfg.c:328: first defined here
>  /pkg/lib/gcc/i686-pc-linux-gnu/4.2.4/../../../libnfsidmap.a(cfg.o): In function `conf_init':
>  /home/gzp/src/libnfsidmap-0.20/cfg.c:316: multiple definition of `conf_init'
>  cfg.o:/home/gzp/src/nfs-utils-1.1.2/utils/idmapd/cfg.c:316: first defined here
>  /pkg/lib/gcc/i686-pc-linux-gnu/4.2.4/../../../libnfsidmap.a(cfg.o):(.rodata+0x0): multiple definition of `bin2asc'
>  cfg.o:(.rodata+0x0): first defined here
>  collect2: ld returned 1 exit status
>  make: *** [idmapd] Error 1
>  --
>  To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>  the body of a message to majordomo@vger.kernel.org
>  More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
