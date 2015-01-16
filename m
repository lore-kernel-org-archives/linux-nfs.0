Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f170.google.com ([209.85.192.170]:55850 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751930AbbAPEGc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Jan 2015 23:06:32 -0500
Date: Thu, 15 Jan 2015 20:06:28 -0800
From: Brian Norris <computersforpeace@gmail.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Jens Axboe <axboe@fb.com>, linux-nfs@vger.kernel.org, linux-mm@kvack.org,
        David Howells <dhowells@redhat.com>, linux-fsdevel@vger.kernel.org,
        linux-mtd@lists.infradead.org, Tejun Heo <tj@kernel.org>,
        ceph-devel@vger.kernel.org, David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH 03/12] fs: introduce f_op->mmap_capabilities for nommu
 mmap support
Message-ID: <20150116040628.GG9759@ld-irv-0074>
References: <1421228561-16857-1-git-send-email-hch@lst.de>
 <1421228561-16857-4-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1421228561-16857-4-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

+ dwmw2

On Wed, Jan 14, 2015 at 10:42:32AM +0100, Christoph Hellwig wrote:
> Since "BDI: Provide backing device capability information [try #3]" the
> backing_dev_info structure also provides flags for the kind of mmap
> operation available in a nommu environment, which is entirely unrelated
> to it's original purpose.
> 
> Introduce a new nommu-only file operation to provide this information to
> the nommu mmap code instead.  Splitting this from the backing_dev_info
> structure allows to remove lots of backing_dev_info instance that aren't
> otherwise needed, and entirely gets rid of the concept of providing a
> backing_dev_info for a character device.  It also removes the need for
> the mtd_inodefs filesystem.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Reviewed-by: Tejun Heo <tj@kernel.org>
> ---
>  Documentation/nommu-mmap.txt                    |  8 +--
>  block/blk-core.c                                |  2 +-
>  drivers/char/mem.c                              | 64 ++++++++++----------
>  drivers/mtd/mtdchar.c                           | 72 ++++------------------
>  drivers/mtd/mtdconcat.c                         | 10 ----
>  drivers/mtd/mtdcore.c                           | 80 +++++++------------------
>  drivers/mtd/mtdpart.c                           |  1 -

There's a small conflict in mtdcore.c with some stuff I have queued up
for MTD in linux-next. Should be trivial to resolve later.

I don't have a test platform for nommu, and I'll admit I'm not too
familiar with this code, but it looks OK to me. So FWIW, for the MTD
parts:

Acked-by: Brian Norris <computersforpeace@gmail.com>

>  drivers/staging/lustre/lustre/llite/llite_lib.c |  2 +-
>  fs/9p/v9fs.c                                    |  2 +-
>  fs/afs/volume.c                                 |  2 +-
>  fs/aio.c                                        | 14 +----
>  fs/btrfs/disk-io.c                              |  3 +-
>  fs/char_dev.c                                   | 24 --------
>  fs/cifs/connect.c                               |  2 +-
>  fs/coda/inode.c                                 |  2 +-
>  fs/configfs/configfs_internal.h                 |  2 -
>  fs/configfs/inode.c                             | 18 +-----
>  fs/configfs/mount.c                             | 11 +---
>  fs/ecryptfs/main.c                              |  2 +-
>  fs/exofs/super.c                                |  2 +-
>  fs/ncpfs/inode.c                                |  2 +-
>  fs/ramfs/file-nommu.c                           |  7 +++
>  fs/ramfs/inode.c                                | 22 +------
>  fs/romfs/mmap-nommu.c                           | 10 ++++
>  fs/ubifs/super.c                                |  2 +-
>  include/linux/backing-dev.h                     | 33 ++--------
>  include/linux/cdev.h                            |  2 -
>  include/linux/fs.h                              | 23 +++++++
>  include/linux/mtd/mtd.h                         |  2 +
>  mm/backing-dev.c                                |  7 +--
>  mm/nommu.c                                      | 69 ++++++++++-----------
>  security/security.c                             | 13 ++--
>  32 files changed, 169 insertions(+), 346 deletions(-)
[...]

Brian
