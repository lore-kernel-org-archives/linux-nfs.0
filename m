Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f177.google.com ([209.85.223.177]:48656 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754481AbaIZO3e (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Sep 2014 10:29:34 -0400
Received: by mail-ie0-f177.google.com with SMTP id x19so15656199ier.22
        for <linux-nfs@vger.kernel.org>; Fri, 26 Sep 2014 07:29:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1411740170-18611-2-git-send-email-hch@lst.de>
References: <1411740170-18611-1-git-send-email-hch@lst.de>
	<1411740170-18611-2-git-send-email-hch@lst.de>
Date: Fri, 26 Sep 2014 10:29:34 -0400
Message-ID: <CAHQdGtTg8Tc8bRqbezW-ZWrcTJdG233uRTrqQMP5CvxAcjW9Fg@mail.gmail.com>
Subject: Re: [PATCH] pnfs/blocklayout: serialize GETDEVICEINFO calls
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 26, 2014 at 10:02 AM, Christoph Hellwig <hch@lst.de> wrote:
> The rpc_pipefs code isn't thread safe, leading to occasional use after
> frees when running xfstests generic/241 (dbench).
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/nfs/blocklayout/rpc_pipefs.c | 14 +++++++++-----
>  fs/nfs/netns.h                  |  1 +
>  2 files changed, 10 insertions(+), 5 deletions(-)
>
>

It worries me that we're putting a mutex directly in the writeback
path. For small arrays, it might be acceptable, but what if you have a
block device with 1000s of disks on the back end?

Is there no better way to fix this issue?

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
