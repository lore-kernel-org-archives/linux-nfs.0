From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 12564] New: poor performance while
 preprocessing source code
Date: Wed, 28 Jan 2009 15:04:38 -0800
Message-ID: <20090128150438.fe0137f1.akpm@linux-foundation.org>
References: <bug-12564-10286@http.bugzilla.kernel.org/>
	<20090128132942.c957a199.akpm@linux-foundation.org>
	<1233182618.25546.33.camel@bluishred.int.infinisim.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Steven Patrick <steven-m+eqe7hsN2k@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:47667 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751981AbZA1XGB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Jan 2009 18:06:01 -0500
In-Reply-To: <1233182618.25546.33.camel-JOpGwFo0nm2KXcNLy8+eQDu064pCsa3TQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 28 Jan 2009 14:43:37 -0800
Steven Patrick <steven-m+eqe7hsN2k@public.gmane.org> wrote:

> > > Problem Description:
> > >   Here's my situation.  I've recently upgraded the kernels
> > > on ~30 computers at work (from 2.6.21 to 2.6.27).  These 
> > > computers are used to build and test software we develop.  
> > > We speed up the building process using distcc.  However,
> > > after the kernel upgrade, the builds are much much slower.
> > > The preprocessing stage seems to be at least 10 times
> > > slower.
> > >   As evidence of this slowdown I am attaching two images created
> > > using distccmon-gnome.  Both snapshots were taken shortly 
> > > after starting builds in a clean sandbox.  The only difference
> > > is the kernel.  "fast.png" was generated while running
> > > kernel 2.6.25.20.  "slow.png" was generated with 2.6.26.
> > > The light purple sections indicate the preprocessing times
> > > for each file.  
> > >   This slowdown is observed on both 32 and 64 bit computers
> > > and using either gcc or the intel compiler. (The intel compiler
> > > builds do not use distcc, but that are also slower.)  Strangely 
> > > enough, it's still faster to use an NFS mounted sandbox on a
> > > machine with an older kernel than the same sandbox on the local
> > > machine with a newer kernel.  (This suggests to me that it
> > > is neither a disk or network IO problem.)
> > >   I've used git bisect to narrow it down to a single commit:
> > > # bad: [b0b539739fe9b7d75002412a787cfdf4efddbc33] NFS: Ensure that 'noac'
> > > and/or 'actimeo=0' turn off attribute caching
> > 
> > And thanks for bisecting it.
> 
>   I think it might be possible to bisect further, but I
> don't know how get git to do it.  

OK..

> > > This is the first commit after v2.6.26-rc3.  I'm not an
> > > experienced git user, so I don't know how to narrow it down
> > > further.  Distccmon-gnome snapshots from the bisection
> > > process are similar to the ones noted above.
> > >   Naturally, I would like the newer kernels to have similar
> > > performance to the older kernels.
> > >   I will be attaching various items.  Let me know what other 
> > > information might be helpful.
> > > 
> > > Steps to reproduce:
> > > distccmon-gnome &
> > > # using a makefile setup to use distcc:
> > > make -j 5 all
> > > # note preprocessing times in distccmon
> > > 
> > 
> > Something I don't understand from this:
> > 
> > If your normal setup is using distcc then what role does NFS have to
> > play?  I mean, distcc kind-of replaces NFS in this workload.
> 
>   I don't believe that this actually has anything to do
> with NFS.  The only way I could see NFS coming into this is the
> fact that I use amd to automount home directories.
>   The commit mentioned above modifies just over 100 files, very
> few of which appear related to NFS.  I've attached the diifs.
> It appears to be a number of fixes rolled up into one patch.
> This is why I believe it might be possible to continue bisecting
> with git.  But, to do that I suspect I would need to use a
> different repository and/or tag or version names.
>   BTW, the diffs were generated with "git diff v2.6.26-rc3"
> after having done the bisection.  This is why it looks to me
> like this one commit includes multiple updates.  Since all
> bisection iterations were bad, the diffs against the good
> version must be the diffs of the one commit.  Of course, I 
> reserve the right to have made a mistake or not understand 
> things completely.
>   There was one other detail that seemed strange.  In the
> last four bisection iterations, the kernel identified
> itself as -rc2 instead of -rc3.  I assumed an update
> accidentally changed it back.

