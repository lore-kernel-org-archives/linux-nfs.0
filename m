Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:22133 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751522AbdLAVwO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 1 Dec 2017 16:52:14 -0500
To: Linus Torvalds <torvalds@linux-foundation.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Subject: [GIT PULL] Please pull NFS client fixes for 4.15-rc2
Message-ID: <eab7922e-40a7-b417-fe8a-1a8ce3647fab@Netapp.com>
Date: Fri, 1 Dec 2017 16:52:08 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

The following changes since commit fcfa447062b2061e11f68b846d61cbfe60d0d604:

  NFS: Revert "NFS: Move the flock open mode check into nfs_flock()" (2017-11-17 16:43:52 -0500)

are available in the Git repository at:

  git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-4.15-2

for you to fetch changes up to eb5b46faa693470681ec7c28cc2436edd1571198:

  SUNRPC: Handle ENETDOWN errors (2017-11-30 11:52:52 -0500)

----------------------------------------------------------------
These patches fix a problem with compiling using an old version of gcc, and also fix
up error handling in the SUNRPC layer.

Thanks,
Anna

----------------------------------------------------------------
Trond Myklebust (3):
      NFSv4: Ensure gcc 4.4.4 can compile initialiser for "invalid_stateid"
      SUNRPC: Allow connect to return EHOSTUNREACH
      SUNRPC: Handle ENETDOWN errors

 fs/nfs/nfs4state.c    | 4 ++--
 net/sunrpc/clnt.c     | 5 +++++
 net/sunrpc/xprtsock.c | 2 ++
 3 files changed, 9 insertions(+), 2 deletions(-)
