Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f177.google.com ([209.85.220.177]:39951 "EHLO
	mail-vc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750881AbaIIEnT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Sep 2014 00:43:19 -0400
Received: by mail-vc0-f177.google.com with SMTP id hq11so16179994vcb.22
        for <linux-nfs@vger.kernel.org>; Mon, 08 Sep 2014 21:43:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1408637375-11343-15-git-send-email-hch@lst.de>
References: <1408637375-11343-1-git-send-email-hch@lst.de>
	<1408637375-11343-15-git-send-email-hch@lst.de>
Date: Mon, 8 Sep 2014 21:43:18 -0700
Message-ID: <CAHQdGtQ9UBeMUFd5qbLe0VkpUGy9SKARbgbcBO_1BrWyjbMs7A@mail.gmail.com>
Subject: Re: [PATCH 14/19] pnfs/blocklayout: remove read-modify-write handling
 in bl_write_pagelist
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 21, 2014 at 9:09 AM, Christoph Hellwig <hch@lst.de> wrote:
> Use the new PNFS_READ_WHOLE_PAGE flag to offload read-modify-write
> handling to core nfs code, and remove a huge chunk of deadlock prone
> mess from the block layout writeback path.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---

This also depends on "[PATCH 07/19] pnfs: add flag to force
read-modify-write in ->write_begin". Holding pending resolution.

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
