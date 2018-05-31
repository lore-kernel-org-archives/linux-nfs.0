Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:56374 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756035AbeEaS7V (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 31 May 2018 14:59:21 -0400
Date: Thu, 31 May 2018 14:59:20 -0400
To: Trond Myklebust <trondmy@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 00/19] Layoutget on OPEN
Message-ID: <20180531185920.GA3557@fieldses.org>
References: <20180530180553.38769-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180530180553.38769-1-trond.myklebust@hammerspace.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 30, 2018 at 02:05:34PM -0400, Trond Myklebust wrote:
> This patchset is something we've been sitting on for a couple of years
> in order to allow it to mature. It was mainly developed by Fred Isaman
> while he was working for Primary Data, but we've had a few bugfixes
> come in since then.
> The main reason for delaying the upstream merge was to ensure that
> adding layoutget to the OPEN compound was safe (does not cause existing
> layouts to be automatically revoked) and that it gives us a real
> performance benefit.

Do you have any of the performance data?

Or just a rough summary explaining when it helps most and by how much?

--b.

> 
> Fred Isaman (14):
>   pnfs: Remove redundant assignment from nfs4_proc_layoutget().
>   pnfs: Store return value of decode_layoutget for later processing
>   NFS4: move ctx into nfs4_run_open_task
>   pnfs: Add layout driver flag PNFS_LAYOUTGET_ON_OPEN
>   pnfs: refactor send_layoutget
>   pnfs: move allocations out of nfs4_proc_layoutget
>   pnfs: Add conditional encode/decode of LAYOUTGET within OPEN compound
>   pnfs: Move nfs4_opendata into nfs4_fs.h
>   pnfs: Change pnfs_alloc_init_layoutget_args call signature
>   pnfs: Add LAYOUTGET to OPEN of a new file
>   pnfs: Add LAYOUTGET to OPEN of an existing file
>   pnfs: Stop attempting LAYOUTGET on OPEN on failure
>   pnfs: Add barrier to prevent lgopen using LAYOUTGET during recall
>   pnfs: Fix manipulation of NFS_LAYOUT_FIRST_LAYOUTGET
> 
> Trond Myklebust (5):
>   NFSv4/pnfs: Ensure pnfs_parse_lgopen() won't try to parse
>     uninitialised data
>   NFSv4/pnfs: Don't switch off layoutget-on-open for transient errors
>   pNFS: Don't send LAYOUTGET on OPEN for read, if we already have cached
>     data
>   pnfs: Don't call commit on failed layoutget-on-open
>   pnfs: Don't release the sequence slot until we've processed layoutget
>     on open
> 
>  fs/nfs/callback_proc.c                 |   2 +
>  fs/nfs/flexfilelayout/flexfilelayout.c |   1 +
>  fs/nfs/nfs4_fs.h                       |  25 +++
>  fs/nfs/nfs4proc.c                      |  97 +++++----
>  fs/nfs/nfs4state.c                     |   8 +
>  fs/nfs/nfs4xdr.c                       |  65 +++++-
>  fs/nfs/pnfs.c                          | 266 +++++++++++++++++++++----
>  fs/nfs/pnfs.h                          |  28 ++-
>  include/linux/nfs_fs_sb.h              |   2 +
>  include/linux/nfs_xdr.h                |   4 +
>  10 files changed, 398 insertions(+), 100 deletions(-)
> 
> -- 
> 2.17.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
