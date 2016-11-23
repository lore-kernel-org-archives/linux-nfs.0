Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:30286 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752437AbcKWWGt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 23 Nov 2016 17:06:49 -0500
To: <torvalds@linux-foundation.org>
CC: Trond Myklebust <trond.myklebust@primarydata.com>,
        <linux-nfs@vger.kernel.org>, <linux-kernel@vger.kernel.org>
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Subject: [GIT PULL] Please pull more NFS client bugfixes for 4.9
Message-ID: <c1e5595a-2e28-aedf-3a32-48200252fbf3@Netapp.com>
Date: Wed, 23 Nov 2016 17:06:41 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

The following changes since commit 62bdf94a2049822ef8c6d4b0e83cd9c3a1663ab4:

  xprtrdma: Fix DMAR failure in frwr_op_map() after reconnect (2016-11-10 11:04:54 -0500)

are available in the git repository at:

  git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-4.9-4

for you to fetch changes up to d55b352b01bc78fbc3d1bb650140668b87e58bf9:

  NFSv4.x: hide array-bounds warning (2016-11-22 16:11:44 -0500)
----------------------------------------------------------------

Most of these fix regressions or races, but there is one patch for Stable that Arnd sent me

Stable Bugfixes:
- Hide array-bounds warning

Bugfixes:
- Keep a reference on lock states while checking
- Handle NFS4ERR_OLD_STATEID in nfs4_reclaim_open_state
- Don't call close if the open stateid has already been cleared
- Fix CLOSE rases with OPEN
- Fix a regression in DELEGRETURN

Thank you!  Have a good Thanksgiving!
Anna
----------------------------------------------------------------

Arnd Bergmann (1):
      NFSv4.x: hide array-bounds warning

Benjamin Coddington (2):
      NFSv4.1: Handle NFS4ERR_OLD_STATEID in nfs4_reclaim_open_state
      NFSv4.1: Keep a reference on lock states while checking

Trond Myklebust (3):
      NFSv4.1: Fix a regression in DELEGRETURN
      NFSv4: Fix CLOSE races with OPEN
      NFSv4: Don't call close if the open stateid has already been cleared

 fs/nfs/callback.c  |  2 +-
 fs/nfs/nfs4_fs.h   |  7 +++++++
 fs/nfs/nfs4proc.c  | 38 ++++++++++++++++++++++++++------------
 fs/nfs/nfs4state.c |  1 +
 4 files changed, 35 insertions(+), 13 deletions(-)
