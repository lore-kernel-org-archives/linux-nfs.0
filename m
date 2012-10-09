Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:53760 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754652Ab2JISpG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Oct 2012 14:45:06 -0400
Message-ID: <507470AB.8030900@panasas.com>
Date: Tue, 9 Oct 2012 11:44:59 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Peng Tao <bergwolf@gmail.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        linuxnfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH-Resend] NFS41: layoutget optimize and pnfsblock cleanup
References: <CA+a=Yy5+i+z++XHkKkyFav1nE9pdccwUpz2=GW2J1GDRseR8jA@mail.gmail.com>
In-Reply-To: <CA+a=Yy5+i+z++XHkKkyFav1nE9pdccwUpz2=GW2J1GDRseR8jA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/07/2012 02:59 PM, Peng Tao wrote:
> Hi Trond,
> 
> Following first three patches were sent before and optimize layoutget size.
> Last patch is cleanup and is also sent before.
> 
> Sorry that I have to send patches as attachments. I am having problem
> with my smtp setup.
> 
> Thanks,
> Tao
> 

Tao hi.

What are these patches based on? they do not apply to Linus tree as of today
(v3.6-9228-g547b1e8) and they do not apply to v3.6 nor v3.5 tags.

I get a conflict on the first patch:
	NFS: track direct IO left bytes

(Do you have a public git tree with these on? Why don't you ask for a git tree
 on git.linux-nfs.org. Trond who should we ask for an hosting on git.linux-nfs.org)

Thanks
Boaz

> Peng Tao (4):
>   NFS: track direct IO left bytes
>   NFS41: send real write size in layoutget
>   NFS41: send real read size in layoutget
>   pnfsblock: cleanup nfs4_blkdev_get
> 
>  fs/nfs/blocklayout/blocklayout.c    |   38 ++++++++++++++++++++++++++++++++--
>  fs/nfs/blocklayout/blocklayout.h    |    1 -
>  fs/nfs/blocklayout/blocklayoutdev.c |   25 ++++------------------
>  fs/nfs/direct.c                     |   12 +++++++++++
>  fs/nfs/internal.h                   |    1 +
>  fs/nfs/objlayout/objio_osd.c        |    9 +++++++-
>  fs/nfs/pnfs.c                       |   16 ++++++++++++--
>  fs/nfs/pnfs.h                       |    3 +-
>  8 files changed, 76 insertions(+), 29 deletions(-)
> 


