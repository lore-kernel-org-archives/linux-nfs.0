Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f42.google.com ([209.85.218.42]:34511 "EHLO
	mail-oi0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752626AbcAWRcG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 23 Jan 2016 12:32:06 -0500
Received: by mail-oi0-f42.google.com with SMTP id k206so66518781oia.1
        for <linux-nfs@vger.kernel.org>; Sat, 23 Jan 2016 09:32:04 -0800 (PST)
MIME-Version: 1.0
Date: Sat, 23 Jan 2016 12:32:04 -0500
Message-ID: <CAHQdGtTXhsmcE-2+R_XbCpqw7dWc+C=aT0K=X_OOnLCXYvd87g@mail.gmail.com>
Subject: [GIT PULL] Please pull bugfixes+cleanup for Linux 4.5
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

The following changes since commit 44aab3e09ef947e546ee61c5082c41b86dd15e53:


  NFS: Fix a compile warning about unused variable in
nfs_generic_pg_pgios() (2016-01-08 08:12:47 -0500)


are available in the git repository at:


  git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-4.5-2


for you to fetch changes up to 6d45c042f35ea9b27bf946380f74ff75d32280c9:


  Merge branch 'bugfixes' (2016-01-22 11:02:36 -0500)


----------------------------------------------------------------

NFS client bugfixes and cleanups for Linux 4.5


Bugfixes:

- pNFS/flexfiles: Fix an XDR encoding bug in layoutreturn

- pNFS/flexfiles: Improve merging of errors in LAYOUTRETURN


Cleanups:

- NFS: Simplify nfs_request_add_commit_list() arguments


----------------------------------------------------------------

Anna Schumaker (1):

      NFS: Simplify nfs_request_add_commit_list() arguments


Trond Myklebust (3):

      pNFS/flexfiles: Improve merging of errors in LAYOUTRETURN

      pNFS/flexfiles: Fix an XDR encoding bug in layoutreturn

      Merge branch 'bugfixes'


 fs/nfs/filelayout/filelayout.c            |  2 +-

 fs/nfs/flexfilelayout/flexfilelayout.c    |  6 +-

 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 99 +++++++++++++------------------

 fs/nfs/internal.h                         |  2 +-

 fs/nfs/write.c                            |  7 +--

 5 files changed, 47 insertions(+), 69 deletions(-)

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
