Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33624 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754292AbbA2ViC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Jan 2015 16:38:02 -0500
Received: by mail-pa0-f45.google.com with SMTP id et14so43704997pad.4
        for <linux-nfs@vger.kernel.org>; Thu, 29 Jan 2015 13:38:01 -0800 (PST)
Message-ID: <1422567477.6784.1.camel@primarydata.com>
Subject: [GIT PULL] Please pull NFS client bugfixes
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Date: Thu, 29 Jan 2015 16:37:57 -0500
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

The following changes since commit ec6f34e5b552fb0a52e6aae1a5afbbb1605cc6cc:

  Linux 3.19-rc5 (2015-01-18 18:02:20 +1200)

are available in the git repository at:

  git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-3.19-3

for you to fetch changes up to 2ef47eb1aee171ecf1d83311b9f7fae80f330181:

  NFS: Fix use of nfs_attr_use_mounted_on_fileid() (2015-01-21 17:15:41 -0500)

----------------------------------------------------------------
NFS client bugfixes for Linux 3.19

Highlights include:
- Stable fix for a NFSv4.1 Oops on mount
- Stable fix for an O_DIRECT deadlock condition
- Fix an issue with submounted volumes and fake duplicate inode numbers

----------------------------------------------------------------
Anna Schumaker (1):
      NFS: Fix use of nfs_attr_use_mounted_on_fileid()

Peng Tao (1):
      nfs: fix dio deadlock when O_DIRECT flag is flipped

Trond Myklebust (1):
      NFSv4.1: Fix an Oops in nfs41_walk_client_list

 fs/nfs/direct.c     | 6 ++++++
 fs/nfs/inode.c      | 5 +++--
 fs/nfs/internal.h   | 2 --
 fs/nfs/nfs4client.c | 2 +-
 4 files changed, 10 insertions(+), 5 deletions(-)


