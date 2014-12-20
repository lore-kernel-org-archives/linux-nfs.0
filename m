Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f179.google.com ([209.85.192.179]:40385 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751830AbaLTDSl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Dec 2014 22:18:41 -0500
Received: by mail-pd0-f179.google.com with SMTP id fp1so2348948pdb.38
        for <linux-nfs@vger.kernel.org>; Fri, 19 Dec 2014 19:18:41 -0800 (PST)
From: Omar Sandoval <osandov@osandov.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
        Andrew Morton <akpm@linux-foundation.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org,
        linux-mm@kvack.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Cc: Omar Sandoval <osandov@osandov.com>
Subject: [PATCH v2 0/5] clean up and generalize swap-over-NFS
Date: Fri, 19 Dec 2014 19:18:24 -0800
Message-Id: <cover.1419044605.git.osandov@osandov.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

This patch series (based on ecb5ec0 in Linus' tree) contains all of the
non-BTRFS work that I've done to implement swapfiles on BTRFS. The BTRFS
portion is still undergoing development and is now outweighed by the
non-BTRFS changes, so I want to get these in separately.

Version 2 changes the generic swapfile interface to use ->read_iter and
->write_iter instead of using ->direct_IO directly in response to
discussion on the previous submission. It also adds the iov_iter_is_bvec
helper to factor out some common checks.

Version 1 can be found here: https://lkml.org/lkml/2014/12/15/7

Omar Sandoval (5):
  iov_iter: add ITER_BVEC helpers
  direct-io: don't dirty ITER_BVEC pages on read
  nfs: don't dirty ITER_BVEC pages read through direct I/O
  swapfile: use ->read_iter and ->write_iter
  vfs: update swap_{,de}activate documentation

 Documentation/filesystems/Locking |  7 ++++---
 Documentation/filesystems/vfs.txt |  7 ++++---
 fs/direct-io.c                    |  8 ++++---
 fs/nfs/direct.c                   |  5 ++++-
 fs/splice.c                       |  7 ++-----
 include/linux/uio.h               |  7 +++++++
 mm/iov_iter.c                     | 12 +++++++++++
 mm/page_io.c                      | 44 +++++++++++++++++++++++++--------------
 mm/swapfile.c                     | 11 +++++++++-
 9 files changed, 76 insertions(+), 32 deletions(-)

-- 
2.2.1

