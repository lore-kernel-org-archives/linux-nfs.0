Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:60487 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932330Ab2AISFM convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Jan 2012 13:05:12 -0500
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Subject: RE: [PATCH 0/9] pnfsblock: patches for 3.3
Date: Mon, 9 Jan 2012 10:04:37 -0800
Message-ID: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430CCB0792@SACMVEXC2-PRD.hq.netapp.com>
In-Reply-To: <1326124939-2152-1-git-send-email-bergwolf@gmail.com>
References: <1326124939-2152-1-git-send-email-bergwolf@gmail.com>
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Peng Tao" <bergwolf@gmail.com>
Cc: <linux-nfs@vger.kernel.org>, <mdw@umich.edu>, <honey@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Tao,

At this point in the merge window, I'm not going to take any new
pNFS-related patches for 3.3 that have not been in the linux-next tree,
but I can queue up the bugfixes for inclusion in a post-rc1 bugfixes
push. Could you please resend those, on top of a clean nfs-for-3.3
branch?

Cheers
  Trond

> -----Original Message-----
> From: Peng Tao [mailto:bergwolf@gmail.com]
> Sent: Monday, January 09, 2012 11:02 AM
> To: Myklebust, Trond
> Cc: linux-nfs@vger.kernel.org; mdw@umich.edu; honey@citi.umich.edu
> Subject: [PATCH 0/9] pnfsblock: patches for 3.3
> 
> Hi Trond,
> 
> These are blocklayout patches for 3.3. All have been sent to list
before and
> merged by Benny.
> 
> Patches can also be found at http://github.com/bergwolf/linux.git
for-trond-
> 3.3
> 
> Thanks,
> Tao
> 
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
>  fs/nfs/blocklayout/blocklayout.c |  202
++++++++++++++++++++++++-------
> ------
>  fs/nfs/blocklayout/blocklayout.h |   12 ++-
>  fs/nfs/blocklayout/extents.c     |  176
++++++++++++++-------------------
>  3 files changed, 215 insertions(+), 175 deletions(-)

