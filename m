Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-fx0-f46.google.com ([209.85.161.46]:51587 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755351Ab1KJIhj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Nov 2011 03:37:39 -0500
Received: by fagn18 with SMTP id n18so255657fag.19
        for <linux-nfs@vger.kernel.org>; Thu, 10 Nov 2011 00:37:38 -0800 (PST)
Message-ID: <4EBB8D4E.7080300@tonian.com>
Date: Thu, 10 Nov 2011 10:37:34 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: Peng Tao <bergwolf@gmail.com>
CC: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com
Subject: Re: [PATCH 0/8] pnfsblock cleanup and fixes
References: <1320851766-1834-1-git-send-email-bergwolf@gmail.com>
In-Reply-To: <1320851766-1834-1-git-send-email-bergwolf@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2011-11-09 17:15, Peng Tao wrote:
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

I can't find this patch in my mailbox.
It looks like you did not send it...
http://thread.gmane.org/gmane.linux.nfs/44761

Benny

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
