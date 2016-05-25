Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:36716 "EHLO
	mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750733AbcEYIBA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 May 2016 04:01:00 -0400
MIME-Version: 1.0
In-Reply-To: <20160525072027.5107.qmail@ns.sciencehorizons.net>
References: <CA+55aFxPSW+84KfQ1N_WmND-wtvgj2zQm8nFPkRcc+gyU=uing@mail.gmail.com>
	<20160525072027.5107.qmail@ns.sciencehorizons.net>
Date: Wed, 25 May 2016 10:00:59 +0200
Message-ID: <CAMuHMdUUCYfGfX1CDVxxihGSC+dz2D1JJVXUWC5H0_W-MmHe7Q@mail.gmail.com>
Subject: Re: [PATCH 00/10] String hash improvements
From: Geert Uytterhoeven <geert@linux-m68k.org>
To: George Spelvin <linux@sciencehorizons.net>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        alistair.francis@xilinx.com, Bruce Fields <bfields@fieldses.org>,
        Greg Ungerer <gerg@linux-m68k.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        linux-m68k <linux-m68k@vger.kernel.org>,
        "open list:NFS, SUNRPC, AND..." <linux-nfs@vger.kernel.org>,
        Michal Simek <michal.simek@xilinx.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        uclinux-h8-devel@lists.sourceforge.jp,
        Yoshinori Sato <ysato@users.sourceforge.jp>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi George,

On Wed, May 25, 2016 at 9:20 AM, George Spelvin
<linux@sciencehorizons.net> wrote:
> I'm not particularly fond of the names of the header files I created,
> but if anyone has a better idea please talk fast!

Usually this is handled through include/asm-generic/.
Put the generic default implementation in include/asm-generic/hash.h.

Architectures that need to override provide their own version, e.g.
arch/m68k/include/asm/hash.h. They may #include <asm-generic/hash.h>
if they still want to reuse parts of the generic implementation.

Other architectures add "generic-y += hash.h" to their
arch/<ARCH>/include/asm/Kbuild.

<linux/hash.h> includes <asm/hash.h> t.

>  arch/h8300/include/asm/archhash.h      |  52 ++++++++++++
>  arch/m68k/include/asm/archhash.h       |  67 +++++++++++++++
>  arch/microblaze/include/asm/archhash.h |  80 ++++++++++++++++++
>  include/linux/hash.h                   | 111 ++++++++++++------------
>  include/linux/stringhash.h             |  76 +++++++++++++++++

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
