Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f45.google.com ([209.85.220.45]:54902 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755399AbaKUKPK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Nov 2014 05:15:10 -0500
Received: by mail-pa0-f45.google.com with SMTP id lj1so4590893pab.32
        for <linux-nfs@vger.kernel.org>; Fri, 21 Nov 2014 02:15:10 -0800 (PST)
From: Omar Sandoval <osandov@osandov.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
        Andrew Morton <akpm@linux-foundation.org>, Chris Mason <clm@fb.com>,
        Josef Bacik <jbacik@fb.com>, linux-btrfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Mel Gorman <mgorman@suse.de>
Cc: Omar Sandoval <osandov@osandov.com>
Subject: [PATCH v2 0/5] btrfs: implement swap file support
Date: Fri, 21 Nov 2014 02:08:26 -0800
Message-Id: <cover.1416563833.git.osandov@osandov.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch series, based on 3.18-rc5, implements support for swap files on
BTRFS.

The standard swap file implementation uses the filesystem's implementation of
bmap() to get a list of physical blocks on disk, which the swap file code then
does I/O on directly without going through the filesystem. This doesn't work
for BTRFS, which is copy-on-write and therefore moves disk blocks around (COW
isn't the only thing that can shuffle around disk blocks: consider
defragmentation, balancing, etc.).

Swap-over-NFS introduced an interface through which a filesystem can arbitrate
swap I/O through address space operations:

- swap_activate() is called by swapon() and informs the address space that the
  given file is going to be used for swap, so it should take adequate measures
  like reserving space on disk and pinning block lookup information in memory
- swap_deactivate() is used to clean up on swapoff()
- readpage() is used to page in (read a page from disk)
- direct_IO() is used to page out (write a page out to disk)

Version 2 modifies this interface in the first part of the patch series to use
direct_IO for both reads and writes, which makes things much cleaner.

The second part of the patch series implements support for the interface on
BTRFS, which just means implementing swap_{,de}activate and adding some chattr
checks, which raises the following considerations:

- We can't do direct I/O on compressed or inline extents, so we can't use files
  with either for swap.
- Supporting COW swapfiles might also come with some weird edge cases?

This functionality is tenuously tested in a virtual machine with some
artificial workloads. Comment away.

Omar Sandoval (5):
  direct-io: don't dirty ITER_BVEC pages on read
  nfs: don't dirty ITER_BVEC pages read through direct I/O
  swap: use direct I/O for SWP_FILE swap_readpage
  btrfs: don't allow -C or +c chattrs on a swap file
  btrfs: enable swap file support

v2: use direct_IO for swap_readpage

 fs/btrfs/inode.c | 71 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/btrfs/ioctl.c | 50 ++++++++++++++++++++++++---------------
 fs/direct-io.c   |  8 ++++---
 fs/nfs/direct.c  |  5 +++-
 mm/page_io.c     | 32 +++++++++++++++++++++----
 5 files changed, 139 insertions(+), 27 deletions(-)

-- 
2.1.3

