Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:60743 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751126Ab1JYQXH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Oct 2011 12:23:07 -0400
Message-ID: <4EA6E256.1060803@panasas.com>
Date: Tue, 25 Oct 2011 09:22:46 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Linus Torvalds <torvalds@linux-foundation.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        open-osd <osd-dev@open-osd.org>, "Welch, Brent" <welch@panasas.com>
CC: linux-kernel <linux-kernel@vger.kernel.org>
Subject: [GIT PULL] ore/exofs: Changes for the 3.2 Merge Window (Part 1)
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Linus Hi

Please pull the following changes since v3.1-rc6 [b6fd41e2]

Which are available in the git repository at:
  git://git.open-osd.org/linux-open-osd.git for-linus

The biggest highlight of this Merge is support for RAID5 over objects
with full support for the pnfs-objects-ietf-standard layout. (This is
a special RAID5 over objects which is equivalent to RAID5 over files
much more then RAID5 over block devices).

Part 2: Of this merge is dependent on this inclusion and the bits
in Trond's NFS tree. For the fs/nfs/objlayout and will be pushed
through Trond, once both hit mainline.

Thanks!
Boaz Harrosh (19):
      osd: Kconfig remove wrong FIXME
      exofs: Rename struct ore_components comps => oc
      exofs: Remove unused data_map member from exofs_sb_info
      ore: Make ore_striping_info and ore_calc_stripe_info public
      ore/exofs: Change the type of the devices array (API change)
      ore: Only IO one group at a time (API change)
      ore: cleanup: Embed an ore_striping_info inside ore_io_state
      ore: Remove check for ios->kern_buff in _prepare_for_striping to later
      exofs: Support for short read/writes
      ore: Support for short read/writes
      ore: Support for partial component table
      ore/exofs: Define new ore_verify_layout
      ore/exofs: Change ore_check_io API
      ore: Make ore_calc_stripe_info EXPORT_SYMBOL
      fs/Makefile: Always inspect exofs/
      ore: RAID5 read
      ore: RAID5 Write
      exofs: Support for RAID5 read-4-write interface.
      ore: Enable RAID5 mounts

H Hartley Sweeten (2):
      exofs/ore.c: local functions should be static
      exofs/super.c: local functions should be static

 drivers/scsi/osd/Kconfig |    4 -
 fs/Makefile              |    2 +-
 fs/exofs/Kbuild          |    3 +-
 fs/exofs/Kconfig         |    9 +-
 fs/exofs/exofs.h         |   26 +-
 fs/exofs/inode.c         |  233 +++++++++++++----
 fs/exofs/ore.c           |  656 +++++++++++++++++++++++++++++++++-------------
 fs/exofs/ore_raid.c      |  660 ++++++++++++++++++++++++++++++++++++++++++++++
 fs/exofs/ore_raid.h      |   79 ++++++
 fs/exofs/super.c         |  205 ++++++---------
 include/scsi/osd_ore.h   |   80 ++++++-
 11 files changed, 1583 insertions(+), 374 deletions(-)
 create mode 100644 fs/exofs/ore_raid.c
 create mode 100644 fs/exofs/ore_raid.h
