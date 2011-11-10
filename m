Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mexforward.lss.emc.com ([128.222.32.20]:18599 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752151Ab1KJCJi convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Nov 2011 21:09:38 -0500
From: <tao.peng@emc.com>
To: <bhalevy@tonian.com>
CC: <Trond.Myklebust@netapp.com>, <linux-nfs@vger.kernel.org>
Date: Wed, 9 Nov 2011 21:09:13 -0500
Subject: RE: [PATCH 0/8] pnfsblock cleanup and fixes
Message-ID: <F19688880B763E40B28B2B462677FBF805DD054B4F@MX09A.corp.emc.com>
References: <1320851766-1834-1-git-send-email-bergwolf@gmail.com>
In-Reply-To: <1320851766-1834-1-git-send-email-bergwolf@gmail.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Benny, hi,

These patches fail to apply to pnfs-latest branch because of conflicts with pnfs private workqueue patches. Since Trond has decided not to take pnfs private workqueue patches, would you please drop them so that new patches can apply? I can send you revert patches if you want.

Thanks,
Tao

> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org]
> On Behalf Of Peng Tao
> Sent: Wednesday, November 09, 2011 11:16 PM
> To: linux-nfs@vger.kernel.org
> Cc: Trond.Myklebust@netapp.com; bhalevy@tonian.com
> Subject: [PATCH 0/8] pnfsblock cleanup and fixes
> 
> Hi, Trond and Benny,
> 
> Bellow are some pnfsblock patches that I have tested for days. Most of them
> are cleanup and small improvements. Only
> [PATCH 2/8] pnfsblock: acquire im_lock in _preload_range
> needs to go into stable.
> 
> Thanks,
> Tao
> 
> Peng Tao (8):
>   pnfsblock: cleanup bl_mark_sectors_init
>   pnfsblock: acquire im_lock in _preload_range
>   pnfsblock: move find lock page logic out of bl_write_pagelist
>   pnfsblock: set read/write tk_status to pnfs_error
>   pnfsblock: remove rpc_call_ops from struct parallel_io
>   pnfsblock: clean up _add_entry
>   pnfsblock: add im_extents to pnfs_inval_markings
>   pnfsblock: alloc short extent before submit bio
> 
>  fs/nfs/blocklayout/blocklayout.c |  176 +++++++++++++++++++++++++-------------
>  fs/nfs/blocklayout/blocklayout.h |   11 ++-
>  fs/nfs/blocklayout/extents.c     |  146 ++++++++++++--------------------
>  3 files changed, 180 insertions(+), 153 deletions(-)
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

