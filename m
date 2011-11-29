Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:48087 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756710Ab1K2Vej (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Nov 2011 16:34:39 -0500
Message-ID: <4ED54FE4.9050008@panasas.com>
Date: Tue, 29 Nov 2011 13:34:28 -0800
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Peng Tao <bergwolf@gmail.com>
CC: <Trond.Myklebust@netapp.com>, <linux-nfs@vger.kernel.org>,
        <bhalevy@tonian.com>
Subject: Re: [PATCH 0/4] nfs41: allow layoutget at pnfs_do_multiple_writes
References: <1322887965-2938-1-git-send-email-bergwolf@gmail.com>
In-Reply-To: <1322887965-2938-1-git-send-email-bergwolf@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12/02/2011 08:52 PM, Peng Tao wrote:
> Issuing layoutget at .pg_init will drop the IO size information and ask for 4KB
> layout every time. However, the IO size information is very valuable for MDS to
> determine how much layout it should return to client.
> 
> The patchset try to allow LD not to send layoutget at .pg_init but instead at
> pnfs_do_multiple_writes. So that real IO size is preserved and sent to MDS.
> 
> Tests against a server that does not aggressively pre-allocate layout, shows
> that the IO size informantion is really useful to block layout MDS.
> 
> The generic pnfs layer changes are trival to file layout and object as long as
> they still send layoutget at .pg_init.
> 

I have a better solution for your problem. Which is a much smaller a change and
I think gives you much better heuristics.

Keep the layout_get exactly where it is, but instead of sending PAGE_SIZE send
the amount of dirty pages you have.

If it is a linear write you will be exact on the money with a single lo_get. If
it is an heavy random write then you might need more lo_gets and you might be getting
some unused segments. But heavy random write is rare and slow anyway. As a first
approximation its fine. (We can later fix that as well)

The .pg_init is done after .write_pages call from VFS and all the to-be-written
pages are already staged to be written. So there should be a way to easily extract
that information.

> iozone cmd:
> ./iozone -r 1m -s 4G -w -W -c -t 10 -i 0 -F /mnt/iozone.data.1 /mnt/iozone.data.2 /mnt/iozone.data.3 /mnt/iozone.data.4 /mnt/iozone.data.5 /mnt/iozone.data.6 /mnt/iozone.data.7 /mnt/iozone.data.8 /mnt/iozone.data.9 /mnt/iozone.data.10
> 
> Befor patch: around 12MB/s throughput
> After patch: around 72MB/s throughput
> 

Yes Yes that stupid Brain dead Server is no indication for anything. The server
should know best about optimal sizes and layouts. Please don't give me that stuff
again.

But just do the above and you'll see that it is perfect.

BTW don't limit the lo_segment size by the max_io_size. This is why you
have .bg_test to signal when IO is maxed out.

- The read segments should be as big as possible (i_size long)
- The Write segments should ideally be as big as the Application
  wants to write to. (Amount of dirty pages at time of nfs-write-out
  is a very good first approximation).

So I guess it is: I hate these patches, to much mess, too little goodness.

Thank
Boaz

> Peng Tao (4):
>   nfsv41: export pnfs_find_alloc_layout
>   nfsv41: add and export pnfs_find_get_layout_locked
>   nfsv41: get lseg before issue LD IO if pgio doesn't carry lseg
>   pnfsblock: do ask for layout in pg_init
> 
>  fs/nfs/blocklayout/blocklayout.c |   54 ++++++++++++++++++++++++++-
>  fs/nfs/pnfs.c                    |   74 +++++++++++++++++++++++++++++++++++++-
>  fs/nfs/pnfs.h                    |    9 +++++
>  3 files changed, 134 insertions(+), 3 deletions(-)
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