Heaven knows.

OK, "This is the first commit after v2.6.26-rc3", so NFS is innocent. 
Presumably your git bisect landed on a big merge commit.

I'm afaid I'm not the person who can tell you how to fix this - it
hasn't happened to me in a while, but I don't know what I did to
prevent it happening :(

Here's the diffstat from your diffs.txt.gz:

 arch/m68k/configs/multi_defconfig              | 1269 -------------------------
 b/MAINTAINERS                                  |    4 
 b/Makefile                                     |    2 
 b/arch/arm/common/locomo.c                     |   66 -
 b/arch/arm/kernel/armksyms.c                   |    2 
 b/arch/arm/kernel/arthur.c                     |    2 
 b/arch/arm/mach-omap1/board-palmte.c           |    2 
 b/arch/arm/mach-omap1/board-palmz71.c          |    2 
 b/arch/arm/mach-omap2/board-2430sdp.c          |    1 
 b/arch/arm/mach-omap2/board-apollon.c          |    1 
 b/arch/arm/mach-omap2/board-generic.c          |    1 
 b/arch/arm/mach-omap2/board-h4.c               |    1 
 b/arch/arm/mach-omap2/clock.c                  |    4 
 b/arch/arm/mach-omap2/clock34xx.h              |   21 
 b/arch/arm/mach-omap2/cm-regbits-34xx.h        |    1 
 b/arch/arm/mach-omap2/mailbox.c                |   25 
 b/arch/arm/mach-omap2/prm.h                    |    2 
 b/arch/arm/mach-orion5x/dns323-setup.c         |    2 
 b/arch/arm/mach-orion5x/kurobox_pro-setup.c    |    2 
 b/arch/arm/mach-pxa/colibri.c                  |    3 
 b/arch/arm/mach-pxa/spitz.c                    |    1 
 b/arch/arm/mm/proc-arm925.S                    |    2 
 b/arch/arm/mm/proc-arm926.S                    |    2 
 b/arch/arm/mm/proc-arm940.S                    |    2 
 b/arch/arm/mm/proc-arm946.S                    |    2 
 b/arch/arm/plat-omap/clock.c                   |   10 
 b/arch/arm/plat-omap/dma.c                     |    2 
 b/arch/arm/plat-omap/mailbox.c                 |    1 
 b/arch/blackfin/mach-bf527/boards/ezkit.c      |    2 
 b/arch/m68k/Kconfig                            |    9 
 b/arch/m68k/configs/amiga_defconfig            |  159 +--
 b/arch/m68k/configs/apollo_defconfig           |  140 --
 b/arch/m68k/configs/atari_defconfig            |  143 +-
 b/arch/m68k/configs/bvme6000_defconfig         |  138 --
 b/arch/m68k/configs/hp300_defconfig            |  142 +-
 b/arch/m68k/configs/mac_defconfig              |  144 +-
 b/arch/m68k/configs/mvme147_defconfig          |  138 --
 b/arch/m68k/configs/mvme16x_defconfig          |  138 --
 b/arch/m68k/configs/q40_defconfig              |  159 +--
 b/arch/m68k/configs/sun3_defconfig             |  140 --
 b/arch/m68k/configs/sun3x_defconfig            |  140 --
 b/arch/m68k/kernel/head.S                      |    2 
 b/arch/m68k/kernel/setup.c                     |   15 
 b/arch/powerpc/platforms/pasemi/misc.c         |    7 
 b/arch/sparc64/defconfig                       |   40 
 b/arch/sparc64/mm/init.c                       |    2 
 b/arch/x86/kernel/process.c                    |   36 
 b/arch/x86/mm/pat.c                            |    2 
 b/drivers/block/amiflop.c                      |    6 
 b/drivers/block/z2ram.c                        |    2 
 b/drivers/char/snsc_event.c                    |    2 
 b/drivers/char/vme_scc.c                       |    4 
 b/drivers/i2c/busses/i2c-amd756.c              |    2 
 b/drivers/i2c/busses/i2c-nforce2.c             |   28 
 b/drivers/i2c/chips/max6875.c                  |    3 
 b/drivers/i2c/i2c-core.c                       |   22 
 b/drivers/ide/legacy/macide.c                  |    3 
 b/drivers/input/keyboard/hilkbd.c              |    4 
 b/drivers/input/misc/hp_sdc_rtc.c              |    5 
 b/drivers/input/serio/hp_sdc_mlc.c             |    5 
 b/drivers/input/serio/q40kbd.c                 |    2 
 b/drivers/media/video/cs5345.c                 |    7 
 b/drivers/media/video/cs53l32a.c               |   10 
 b/drivers/media/video/cx18/cx18-i2c.c          |    9 
 b/drivers/media/video/cx25840/cx25840-core.c   |    7 
 b/drivers/media/video/et61x251/et61x251_core.c |    2 
 b/drivers/media/video/ivtv/ivtv-i2c.c          |   13 
 b/drivers/media/video/m52790.c                 |    9 
 b/drivers/media/video/msp3400-driver.c         |   17 
 b/drivers/media/video/saa7115.c                |   40 
 b/drivers/media/video/saa7127.c                |    9 
 b/drivers/media/video/saa717x.c                |    9 
 b/drivers/media/video/sn9c102/sn9c102_core.c   |    2 
 b/drivers/media/video/tuner-core.c             |   17 
 b/drivers/media/video/upd64031a.c              |    6 
 b/drivers/media/video/upd64083.c               |    6 
 b/drivers/media/video/vp27smpx.c               |    9 
 b/drivers/media/video/wm8739.c                 |    7 
 b/drivers/media/video/wm8775.c                 |    7 
 b/drivers/media/video/zc0301/zc0301_core.c     |    2 
 b/drivers/media/video/zoran_device.c           |    2 
 b/drivers/media/video/zoran_driver.c           |    2 
 b/drivers/net/82596.c                          |    7 
 b/drivers/net/apne.c                           |    3 
 b/drivers/net/mac89x0.c                        |    3 
 b/drivers/net/macmace.c                        |    3 
 b/drivers/net/sun3lance.c                      |    3 
 b/drivers/net/wireless/atmel.c                 |    2 
 b/drivers/video/Kconfig                        |    4 
 b/drivers/video/amifb.c                        |    4 
 b/drivers/video/dnfb.c                         |    3 
 b/drivers/video/hpfb.c                         |    2 
 b/drivers/video/pxafb.c                        |    5 
 b/fs/befs/endian.h                             |    2 
 b/fs/nfs/inode.c                               |    7 
 b/include/asm-arm/arch-omap/common.h           |    4 
 b/include/asm-arm/arch-omap/control.h          |    2 
 b/include/asm-arm/arch-omap/mmc.h              |   24 
 b/include/asm-arm/arch-sa1100/irqs.h           |    2 
 b/include/asm-arm/hardware/locomo.h            |   19 
 b/include/asm-m68k/bug.h                       |    4 
 b/include/asm-m68k/io.h                        |   44 
 b/include/asm-m68k/setup.h                     |    2 
 b/include/asm-m68k/uaccess.h                   |    6 
 b/include/linux/i2c.h                          |    7 
 b/include/linux/i2c/pcf857x.h                  |    3 
 106 files changed, 833 insertions(+), 2743 deletions(-)

Now, distcc has a long track record of tripping up bugs and regressions
in the networking code - it's very clever that way.  But it doesn't
look like there were any relevant networking changes in that window.

So I think the next step is to ask you to continue with (or redo) that
bisection search.

Is there someone who is more git-competent than I who could help with
this please?


