Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:35290 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933276AbdCaRkk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 31 Mar 2017 13:40:40 -0400
From: Anna Schumaker <schumaker.anna@gmail.com>
Subject: [GIT PULL] Please pull a few more NFS client bugfixes for 4.11
To: torvalds@linux-foundation.org
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-kernel@vger.kernel.org
Message-ID: <7dbb671e-0168-fa36-bca2-f747f2245040@gmail.com>
Date: Fri, 31 Mar 2017 13:40:36 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

The following changes since commit da066f3f039eba3e72e97b2ccad0dd8b45ba84bd:

  pNFS/flexfiles: never nfs4_mark_deviceid_unavailable (2017-03-17 16:07:17 -0400)

are available in the git repository at:

  git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-4.11-3

for you to fetch changes up to f17f8a14e82cdf34cd6473e3644f3c672b3884f6:

  nfs: flexfiles: fix kernel OOPS if MDS returns unsupported DS type (2017-03-31 13:30:49 -0400)

----------------------------------------------------------------
Here are a few more bugfixes that came in over the last couple of weeks.  Most of these fix
various hangs and loops that people found, but we also had a few error handling fixes.

Stable Bugfixes:
- Fix infinite loop on BAD_STATEID error

Other Bugfixes:
- Fix old dentry rehash after move
- Fix pnfs GETDEVINFO hangs
- Fix pnfs fallback to MDS on commit errors
- Fix flexfiles kernel oops


Have a good weekend!
Anna

----------------------------------------------------------------
Andy Adamson (3):
      NFS cleanup struct nfs4_filelayout_segment
      NFS store nfs4_deviceid in struct nfs4_filelayout_segment
      NFS filelayout:call GETDEVICEINFO after pnfs_layout_process completes

Benjamin Coddington (1):
      NFS: Fix old dentry rehash after move

Olga Kornievskaia (2):
      PNFS fix fallback to MDS if got error on commit to DS
      NFSv4.1 fix infinite loop on IO BAD_STATEID error

Tigran Mkrtchyan (1):
      nfs: flexfiles: fix kernel OOPS if MDS returns unsupported DS type

 fs/nfs/dir.c                              |   9 ++-------
 fs/nfs/filelayout/filelayout.c            | 151 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-------------------------------------------------------
 fs/nfs/filelayout/filelayout.h            |  19 ++++++++++---------
 fs/nfs/flexfilelayout/flexfilelayoutdev.c |   4 ++++
 fs/nfs/nfs4proc.c                         |   9 +++------
 5 files changed, 115 insertions(+), 77 deletions(-)
