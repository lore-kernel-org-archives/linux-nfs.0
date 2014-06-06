Return-Path: linux-nfs-owner@vger.kernel.org
Received: from static-209-166-131-148.expedient.com ([209.166.131.148]:55508
	"EHLO natasha.panasas.com" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751098AbaFFIeK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Jun 2014 04:34:10 -0400
Message-ID: <53917CF3.3010209@panasas.com>
Date: Fri, 6 Jun 2014 11:33:55 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Linus Torvalds <torvalds@linux-foundation.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
CC: Elizabeth Ellenbogen Ziph <elizabeth@linuxbox.com>
Subject: [GIT PULL] exofs: raid6 support for the 3.16 merge window
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus
The following changes since commit:

	[d6d211db] Linux 3.15-rc5 (2014-05-09 13:10:52 -0700)

are available in the git repository at:

  git://git.open-osd.org/linux-open-osd.git for-linus

for you to fetch changes up to:

	[ce5d36aa] ore: Support for raid 6 (2014-05-22 14:48:15 +0300)

proud to present support for raid6 in ORE.
These simple patches will enable raid6 using the Kernel's raid6_pq engine
for support under exofs and pnfs-objects. There is nothing needed to do
at exofs and pnfs-obj. Just fire your mkfs.exofs with --raid=6 (that was
already supported before) and off you go as usual. The ORE will pick up
the new map and will start writing two devices of redundancy bits.
The patches are so simple because most of the ORE was already for the
general raid case, only a few bug fixes were needed and the actual wiring
into the raid6_pq engine.

Thanks
Boaz

----------------------------------------------------------------
Boaz Harrosh (3):
      ore: (trivial) reformat some code
      ore: Remove redundant dev_order(), more cleanups
      ore: Support for raid 6

 fs/exofs/Kconfig.ore |   2 ++
 fs/exofs/ore.c       | 100 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++------------------------------------
 fs/exofs/ore_raid.c  |  56 ++++++++++++++++++++++++++++++--------------------------
 fs/exofs/ore_raid.h  |  21 ++-------------------
 4 files changed, 98 insertions(+), 81 deletions(-)
