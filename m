Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f173.google.com ([209.85.220.173]:45315 "EHLO
	mail-vc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750827AbaIIEwF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Sep 2014 00:52:05 -0400
Received: by mail-vc0-f173.google.com with SMTP id le20so2387329vcb.4
        for <linux-nfs@vger.kernel.org>; Mon, 08 Sep 2014 21:52:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1408637375-11343-20-git-send-email-hch@lst.de>
References: <1408637375-11343-1-git-send-email-hch@lst.de>
	<1408637375-11343-20-git-send-email-hch@lst.de>
Date: Mon, 8 Sep 2014 21:52:03 -0700
Message-ID: <CAHQdGtRb_YcVWTnQR3cAkU=CT7X5NyKLphcN-9bxuu_JozBzsQ@mail.gmail.com>
Subject: Re: [PATCH 19/19] pnfs/blocklayout: allocate separate pages for the
 layoutcommit payload
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 21, 2014 at 9:09 AM, Christoph Hellwig <hch@lst.de> wrote:
> Instead of overflowing the XDR send buffer with our extent list allocate
> pages and pre-encode the layoutupdate payload into them.  We optimistically
> allocate a single page use alloc_page and only switch to vmalloc when we
> have more extents outstanding.  Currently there is only a single testcase
> (xfstests generic/113) which can reproduce large enough extent lists for
> this to occur.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/nfs/blocklayout/blocklayout.c |  15 ++----
>  fs/nfs/blocklayout/blocklayout.h |   8 ++--
>  fs/nfs/blocklayout/extent_tree.c | 100 +++++++++++++++++++++++++++++++--------
>  3 files changed, 90 insertions(+), 33 deletions(-)
>

Holding due to dependencies on unapplied patches.

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
