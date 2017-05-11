Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:32921 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755029AbdEKHxb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 11 May 2017 03:53:31 -0400
Subject: Re: [GIT PULL] Please pull NFS client fixes for 4.12
To: Trond Myklebust <trondmy@primarydata.com>,
        "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>
References: <1494434821.4764.1.camel@primarydata.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Michal Hocko <mhocko@suse.com>
From: Nikolay Borisov <n.borisov.lkml@gmail.com>
Message-ID: <be16be57-235c-fdf9-f708-3898aeeeb5aa@gmail.com>
Date: Thu, 11 May 2017 10:53:27 +0300
MIME-Version: 1.0
In-Reply-To: <1494434821.4764.1.camel@primarydata.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10.05.2017 19:47, Trond Myklebust wrote:
> Hi Linus,
> 
> The following changes since commit 4f7d029b9bf009fbee76bb10c0c4351a1870d2f3:
> 
>   Linux 4.11-rc7 (2017-04-16 13:00:18 -0700)
> 
> are available in the git repository at:
> 
>   git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-4.12-1
> 
> for you to fetch changes up to 76b2a303384e1d6299c3a0249f0f0ce2f8f96017:
> 
>   pNFS/flexfiles: Always attempt to call layoutstats when flexfiles is enabled (2017-05-09 16:02:57 -0400)
> 
> ----------------------------------------------------------------
> NFS client updates for Linux 4.12
> 
> Highlights include:
> 
> Stable bugfixes:
> - Fix use after free in write error path
> - Use GFP_NOIO for two allocations in writeback
> - Fix a hang in OPEN related to server reboot
> - Check the result of nfs4_pnfs_ds_connect
> - Fix an rcu lock leak
> 
> Features:
> - Removal of the unmaintained and unused OSD pNFS layout
> - Cleanup and removal of lots of unnecessary dprintk()s
> - Cleanup and removal of some memory failure paths now that
>   GFP_NOFS is guaranteed to never fail.

What guarantees that? Since if this is the case then this can result in
a lot of opportunities for cleanup across the whole kernel tree. After
discussing with mhocko (cc'ed) it seems that in practice everything
below COSTLY_ORDER which are not GFP_NORETRY will never fail. But this
semantic is not the same as GFP_NOFAIL. E.g. nothing guarantees that
this will stay like that in the future?



[omitted for brevity]
