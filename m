Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:48156 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756840Ab1K2Vit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Nov 2011 16:38:49 -0500
Message-ID: <4ED550DE.5030505@panasas.com>
Date: Tue, 29 Nov 2011 13:38:38 -0800
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Peng Tao <bergwolf@gmail.com>
CC: <Trond.Myklebust@netapp.com>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/9] pnfsblock patches
References: <1322887583-2719-1-git-send-email-bergwolf@gmail.com>
In-Reply-To: <1322887583-2719-1-git-send-email-bergwolf@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12/02/2011 08:46 PM, Peng Tao wrote:
> Hi, Trond,
> 
> Following are some bugfix and improvements for blocklayout driver. All have been
> sent to the list before and have been tested for several weeks.
> 

I never got 9 patches in the mail.

I only have 1,3,4,5,6,7

Do you have them on a gitweb, or re-post 2,8,9

Thanks
Boaz

> Peng Tao (9):
>   pnfsblock: cleanup bl_mark_sectors_init
>   pnfsblock: acquire im_lock in _preload_range
>   pnfsblock: move find lock page logic out of bl_write_pagelist
>   pnfsblock: set read/write tk_status to pnfs_error
>   pnfsblock: remove rpc_call_ops from struct parallel_io
>   pnfsblock: clean up _add_entry
>   pnfsblock: alloc short extent before submit bio
>   pnfsblock: don't spinlock when freeing block_dev
>   pnfsblock: limit bio page count
> 
>  fs/nfs/blocklayout/blocklayout.c |  202 ++++++++++++++++++++++++-------------
>  fs/nfs/blocklayout/blocklayout.h |   12 ++-
>  fs/nfs/blocklayout/extents.c     |  176 ++++++++++++++-------------------
>  3 files changed, 215 insertions(+), 175 deletions(-)
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

