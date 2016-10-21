Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:5407 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754619AbcJUUac (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 21 Oct 2016 16:30:32 -0400
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Subject: [GIT PULL] Please pull NFS client bugfixes
To: Linus Torvalds <torvalds@linux-foundation.org>
CC: Trond Myklebust <trond.myklebust@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Message-ID: <a2ad29b2-0e76-018d-4155-58e52b80d8a2@Netapp.com>
Date: Fri, 21 Oct 2016 16:30:03 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

The following changes since commit 3f807e5ae5597bd65a6fff684083e8eaa21f3fa7:

  NFSv4.2: Fix a reference leak in nfs42_proc_layoutstats_generic (2016-10-04 16:30:54 -0400)

are available in the git repository at:

  git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-4.9-2

for you to fetch changes up to 83aa3e0f791d458a28f91d7a50f92926f971ef7c:

  nfs4: fix missing-braces warning (2016-10-19 14:39:15 -0400)

----------------------------------------------------------------
Just two bugfixes this time:

Stable bugfix:
- Fix last_write_offset incorrectly set to page boundary

Other bugfix:
- Fix missing-braces warning

Thanks,
Anna
----------------------------------------------------------------
Arnd Bergmann (1):
      nfs4: fix missing-braces warning

Benjamin Coddington (1):
      pnfs/blocklayout: fix last_write_offset incorrectly set to page boundary

 fs/nfs/blocklayout/blocklayout.c | 3 ++-
 fs/nfs/nfs4proc.c                | 2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)
