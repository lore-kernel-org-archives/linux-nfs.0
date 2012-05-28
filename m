Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:50131 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750866Ab2E1Nvl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 May 2012 09:51:41 -0400
Message-ID: <4FC382DD.7090102@panasas.com>
Date: Mon, 28 May 2012 16:51:25 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Linus Torvalds <torvalds@linux-foundation.org>,
        open-osd <osd-dev@open-osd.org>
CC: NFS list <linux-nfs@vger.kernel.org>
Subject: [GIT PULL] exofs changes for 3.5-rc1 merge Window
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following changes since commit [36be5051] Linux 3.4-rc7 (2012-05-12 18:37:47 -0700)

are available in the git repository at:

  git://git.open-osd.org/linux-open-osd.git for-linus


These are just a couple of patches. The first is a BUG fix destined for Stable
which missed the 3.4-rc7 Kernel. 
The second is just a fixture addition so exofs is able to be better exported as
a cluster file system via pNFS.

Thanks
Boaz

----------------------------------------------------------------
Boaz Harrosh (1):
      exofs: Fix CRASH on very early IO errors.

Sachin Bhamare (1):
      exofs:  Add SYSFS info for autologin/pNFS export

 fs/exofs/Kbuild  |   2 +-
 fs/exofs/exofs.h |  14 +++++++++++++
 fs/exofs/super.c |  16 +++++++++++++-
 fs/exofs/sys.c   | 200 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 230 insertions(+), 2 deletions(-)
 create mode 100644 fs/exofs/sys.c
