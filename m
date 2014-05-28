Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ve0-f176.google.com ([209.85.128.176]:50293 "EHLO
	mail-ve0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754069AbaE1XXS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 May 2014 19:23:18 -0400
Received: by mail-ve0-f176.google.com with SMTP id jz11so13341036veb.35
        for <linux-nfs@vger.kernel.org>; Wed, 28 May 2014 16:23:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1400169417-28245-1-git-send-email-dros@primarydata.com>
References: <1400169417-28245-1-git-send-email-dros@primarydata.com>
Date: Wed, 28 May 2014 19:23:17 -0400
Message-ID: <CAHQdGtQyR9bXz7-xFfM2JTiLi6R_Vaj6rfpNweEEAL+7-iCRwA@mail.gmail.com>
Subject: Re: [PATCH v3 00/18] nfs: support multiple requests per page
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Weston Andros Adamson <dros@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 15, 2014 at 11:56 AM, Weston Andros Adamson
<dros@primarydata.com> wrote:
> This patchset changes the read and write paths to be more flexible in dealing
> with requests that are not page aligned. Until now there was a 1:1 mapping
> of struct nfs_page (referred to as "nfs requests") to struct page, which
> limited the client to page aligned I/O in several pNFS scenarios.
>
> This patchset allows multiple requests per page, loosely following
> the approach taken with struct buffer_head (part of kernel bio interface).
>
> With this patchset the client now supports:
>  - non-page-aligned O_DIRECT I/O to DSes (instead of reverting to MDS)
>  - arbitrary pnfs layout segment boundaries
>  - arbitrary pnfs filelayout stripe sizes
>
> This patchset also includes a lot of cleanup - notably we no longer need
> a separate code path to support rsize/wsize < PAGE_SIZE.
>
> This new approach opens the door to many optimizations, such as not having to
> flush a page on a non-contiguous write, but for the time being we are focusing
> on correctness -- this patchset touches the read and write path for *all*
> versions of NFS!
>
> This has been tested against v2, v3, v4.0 and v4.1 (no pnfs) servers with
> different rsize/wsize settings, and against pynfs filelayout servers hacked to
> have non page aligned stripe sizes.
>
> I had some code review already (with changes applied) and we've been testing
> this pretty extensively for the last month+ - focusing mostly on v2, v3, v4.x
> (no pnfs).
>
> The patchset applies against Trond's testing branch, but should also include
> the fix I posted earlier today: "pnfs: fix race in filelayout commit path"
> as the race seems to be easier to hit with this patchset applied.
>
> I'm pretty sure I didn't break anything in the object and block layouts, but
> some extra attention there would be helpful.
>
> I plan on sharing some performance numbers once I'm able to run some nfsometer
> workloads.
>
> Changes in V3:
>    - rebased to Anna's newest patches, which merges pageio.c into pagelist.c

Thanks! Applied...

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
