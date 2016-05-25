Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from science.sciencehorizons.net ([71.41.210.147]:24480 "HELO
	ns.sciencehorizons.net" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with SMTP id S1752724AbcEYILa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 May 2016 04:11:30 -0400
Date: 25 May 2016 04:11:28 -0400
Message-ID: <20160525081128.6920.qmail@ns.sciencehorizons.net>
From: "George Spelvin" <linux@sciencehorizons.net>
To: geert@linux-m68k.org, linux@sciencehorizons.net
Subject: Re: [PATCH 00/10] String hash improvements
Cc: alistair.francis@xilinx.com, bfields@fieldses.org, gerg@linux-m68k.org,
        jlayton@poochiereds.net, linux-kernel@vger.kernel.org,
        linux-m68k@vger.kernel.org, linux-nfs@vger.kernel.org,
        michal.simek@xilinx.com, tglx@linutronix.de,
        torvalds@linux-foundation.org, uclinux-h8-devel@lists.sourceforge.jp,
        ysato@users.sourceforge.jp
In-Reply-To: <CAMuHMdUUCYfGfX1CDVxxihGSC+dz2D1JJVXUWC5H0_W-MmHe7Q@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Geert Uytterhoeven wrote:
> Usually this is handled through include/asm-generic/.
> Put the generic default implementation in include/asm-generic/hash.h.
>
> Architectures that need to override provide their own version, e.g.
> arch/m68k/include/asm/hash.h. They may #include <asm-generic/hash.h>
> if they still want to reuse parts of the generic implementation.
>
> Other architectures add "generic-y += hash.h" to their
> arch/<ARCH>/include/asm/Kbuild.

I thought about that, but then I'd have to edit *every* architecture,
and might need acks from all the maintainers.

I was looking for something that was a total no-op on most architectures.

But if this is preferred, it's not technically difficult at all.


If asm-generic were in the <asm/*.h> search path, it would magically
Just Work, but leftover files from a broken checkout would be a big
potential problem.
