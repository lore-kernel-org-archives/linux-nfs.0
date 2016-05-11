Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from m50-135.163.com ([123.125.50.135]:42236 "EHLO m50-135.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751648AbcEKI3Q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 May 2016 04:29:16 -0400
From: zengzhaoxiu@163.com
To: akpm@linux-foundation.org, linux@horizon.com, bp@suse.de,
        ulrik.debie-os@e2big.org, sam@ravnborg.org, davem@davemloft.net,
        ddaney.cavm@gmail.com, joe@perches.com, computersforpeace@gmail.com
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
        linux-alpha@vger.kernel.org, adi-buildroot-devel@lists.sourceforge.net,
        linux-ia64@vger.kernel.org, linux-mips@linux-mips.org,
        linux-am33-list@redhat.com, linuxppc-dev@lists.ozlabs.org,
        sparclinux@vger.kernel.org, qat-linux@intel.com,
        linux-crypto@vger.kernel.org, linux-edac@vger.kernel.org,
        linux-media@vger.kernel.org, linux-mtd@lists.infradead.org,
        netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-mediatek@lists.infradead.org,
        Zhaoxiu Zeng <zhaoxiu.zeng@gmail.com>
Subject: [patch V4 00/31] bitops: add parity functions
Date: Wed, 11 May 2016 16:25:58 +0800
Message-Id: <1462955158-28394-1-git-send-email-zengzhaoxiu@163.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Zhaoxiu Zeng <zhaoxiu.zeng@gmail.com>

When I do "grep parity -r linux", I found many parity calculations
distributed in many drivers.

This patch series does:
  1. provide generic and architecture-specific parity calculations
  2. remove drivers' local parity calculations, use bitops' parity
     functions instead
  3. replace "hweightN(x) & 1" with "parityN(x)" to improve readability,
     and improve performance on some CPUs that without popcount support

I did not use GCC's __builtin_parity* functions, based on the following reasons:
  1. I don't know where to identify which version of GCC from the beginning
     supported __builtin_parity for the architecture.
  2. For the architecture that doesn't has popcount instruction, GCC instead use
     "call __paritysi2" (__paritydi2 for 64-bits). So if use __builtin_parity, we must
     provide __paritysi2 and __paritydi2 functions for these architectures.
     Additionally, parity4,8,16 might be "__builtin_parity(x & mask)", but the "& mask"
     operation is totally unnecessary.
  3. For the architecture that has popcount instruction, we do the same things as GCC.
  4. For powerpc, sparc, and x86, we do runtime patching to use popcount instruction
     if the CPU support.

I have compiled successfully with x86_64_defconfig, i386_defconfig, pseries_defconfig
and sparc64_defconfig.

Changes to V3:
- Remove "odd" and "even" from documents. The function parityN returns whether an odd
  or even number of bits are on in a N-bit word, does not involve the definition of
  odd/even parity. Is it an odd or even parity checking, depends on the caller's context.
- Replace "hweightN(x) % 2" with "parityN(x)" in crypto/sahara.c and edac/amd64_edac.c
- Use PARITY_MAGIC instead of 0x6996 in powerpc's parity_64.S
- Use PARITY_MAGIC instead of 0x6996 in sparc's parity.S
- Pick up ACKs

Changes to v2:
- X86, remove custom calling convention, use inline asm
- Add constant PARITY_MAGIC (proposals by Sam Ravnborg)
- Add include/asm-generic/bitops/popc-parity.h (proposals by Chris Metcalf)
- Tile uses popc-parity.h directly
- Mips uses popc-parity.h if has usable __builtin_popcount
- Add few comments in powerpc's and sparc's parity.S

Changes to v1:
- Add runtime patching for powerpc, sparc, and x86
- Avr32 use grenric parity too
- Fix error in ssfdc's patch, and add commit message
- Don't change the original code composition of adxrs450.c
- Directly assignement to phy_cap.parity in drivers/scsi/isci/phy.c

Regards,

=== diffstat ===

Zhaoxiu Zeng (31):
  bitops: add parity functions
  bitops: Include generic parity.h in some architectures' bitops.h
  bitops: Add alpha-specific parity functions
  bitops: Add blackfin-specific parity functions
  bitops: Add ia-specific parity functions
  bitops: Tile and MIPS (if has usable __builtin_popcount) use popcount
    parity functions
  bitops: Add powerpc-specific parity functions
  bitops: Add sparc-specific parity functions
  bitops: Add x86-specific parity functions
  sunrpc: use parity8
  mips: use parity functions in cerr-sb1.c
  lib: bch: use parity32
  media: use parity8 in vivid-vbi-gen.c
  media: use parity functions in saa7115
  input: use parity32 in grip_mp
  input: use parity64 in sidewinder
  input: use parity16 in ams_delta_serio
  scsi: use parity32 in isci's phy
  mtd: use parity16 in ssfdc
  mtd: use parity functions in inftlcore
  crypto: use parity functions in qat_hal
  mtd: use parity16 in sm_ftl
  ethernet: use parity8 in sun/niu.c
  input: use parity8 in pcips2
  input: use parity8 in sa1111ps2
  iio: use parity32 in adxrs450
  serial: use parity32 in max3100
  input: use parity8 in elantech
  ethernet: use parity8 in broadcom/tg3.c
  crypto: use parity_long is sahara.c
  edac: use parity8 in amd64_edac.c

 arch/alpha/include/asm/bitops.h              |  27 +++++
 arch/arc/include/asm/bitops.h                |   1 +
 arch/arm/include/asm/bitops.h                |   1 +
 arch/arm64/include/asm/bitops.h              |   1 +
 arch/avr32/include/asm/bitops.h              |   1 +
 arch/blackfin/include/asm/bitops.h           |  31 ++++++
 arch/c6x/include/asm/bitops.h                |   1 +
 arch/cris/include/asm/bitops.h               |   1 +
 arch/frv/include/asm/bitops.h                |   1 +
 arch/h8300/include/asm/bitops.h              |   1 +
 arch/hexagon/include/asm/bitops.h            |   1 +
 arch/ia64/include/asm/bitops.h               |  31 ++++++
 arch/m32r/include/asm/bitops.h               |   1 +
 arch/m68k/include/asm/bitops.h               |   1 +
 arch/metag/include/asm/bitops.h              |   1 +
 arch/mips/include/asm/bitops.h               |   7 ++
 arch/mips/mm/cerr-sb1.c                      |  67 ++++---------
 arch/mn10300/include/asm/bitops.h            |   1 +
 arch/openrisc/include/asm/bitops.h           |   1 +
 arch/parisc/include/asm/bitops.h             |   1 +
 arch/powerpc/include/asm/bitops.h            |  11 +++
 arch/powerpc/lib/Makefile                    |   2 +-
 arch/powerpc/lib/parity_64.S                 | 143 +++++++++++++++++++++++++++
 arch/powerpc/lib/ppc_ksyms.c                 |   5 +
 arch/s390/include/asm/bitops.h               |   1 +
 arch/sh/include/asm/bitops.h                 |   1 +
 arch/sparc/include/asm/bitops_32.h           |   1 +
 arch/sparc/include/asm/bitops_64.h           |  18 ++++
 arch/sparc/kernel/sparc_ksyms_64.c           |   6 ++
 arch/sparc/lib/Makefile                      |   2 +-
 arch/sparc/lib/parity.S                      | 129 ++++++++++++++++++++++++
 arch/tile/include/asm/bitops.h               |   2 +
 arch/x86/include/asm/arch_hweight.h          |   5 +
 arch/x86/include/asm/arch_parity.h           | 117 ++++++++++++++++++++++
 arch/x86/include/asm/bitops.h                |   4 +-
 arch/xtensa/include/asm/bitops.h             |   1 +
 drivers/crypto/qat/qat_common/qat_hal.c      |  32 ++----
 drivers/crypto/sahara.c                      |   2 +-
 drivers/edac/amd64_edac.c                    |   2 +-
 drivers/iio/gyro/adxrs450.c                  |   4 +-
 drivers/input/joystick/grip_mp.c             |  16 +--
 drivers/input/joystick/sidewinder.c          |  24 +----
 drivers/input/mouse/elantech.c               |  10 +-
 drivers/input/mouse/elantech.h               |   1 -
 drivers/input/serio/ams_delta_serio.c        |   8 +-
 drivers/input/serio/pcips2.c                 |   2 +-
 drivers/input/serio/sa1111ps2.c              |   2 +-
 drivers/media/i2c/saa7115.c                  |  17 +---
 drivers/media/platform/vivid/vivid-vbi-gen.c |   9 +-
 drivers/mtd/inftlcore.c                      |  17 +---
 drivers/mtd/sm_ftl.c                         |   5 +-
 drivers/mtd/ssfdc.c                          |  31 ++----
 drivers/net/ethernet/broadcom/tg3.c          |   6 +-
 drivers/net/ethernet/sun/niu.c               |  10 +-
 drivers/scsi/isci/phy.c                      |  15 +--
 drivers/tty/serial/max3100.c                 |   2 +-
 include/asm-generic/bitops.h                 |   1 +
 include/asm-generic/bitops/arch_parity.h     |  39 ++++++++
 include/asm-generic/bitops/const_parity.h    |  36 +++++++
 include/asm-generic/bitops/parity.h          |   7 ++
 include/asm-generic/bitops/popc-parity.h     |  32 ++++++
 include/linux/bitops.h                       |  10 ++
 lib/bch.c                                    |  14 +--
 net/sunrpc/auth_gss/gss_krb5_keys.c          |   6 +-
 64 files changed, 749 insertions(+), 237 deletions(-)
 create mode 100644 arch/powerpc/lib/parity_64.S
 create mode 100644 arch/sparc/lib/parity.S
 create mode 100644 arch/x86/include/asm/arch_parity.h
 create mode 100644 include/asm-generic/bitops/arch_parity.h
 create mode 100644 include/asm-generic/bitops/const_parity.h
 create mode 100644 include/asm-generic/bitops/parity.h
 create mode 100644 include/asm-generic/bitops/popc-parity.h

-- 
2.7.4


