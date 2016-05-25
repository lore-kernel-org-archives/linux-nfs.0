Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from science.sciencehorizons.net ([71.41.210.147]:51803 "HELO
	ns.sciencehorizons.net" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with SMTP id S1751167AbcEYHU3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 May 2016 03:20:29 -0400
Date: 25 May 2016 03:20:27 -0400
Message-ID: <20160525072027.5107.qmail@ns.sciencehorizons.net>
From: "George Spelvin" <linux@sciencehorizons.net>
To: linux-kernel@vger.kernel.org, torvalds@linux-foundation.org
Subject: [PATCH 00/10] String hash improvements
Cc: alistair.francis@xilinx.com, bfields@fieldses.org, geert@linux-m68k.org,
        gerg@linux-m68k.org, jlayton@poochiereds.net,
        linux-m68k@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux@sciencehorizons.net, michal.simek@xilinx.com, tglx@linutronix.de,
        uclinux-h8-devel@lists.sourceforge.jp, ysato@users.sourceforge.jp
In-Reply-To: <CA+55aFxPSW+84KfQ1N_WmND-wtvgj2zQm8nFPkRcc+gyU=uing@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 17 May 2016 at 09:32, Linus Torvalds <torvalds@linux-foundation.org> wrote:
> On Tue, May 17, 2016 at 6:41 AM, George Spelvin <linux@horizon.com> wrote:
>> I had assumed that since they weren't fully baked when the window opened,
>> they weren't eligible, but I'll try.

> Hey, if they aren't ready, they aren't.

Well, they're close, and I can and did *get* them ready.

> How about just the minimal set of patches that you'er happy with as-is?

The things are a bit interdependent.  I can't fix hash_64() on 32-bit systems until
I get rid of hash_string()'s need for it to return 64 bits, which requires work
on the dcache hashes to make them suitable replacements...

The real fun has come from TPTB deciding to sell the horizon.com domain,
and it turns out that updating rDNS takes the ISP a whole freaking week,
during which time outgoing mail trips everyone's spam filters.

That finally got fixed, just in time for me to put my dominant hand through
a piece of glass.  It's been a week. :-(


Anyway, the patches...

This series does several related things:
1) Gets rid of the string hashes in <linux/sunrpc/svcauth.h>,
   and uses the dcache hash (fs/namei.c) instead.
2) Avoid 64-bit multiplies in hash_64() on 32-bit platforms.
   Two 32-bit multiplies will do well enough.
3) Rids the world of the bad hash multipliers in hash_32.
   This finishes the job started in 689de1d6ca.
   The vast majority of Linux architectures have hardware support
   for 32x32-bit multiply and so derive no benefit from "simplified"
   multipliers.
   The few processors that do not (68000, h8/300 and some models of
   Microblaze) have arch-specific implementations added.  Those patches
   are last in the series so they can go through the relevant arch
   maintainers.
4) Overhauls the dcache hash mixing.
   The patch in 2bf0b16954 was an off-the-cuff suggestion.  Replaced with
   a much more careful design that's simultaneously faster and better.
   (My own invention, as there was noting suitable in the literature I
   could find.  Comments welcome!)

Things I thought about but can wait for now:
5) Modify the hash_name() loop to skip the initial HASH_MIX().
   That would let us salt the hash if we ever wanted to.
6) Modify bytemask_from_count to handle inputs of 1..sizeof(long)
   rather than 0..sizeof(long)-1.  This would simplify all its users
   including full_name_hash.
7) Sort out partial_name_hash().
   The hash function is declared as using a long state, even though
   it's truncated to 32 bits at the end and the extra internal state
   contributes nothing to the result.  And some callers do odd things:
   * fs/hfs/string.c only allocates 32 bits of state
   * fs/hfsplus/unicode.c uses it to hash 16-bit unicode symbols not bytes

I'm not particularly fond of the names of the header files I created,
but if anyone has a better idea please talk fast!

George Spelvin (10):
  Pull out string hash to <linux/stringhash.h>
  fs/namei.c: Add hash_string() function.
  <linux/sunrpc/svcauth.h>: Define hash_str() in terms of hash_string()
  Change hash_64() return value to 32 bits.
  Eliminate bad hash multipliers from hash_32() and hash_64().
  fs/namei.c: Improve dcache hash function
  <linux/hash.h>: Add support for architecture-specific functions
  m68k: Add <asm/archhash.h>
  microblaze: Add <asm/archhash.h>
  h8300: Add <asm/archhash.h>

 arch/Kconfig                           |   8 ++
 arch/h8300/Kconfig                     |   1 +
 arch/h8300/include/asm/archhash.h      |  52 ++++++++++++
 arch/m68k/Kconfig                      |   1 +
 arch/m68k/include/asm/archhash.h       |  67 +++++++++++++++
 arch/microblaze/Kconfig                |   1 +
 arch/microblaze/include/asm/archhash.h |  80 ++++++++++++++++++
 fs/namei.c                             | 149 +++++++++++++++++++++++++--------
 include/linux/dcache.h                 |  27 +-----
 include/linux/hash.h                   | 111 ++++++++++++------------
 include/linux/stringhash.h             |  76 +++++++++++++++++
 include/linux/sunrpc/svcauth.h         |  36 ++------
 12 files changed, 464 insertions(+), 145 deletions(-)
 create mode 100644 arch/h8300/include/asm/archhash.h
 create mode 100644 arch/m68k/include/asm/archhash.h
 create mode 100644 arch/microblaze/include/asm/archhash.h
 create mode 100644 include/linux/stringhash.h

-- 
2.8.1

