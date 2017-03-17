Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:28554 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751222AbdCQUVe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 17 Mar 2017 16:21:34 -0400
To: <torvalds@linux-foundation.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Subject: [GIT PULL] Please pull NFS client bugfixes for 4.11
Message-ID: <2142a302-6319-a6e4-2c4e-46f37e8ac084@Netapp.com>
Date: Fri, 17 Mar 2017 16:21:11 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

The following changes since commit ed92d8c137b7794c2c2aa14479298b9885967607:

  NFSv4: fix getacl ERANGE for some ACL buffer sizes (2017-02-23 17:23:35 -0500)

are available in the git repository at:

  git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-4.11-2

for you to fetch changes up to da066f3f039eba3e72e97b2ccad0dd8b45ba84bd:

  pNFS/flexfiles: never nfs4_mark_deviceid_unavailable (2017-03-17 16:07:17 -0400)

----------------------------------------------------------------
We have a handful of stable fixes to fix kernel warnings and other bugs that have been
around for a while.  We've also found a few other reference counting bugs and memory leaks since the initial 4.11 pull.

Stable Bugfixes:
- Fix decrementing nrequests in NFS v4.2 COPY to fix kernel warnings
- Prevent a double free in async nfs4_exchange_id()
- Squelch a kbuild sparse complaint for xprtrdma

Other Bugfixes:
- Fix a typo (NFS_ATTR_FATTR_GROUP_NAME) that causes a memory leak
- Fix a reference leak that causes kernel warnings
- Make nfs4_cb_sv_ops static to fix a sparse warning
- Respect a server's max size in CREATE_SESSION
- Handle errors from nfs4_pnfs_ds_connect
- Flexfiles layout shouldn't mark devices as unavailable


Thanks,
Anna

----------------------------------------------------------------
Chuck Lever (1):
      xprtrdma: Squelch kbuild sparse complaint

Jason Yan (1):
      nfs: make nfs4_cb_sv_ops static

Kinglong Mee (3):
      nfs4: fix a typo of NFS_ATTR_FATTR_GROUP_NAME
      NFSv4: fix a reference leak caused WARNING messages
      NFS: fix the fault nrequests decreasing for nfs_inode COPY

Olga Kornievskaia (2):
      NFS prevent double free in async nfs4_exchange_id
      NFSv4.1 respect server's max size in CREATE_SESSION

Weston Andros Adamson (2):
      pNFS: return status from nfs4_pnfs_ds_connect
      pNFS/flexfiles: never nfs4_mark_deviceid_unavailable

 fs/nfs/callback.c                         |  4 ++--
 fs/nfs/client.c                           | 25 ++++++++++++++++++++++++-
 fs/nfs/filelayout/filelayoutdev.c         |  8 +++++++-
 fs/nfs/flexfilelayout/flexfilelayout.h    | 14 +++++++++++++-
 fs/nfs/flexfilelayout/flexfilelayoutdev.c |  5 +++--
 fs/nfs/internal.h                         |  2 ++
 fs/nfs/nfs4client.c                       |  4 ++--
 fs/nfs/nfs4proc.c                         | 11 ++++-------
 fs/nfs/nfs4xdr.c                          |  2 +-
 fs/nfs/pnfs.h                             |  2 +-
 fs/nfs/pnfs_nfs.c                         | 31 +++++++++++++++++++++++++------
 fs/nfs/write.c                            |  6 ++++--
 net/sunrpc/xprtrdma/verbs.c               |  3 ++-
 13 files changed, 90 insertions(+), 27 deletions(-)
