Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:37277 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752084AbbESPza (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 May 2015 11:55:30 -0400
Received: by igbsb11 with SMTP id sb11so17655107igb.0
        for <linux-nfs@vger.kernel.org>; Tue, 19 May 2015 08:55:29 -0700 (PDT)
Message-ID: <1432050927.7675.1.camel@primarydata.com>
Subject: [GIT PULL] Please pull 2 client bugfixes
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Date: Tue, 19 May 2015 11:55:27 -0400
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

The following changes since commit 030bbdbf4c833bc69f502eae58498bc5572db736:

  Linux 4.1-rc3 (2015-05-10 15:12:29 -0700)

are available in the git repository at:

  git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-4.1-2

for you to fetch changes up to feaff8e5b2cfc3eae02cf65db7a400b0b9ffc596:

  nfs: take extra reference to fl->fl_file when running a setlk (2015-05-13 14:56:06 -0400)

----------------------------------------------------------------
NFS client bugfixes for Linux 4.1

Highlights include:

- Fix a Linux-4.1 regression affecting stat()
- Take an extra reference to fl->fl_file when running a setlk

----------------------------------------------------------------
Chuck Lever (1):
      nfs: stat(2) fails during cthon04 basic test5 on NFSv4.0

Jeff Layton (1):
      nfs: take extra reference to fl->fl_file when running a setlk

 fs/nfs/nfs4proc.c |  3 +++
 fs/nfs/write.c    | 13 ++++++++-----
 2 files changed, 11 insertions(+), 5 deletions(-)

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com


