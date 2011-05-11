Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:37602 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750761Ab1EKSEI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 May 2011 14:04:08 -0400
Received: from svlrsexc2-prd.hq.netapp.com (svlrsexc2-prd.hq.netapp.com [10.57.115.31])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id p4BI48XY012833
	for <linux-nfs@vger.kernel.org>; Wed, 11 May 2011 11:04:08 -0700 (PDT)
Subject: Re: [PATCH 1/1] NFSv4.1: remove pnfs_layout_hdr from
 pnfs_destroy_all_layouts tmp_list
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: andros@netapp.com
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <1305075245-27123-1-git-send-email-andros@netapp.com>
References: <1305075245-27123-1-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 11 May 2011 14:04:04 -0400
Message-ID: <1305137044.5660.6.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2011-05-10 at 20:54 -0400, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Prevents an infinite loop as list was never emptied.
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/pnfs.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index ff681ab..7626369 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -383,6 +383,7 @@ pnfs_destroy_all_layouts(struct nfs_client *clp)
>  				plh_layouts);
>  		dprintk("%s freeing layout for inode %lu\n", __func__,
>  			lo->plh_inode->i_ino);
> +		list_del(&lo->plh_layouts);
>  		pnfs_destroy_layout(NFS_I(lo->plh_inode));
>  	}
>  }

Shouldn't that be list_del_init()?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

