Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:34256 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754435AbbFRURc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Jun 2015 16:17:32 -0400
Received: by iebmu5 with SMTP id mu5so62265154ieb.1
        for <linux-nfs@vger.kernel.org>; Thu, 18 Jun 2015 13:17:31 -0700 (PDT)
Date: Thu, 18 Jun 2015 16:17:27 -0400
From: Jeff Layton <jeff.layton@primarydata.com>
To: Peng Tao <tao.peng@primarydata.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 00/11] pnfs/flexfiles: layoutstats support
Message-ID: <20150618161727.1b4e287f@tlielax.poochiereds.net>
In-Reply-To: <1434466052-10491-1-git-send-email-tao.peng@primarydata.com>
References: <1434466052-10491-1-git-send-email-tao.peng@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 16 Jun 2015 22:47:21 +0800
Peng Tao <tao.peng@primarydata.com> wrote:

> Hi all,
> 
> The patchsets add LAYOUTSTATS support to flexfiles. LAYOUTSTATS are sent
> every minute if IO is still happening upon a file.
> 
> One limitation is that at most 4 LAYOUTSTATS calls are permitted in a compound.
> Had to send multiple LAYOUTSTATS operations per compound because OP_LAYOUTSTATS
> requires stateid and deviceid as its arguments, which makes it a per-file per-deviceid
> call.
> 

So what happens if there are more than 4 mirrors? Do you send more
LAYOUTSTATS rpcs or do the other ones get left out? I couldn't quite
tell that from looking over the code...

> Cheers,
> Tao
> 
> Peng Tao (8):
>   pNFS: fill in nfs42_layoutstat_ops
>   pnfs: add pnfs_report_layoutstat helper function
>   pNFS/flexfiles: track when layout is first used
>   pnfs/flexfiles: add ff_layout_prepare_layoutstats
>   pnfs/flexfiles: encode LAYOUTSTATS flexfiles specific data
>   pnfs/flexfiles: reset IO statistics upon LAYOUTSTATS success
>   nfs42: serialize LAYOUTSTATS calls of the same file
>   pnfs/flexfiles: report layoutstat regularly
> 
> Trond Myklebust (3):
>   NFSv.2/pnfs Add a LAYOUTSTATS rpc function
>   pNFS/flexfiles: Remove unused struct members user_name, group_name
>   pNFS/flexfiles: add layoutstats tracking
> 
>  fs/nfs/flexfilelayout/flexfilelayout.c | 448 ++++++++++++++++++++++++++++++++-
>  fs/nfs/flexfilelayout/flexfilelayout.h |  30 ++-
>  fs/nfs/nfs42.h                         |   7 +-
>  fs/nfs/nfs42proc.c                     |  81 ++++++
>  fs/nfs/nfs42xdr.c                      | 122 +++++++++
>  fs/nfs/nfs4_fs.h                       |   1 +
>  fs/nfs/nfs4proc.c                      |   4 +-
>  fs/nfs/nfs4xdr.c                       |   1 +
>  fs/nfs/pnfs.c                          |  56 +++++
>  fs/nfs/pnfs.h                          |   3 +
>  include/linux/nfs4.h                   |   1 +
>  include/linux/nfs_fs.h                 |   1 +
>  include/linux/nfs_xdr.h                |  43 ++++
>  13 files changed, 782 insertions(+), 16 deletions(-)
> 

Nice work, Tao. This looks pretty good to me. I had a couple of
nitpicky comments, but that's stuff that can wait unless you need to
respin for other reasons.

You can add my:

Reviewed-by: Jeff Layton <jeff.layton@primarydata.com>
