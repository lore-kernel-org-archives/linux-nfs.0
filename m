Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from science.sciencehorizons.net ([71.41.210.147]:44247 "HELO
	ns.sciencehorizons.net" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with SMTP id S1754124AbcEYJHr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 May 2016 05:07:47 -0400
Date: 25 May 2016 05:07:45 -0400
Message-ID: <20160525090745.8999.qmail@ns.sciencehorizons.net>
From: "George Spelvin" <linux@sciencehorizons.net>
To: geert@linux-m68k.org, linux@sciencehorizons.net
Subject: Re: [PATCH 00/10] String hash improvements
Cc: alistair.francis@xilinx.com, bfields@fieldses.org, gerg@linux-m68k.org,
        jlayton@poochiereds.net, linux-kernel@vger.kernel.org,
        linux-m68k@vger.kernel.org, linux-nfs@vger.kernel.org,
        michal.simek@xilinx.com, tglx@linutronix.de,
        torvalds@linux-foundation.org, uclinux-h8-devel@lists.sourceforge.jp,
        ysato@users.sourceforge.jp
In-Reply-To: <CAMuHMdUuAi_EdWPJmYNgNpUv_Zh34Oc3G7TgqcsChwzuyz0c-Q@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>> +#if defined(CONFIG_M68000) || defined(CONFIG_M68010)

> As I said before, I don't think you need this check, given HAVE_ARCH_HASH is
> selected by M68000, and M68010 doesn't exist.

I was going belt & suspenders on general principles, but yes, I'm happy
to leave it out.

I noticed that CONFIG_M68010 doesn't exist in Linus' tree, but you
recommended it, so I thought you might know something I don't.

> As you only include <asm/archhash.h> if CONFIG_HAVE_ARCH_HASH
> is defined, you can also just call the arch-specific one <asm/hash.h>.

Yes, that's a possibility, too.  But weren't we still discussing whether
I should use conditional #inclusion based on a symbol, or asm-generic?

If neither of us has a killer argument that convinces the other, style
issues like this are amenable to voting, so I was going to wait a little
bit for others to chime in.


Thank you very much for the comments!
