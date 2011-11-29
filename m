Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:50516 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755941Ab1K2Xj5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Nov 2011 18:39:57 -0500
Message-ID: <4ED56D42.3090604@panasas.com>
Date: Tue, 29 Nov 2011 15:39:46 -0800
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Jim Rees <rees@umich.edu>
CC: Peng Tao <bergwolf@gmail.com>, <Trond.Myklebust@netapp.com>,
        <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/9] pnfsblock patches
References: <1322887583-2719-1-git-send-email-bergwolf@gmail.com> <4ED550DE.5030505@panasas.com> <20111129225853.GA8975@umich.edu>
In-Reply-To: <20111129225853.GA8975@umich.edu>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/29/2011 02:58 PM, Jim Rees wrote:
> Boaz Harrosh wrote:
> 
>   On 12/02/2011 08:46 PM, Peng Tao wrote:
>   > Hi, Trond,
>   > 
>   > Following are some bugfix and improvements for blocklayout driver. All have been
>   > sent to the list before and have been tested for several weeks.
>   > 
>   
>   I never got 9 patches in the mail.
>   
>   I only have 1,3,4,5,6,7
>   
>   Do you have them on a gitweb, or re-post 2,8,9
> 
> 1-7 are in benny's tree:
> 
> % git log --oneline -7 benny/pnfs-block
> ec11faf pnfsblock: alloc short extent before submit bio
> 7c93c37 pnfsblock: clean up _add_entry
> 85e8c84 pnfsblock: remove rpc_call_ops from struct parallel_io
> ab0c07d pnfsblock: set read/write tk_status to pnfs_error
> 60d5135 pnfsblock: move find lock page logic out of bl_write_pagelist
> 657c2f4 pnfsblock: acquire im_lock in _preload_range
> e5b35df pnfsblock: cleanup bl_mark_sectors_init
> 
> I never saw 8,9 and can't find them in the list archive.

Actually I wanted 9. I'm old and senile but I did not remember
I ever saw it so I was wondering.

We know their names from [0/9]:
  pnfsblock: don't spinlock when freeing block_dev
  pnfsblock: limit bio page count

Thanks
Heart
