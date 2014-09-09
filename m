Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f180.google.com ([209.85.220.180]:35057 "EHLO
	mail-vc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751367AbaIIEuc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Sep 2014 00:50:32 -0400
Received: by mail-vc0-f180.google.com with SMTP id lf12so16025380vcb.25
        for <linux-nfs@vger.kernel.org>; Mon, 08 Sep 2014 21:50:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1408637375-11343-17-git-send-email-hch@lst.de>
References: <1408637375-11343-1-git-send-email-hch@lst.de>
	<1408637375-11343-17-git-send-email-hch@lst.de>
Date: Mon, 8 Sep 2014 21:50:32 -0700
Message-ID: <CAHQdGtT+e8Wb4P8KJc428DUn52xeuKvToFKHQSMCiqcXQq4Vsw@mail.gmail.com>
Subject: Re: [PATCH 16/19] pnfs/blocklayout: rewrite extent tracking
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 21, 2014 at 9:09 AM, Christoph Hellwig <hch@lst.de> wrote:
> Currently the block layout driver tracks extents in three separate
> data structures:
>
>  - the two list of pnfs_block_extent structures returned by the server
>  - the list of sectors that were in invalid state but have been written to
>  - a list of pnfs_block_short_extent structures for LAYOUTCOMMIT
>
> All of these share the property that they are not only highly inefficient
> data structures, but also that operations on them are even more inefficient
> than nessecary.
>
> In addition there are various implementation defects like:
>
>  - using an int to track sectors, causing corruption for large offsets
>  - incorrect normalization of page or block granularity ranges
>  - insufficient error handling
>  - incorrect synchronization as extents can be modified while they are in
>    use
>
> This patch replace all three data with a single unified rbtree structure
> tracking all extents, as well as their in-memory state, although we still
> need to instance for read-only and read-write extent due to the arcane
> client side COW feature in the block layouts spec.
>
> To fix the problem of extent possibly being modified while in use we make
> sure to return a copy of the extent for use in the write path - the
> extent can only be invalidated by a layout recall or return which has
> to wait until the I/O operations finished due to refcounts on the layout
> segment.
>
> The new extent tree work similar to the schemes used by block based
> filesystems like XFS or ext4.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/nfs/blocklayout/Makefile         |   3 +-
>  fs/nfs/blocklayout/blocklayout.c    | 258 +++-------
>  fs/nfs/blocklayout/blocklayout.h    | 112 +----
>  fs/nfs/blocklayout/blocklayoutdev.c |  35 +-
>  fs/nfs/blocklayout/extent_tree.c    | 545 ++++++++++++++++++++++
>  fs/nfs/blocklayout/extents.c        | 908 ------------------------------------
>  6 files changed, 649 insertions(+), 1212 deletions(-)
>  create mode 100644 fs/nfs/blocklayout/extent_tree.c
>  delete mode 100644 fs/nfs/blocklayout/extents.c
>

Holding due to dependencies on unapplied patches in the series.


-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
