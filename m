Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vx0-f174.google.com ([209.85.220.174]:54117 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935349Ab1KJPwk convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Nov 2011 10:52:40 -0500
Received: by vcbf1 with SMTP id f1so2497228vcb.19
        for <linux-nfs@vger.kernel.org>; Thu, 10 Nov 2011 07:52:40 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1320938728-3715-1-git-send-email-bergwolf@gmail.com>
References: <1320938728-3715-1-git-send-email-bergwolf@gmail.com>
From: Peng Tao <bergwolf@gmail.com>
Date: Thu, 10 Nov 2011 23:52:17 +0800
Message-ID: <CA+a=Yy64JczxkfJfO9=p152b_mLVCopOZmpn0R4Pd2qitGvs3g@mail.gmail.com>
Subject: Re: [PATCH-v2 0/7] pnfsblock cleanup and fixes
To: linux-nfs@vger.kernel.org
Cc: Trond.Myklebust@netapp.com, bhalevy@tonian.com
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 10, 2011 at 11:25 PM, Peng Tao <bergwolf@gmail.com> wrote:
> Hi, Trond and Benny,
>
> These are updated v2 of the pnfsblock patches and all Benny's comments are addressed.
>
> Thanks,
> Tao
>
> Peng Tao (8):
>  pnfsblock: cleanup bl_mark_sectors_init
>  pnfsblock: acquire im_lock in _preload_range
>  pnfsblock: move find lock page logic out of bl_write_pagelist
>  pnfsblock: set read/write tk_status to pnfs_error
>  pnfsblock: remove rpc_call_ops from struct parallel_io
>  pnfsblock: clean up _add_entry
>  pnfsblock: alloc short extent before submit bio
>  pnfsblock: release lock when freeing block_dev
And sorry for mistyping... The patchset has only 7 patches. The last
one is still under test and is not included here...

-- 
Thanks,
Tao
