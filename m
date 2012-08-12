Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:52139 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750852Ab2HLRlA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 12 Aug 2012 13:41:00 -0400
Message-ID: <5027EA48.2050707@panasas.com>
Date: Sun, 12 Aug 2012 20:39:20 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Peng Tao <bergwolf@gmail.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH RFC 3/3] NFS41: send real read size in layoutget for DIO
References: <1344391392-1948-1-git-send-email-bergwolf@gmail.com> <1344391392-1948-4-git-send-email-bergwolf@gmail.com> <1344452224.8925.30.camel@lade.trondhjem.org> <CA+a=Yy4G7cBmSU-sDXZ7=cb3Qkfr1n7MzSp3mKdK_UYSZ6iKng@mail.gmail.com>
In-Reply-To: <CA+a=Yy4G7cBmSU-sDXZ7=cb3Qkfr1n7MzSp3mKdK_UYSZ6iKng@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/09/2012 05:30 AM, Peng Tao wrote:

> On Thu, Aug 9, 2012 at 2:57 AM, Myklebust, Trond
> <Trond.Myklebust@netapp.com> wrote:
>> On Wed, 2012-08-08 at 10:03 +0800, Peng Tao wrote:
>>> From: Peng Tao <tao.peng@emc.com>
>>>
>>> We don't have the real IO size information in buffer read, but for direct
>>> read, we can get it from dreq->bytes_left. Let's make use of it.
>>
>> What's wrong with using the nfs_readpages arguments? The readahead code
>> will tell you exactly how many pages it is trying to read.
>>
> The nr_pages information gets dropped before calling into pnfs code...
> 
> How about something like bellow for buffer reads? (untested patch and
> needs to integrate with DIO size for sure).
> 
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 2e00fea..cec79c2 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -1162,7 +1162,7 @@ pnfs_generic_pg_init_read(struct
> nfs_pageio_descriptor *pgio, struct nfs_page *r
>  	pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
>  					   req->wb_context,
>  					   req_offset(req),
> -					   req->wb_bytes,
> +					   (unsigned)pgio->pg_layout_private,
>  					   IOMODE_READ,
>  					   GFP_KERNEL);
>  	/* If no lseg, fall back to read through mds */
> diff --git a/fs/nfs/read.c b/fs/nfs/read.c
> index b6bdb18..64fb0e2 100644
> --- a/fs/nfs/read.c
> +++ b/fs/nfs/read.c
> @@ -649,6 +649,7 @@ int nfs_readpages(struct file *filp, struct
> address_space *mapping,
> 
>  	NFS_PROTO(inode)->read_pageio_init(&pgio, inode,
> &nfs_async_read_completion_ops);
> 
> +	pgio.pg_layout_private = (void *)nr_pages;


NACK!!! pgio.pg_layout_private is for use by LD only. Generic code should
never touch it. If you actually need it and this info is realy lost please
use a new member.

>  	ret = read_cache_pages(mapping, pages, readpage_async_filler, &desc);
> 
>  	nfs_pageio_complete(&pgio);
> 
> 


For reads, for both files and objects but I think also for blocks the optimum
size is just offset-to-i_size. I do not see any resource constrained at server.
If the extent list gets to big to be sent as one RPC for blocks layout, (as can be the
case for objects when spanning groups) The server can just send the biggest chunk it wants,
that fits. Or consider some other optimum max size according to internal topology
knowledge.

The server may always send a smaller layout as long as it includes "offset". If so the client
will return for the reminder. I test this al the time it works perfectly.

Actually for exofs regardless of requested size I always return a group_size full
for read-layouts of the group that includes "offset".
Only write-layouts need be sliced thin in exofs.

Boaz
