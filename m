Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:55481 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751887Ab1HPUnT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Aug 2011 16:43:19 -0400
Message-ID: <4E4AD655.9090305@panasas.com>
Date: Tue, 16 Aug 2011 13:43:01 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: Peng Tao <bergwolf@gmail.com>
CC: <benny@tonian.com>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 0/3] recoalesce when ld read/write fails
References: <1313197213-1651-1-git-send-email-bergwolf@gmail.com>
In-Reply-To: <1313197213-1651-1-git-send-email-bergwolf@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 08/12/2011 06:00 PM, Peng Tao wrote:
> Hi,
> 
> I have moved the error handling inside mds_ops->rpc_release to reuse code
> as suggested by Boaz.
> 
> I think we still need to issue the IO even for write because
> we don't know if current writeback is the last one. So if we re-dirty the
> pages and this is the last flush (flush at file close), then we don't have
> a later flusher to writeback the re-dirtied pages. Boaz, please help see if
> current approach is OK. Thanks.
> 
> The two cleanup patches (pipe upcall and set_lo_fail) are seperated out of
> this patchset so they can be merged more easily.
> 
> Thanks,
> Tao
> 

Thanks Tao

They look *really* good these patches. But as you said, do they actually work?

Did you test any of this? I mean do you have a facility to inject random
IO errors and test this out?

At the time I had the most dumb patch that would simply start failing IO after
n writes/reads. Or another one that: if the offset was a magic offset like
0x10017 then the IO would fail. Then with a simple dd I could make the IO
fail and test this out. (Which BTW never worked with pnfs)

The Kernel might be more resilient then we think with regarding to waiting
for clean pages. Because I know that in a UML it is very easy to get to
a low-memory condition where the iscsi stack starts to throw OOM messages
and everything stalls for a while. But I'm always surprised how eventually
the Kernel picks up and the IO ends successfully. One easy way to do this
is with a "git clone linux" with a machine that has a fast (iscsi) disk but
only 256M of memory.

I will only have time to test all this at end of next week at the earliest.
So thanks again for looking into this

Boaz

> Peng Tao (3):
>   pNFS: recoalesce when ld write pagelist fails
>   pNFS: recoalesce when ld read pagelist fails
>   pNFS: introduce pnfs private workqueue
> 
>  fs/nfs/blocklayout/blocklayout.c |   17 +++++--
>  fs/nfs/objlayout/objio_osd.c     |    8 +++
>  fs/nfs/objlayout/objlayout.c     |    4 +-
>  fs/nfs/pnfs.c                    |   92 +++++++++++++++++++++++++++-----------
>  fs/nfs/pnfs.h                    |    8 +++-
>  fs/nfs/read.c                    |   13 +++++-
>  fs/nfs/write.c                   |   25 ++++++++++-
>  7 files changed, 129 insertions(+), 38 deletions(-)
> 

