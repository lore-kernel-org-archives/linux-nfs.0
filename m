Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:46335 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751260AbdLKGES (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 11 Dec 2017 01:04:18 -0500
From: NeilBrown <neilb@suse.com>
To: Linus Torvalds <torvalds@linux-foundation.org>,
        Al Viro <viro@zeniv.linux.org.uk>
Date: Mon, 11 Dec 2017 17:04:05 +1100
Subject: [PATCH 0/4] VFS: fix assorted issues with name_to_handle
 conversions.
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Amir Goldstein <amir73il@gmail.com>,
        lkml <linux-kernel@vger.kernel.org>,
        Lennart Poettering <lennart@poettering.net>
Message-ID: <151297214390.7818.7216826079527521005.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This series of patches is the result of discussion following the
previous patch which increases MAX_HANDLE_SZ.

Thanks,
NeilBrown

---

NeilBrown (4):
      fs/notify: fdinfo can report unsupported file handles.
      fs/notify: don't put file handle buffer on stack.
      NFS: allow name_to_handle_at() to work for Amazon EFS.
      fhandle: Improve error responses in name_to_handle_at()


 fs/exportfs/expfs.c      |    4 +++-
 fs/fhandle.c             |   16 +++++++++-----
 fs/nfs/export.c          |    2 ++
 fs/notify/fdinfo.c       |   51 +++++++++++++++++++++++-----------------------
 include/linux/exportfs.h |   10 +++++++--
 5 files changed, 49 insertions(+), 34 deletions(-)

--
Signature

