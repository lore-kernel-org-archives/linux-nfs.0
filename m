Return-Path: linux-nfs-owner@vger.kernel.org
Received: from static-209-166-131-148.expedient.com ([209.166.131.148]:56111
	"EHLO natasha.panasas.com" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753983AbaA0U0x (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Jan 2014 15:26:53 -0500
Message-ID: <52E6C0F8.3030002@panasas.com>
Date: Mon, 27 Jan 2014 22:26:32 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Linus Torvalds <torvalds@linux-foundation.org>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>
Subject: [git pull] Few fixes to ORE and EXOFS
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Dear Linus

Please pull the following changes since v3.12 commit [5e01dc7b]:

They are available in the git repository at:

  git://git.open-osd.org/linux-open-osd.git for-linus

for you to fetch changes up to 19350e7627a6f3b0f662cbd2eb1128c9961a41fe:

  exofs: Print less in r4w (2014-01-23 18:54:14 +0200)


The main fix here, the first patch, is also destined for Stable@. The rest
is small trivia and cosmetics. The ORE patches effect both exofs and pnfs-objects
very reproducible bugs.

----------------------------------------------------------------
Boaz Harrosh (5):
      ore: Fix wrong math in allocation of per device BIO
      ore: Don't crash on NULL bio in _clear_bio
      exofs: Allow O_DIRECT open
      exofs: Allow corrupted directory entry to be empty file
      exofs: Print less in r4w

 fs/exofs/inode.c       | 31 +++++++++++++++++++------------
 fs/exofs/ore.c         | 45 +++++++++++++++++++++++++++++++--------------
 include/scsi/osd_ore.h |  1 +
 3 files changed, 51 insertions(+), 26 deletions(-)

Thanks
Boaz
