Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:47135 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752557AbdHBU1c (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 2 Aug 2017 16:27:32 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Subject: [GIT PULL] Please pull two more NFS client fixes for 4.13
Message-ID: <1f82691c-edb6-0bd8-0d6e-7ffd53f8a116@Netapp.com>
Date: Wed, 2 Aug 2017 16:27:06 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

The following changes since commit b7dbcc0e433f0f61acb89ed9861ec996be4f2b38:

  NFSv4.1: Fix a race where CB_NOTIFY_LOCK fails to wake a waiter (2017-07-28 15:35:30 -0400)

are available in the git repository at:

  git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-4.13-4

for you to fetch changes up to d9cb73300ac0001832c048a489c592263fc28193:

  NFSv4: Fix double frees in nfs4_test_session_trunk() (2017-08-02 09:45:55 -0400)

----------------------------------------------------------------
Two fixes from Trond this time, now that he's back from his vacation.  The first is a stable fix
for the EXCHANGE_ID issue on the mailing list, and the other fixes a double-free situation that
he found at the same time.

Thanks,
Anna
----------------------------------------------------------------
Trond Myklebust (2):
      NFSv4: Fix EXCHANGE_ID corrupt verifier issue
      NFSv4: Fix double frees in nfs4_test_session_trunk()

 fs/nfs/nfs4client.c     |  3 ---
 fs/nfs/nfs4proc.c       | 27 +++++++--------------------
 fs/nfs/nfs4xdr.c        |  2 +-
 include/linux/nfs_xdr.h |  2 +-
 4 files changed, 9 insertions(+), 25 deletions(-)
