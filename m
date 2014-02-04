Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f171.google.com ([209.85.213.171]:42860 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751214AbaBDQwX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Feb 2014 11:52:23 -0500
Received: by mail-ig0-f171.google.com with SMTP id uy17so8563460igb.4
        for <linux-nfs@vger.kernel.org>; Tue, 04 Feb 2014 08:52:23 -0800 (PST)
Message-ID: <1391532741.8900.1.camel@leira.trondhjem.org>
Subject: [GIT PULL] Please pull NFS client fixes
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Torvalds Linus <torvalds@linux-foundation.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>
Date: Tue, 04 Feb 2014 11:52:21 -0500
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

The following changes since commit 8a1f006ad302ea178aefb1f8c67e679c696289e9:

  Merge tag 'nfs-for-3.14-2' of git://git.linux-nfs.org/projects/trondmy/linux-nfs (2014-01-31 15:39:07 -0800)

are available in the git repository at:


  git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-3.14-3

for you to fetch changes up to 88a78a912ee059467ae6db7429a6efe4654620a5:

  Merge branch 'acl_fixes' into linux-next (2014-02-03 17:13:45 -0500)

----------------------------------------------------------------

NFS client bugfixes for Linux 3.14

Highlights:

- Fix NFSv3 acl regressions
- Fix NFSv4 memory corruption due to slot table abuse in nfs4_proc_open_confirm
- nfs4_destroy_session must call rpc_destroy_waitqueue

----------------------------------------------------------------
Noah Massey (1):
      nfs: fix setting of ACLs on file creation.

Trond Myklebust (6):
      NFSv4: Fix memory corruption in nfs4_proc_open_confirm
      NFSv4.1: nfs4_destroy_session must call rpc_destroy_waitqueue
      NFSv3: Remove unused function nfs3_proc_set_default_acl
      NFSv3: Fix return value of nfs3_proc_setacls
      fs: get_acl() must be allowed to return EOPNOTSUPP
      Merge branch 'acl_fixes' into linux-next

 fs/nfs/nfs3acl.c        | 34 ++++++++++++----------------------
 fs/nfs/nfs4client.c     |  2 +-
 fs/nfs/nfs4proc.c       |  8 ++++----
 fs/nfs/nfs4session.c    | 25 ++++++++++++++++++++-----
 fs/nfs/nfs4session.h    |  2 +-
 fs/posix_acl.c          | 18 ++++++++++++------
 include/linux/nfs_xdr.h |  2 ++
 7 files changed, 52 insertions(+), 39 deletions(-)

-- 
Trond Myklebust
Linux NFS client maintainer

