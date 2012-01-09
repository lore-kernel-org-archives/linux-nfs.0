Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:59994 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753396Ab2AILuk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Jan 2012 06:50:40 -0500
Message-ID: <4F0AD47D.2020405@panasas.com>
Date: Mon, 9 Jan 2012 13:50:21 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Linus Torvalds <torvalds@linux-foundation.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Subject: [GIT PULL] exofs/ore: BUG fixes for the 3.3 merge window
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Linus hi.

the following changes since Linux 3.2-rc7

are available in the git repository at:
  git://git.open-osd.org/linux-open-osd.git for-linus

All of these are actually BUGS to the 3.2 Kernel and therefor CCed
to the Stable@kernel.org.
(I'm really sorry that I did not have them ready before)

They fix a rand-config breakage and some BUG_ONs and crashes,
which where unearthed during some large scale testing. With
these I'm back to a usable system, including RAID5 introduced
in 3.2.

Boaz Harrosh (4):
      ore: FIX breakage when MISC_FILESYSTEMS is not set
      ore: Fix crash in case of an IO error.
      ore: fix BUG_ON, too few sgs when reading
      ore: Must support none-PAGE-aligned IO

 fs/Kconfig           |    2 +
 fs/exofs/Kconfig     |   11 -------
 fs/exofs/Kconfig.ore |   12 ++++++++
 fs/exofs/ore.c       |    8 ++--
 fs/exofs/ore_raid.c  |   78 +++++++++++++++++++++++++++++++++++++++++--------
 5 files changed, 83 insertions(+), 28 deletions(-)
 create mode 100644 fs/exofs/Kconfig.ore

Thanks, have a good merge window
Boaz
