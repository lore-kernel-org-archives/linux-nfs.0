Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:64397 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932539Ab3CUOdx convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Mar 2013 10:33:53 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: Benny Halevy <bhalevy@tonian.com>, Boaz Harrosh <bharrosh@panasas.com>,
        Peng Tao <bergwolf@gmail.com>
Subject: Re: [PATCH v2 2/3] NFSv4.1: Always clear the NFS_INO_LAYOUTCOMMIT
 in layoutreturn
Date: Thu, 21 Mar 2013 14:33:36 +0000
Message-ID: <1363876416.3557.11.camel@leira.trondhjem.org>
References: <1363875181-7147-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1363875181-7147-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1363875181-7147-2-git-send-email-Trond.Myklebust@netapp.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-03-21 at 10:13 -0400, Trond Myklebust wrote:
> Note that clearing NFS_INO_LAYOUTCOMMIT is tricky, since it requires
> you to also clear the NFS_LSEG_LAYOUTCOMMIT bits from the layout
> segments.
> The only two sites that need to do this are the ones that call
> pnfs_return_layout() without first doing a layout commit.
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> Acked-by: Benny Halevy <bhalevy@tonian.com>
> Cc: stable@vger.kernel.org
> ---
>  fs/nfs/nfs4filelayout.c |  1 -
>  fs/nfs/pnfs.c           | 35 +++++++++++++++++++++++++++--------
>  2 files changed, 27 insertions(+), 9 deletions(-)
> 
> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
> index 49eeb04..4fb234d 100644
> --- a/fs/nfs/nfs4filelayout.c
> +++ b/fs/nfs/nfs4filelayout.c
> @@ -129,7 +129,6 @@ static void filelayout_fenceme(struct inode *inode, struct pnfs_layout_hdr *lo)
>  {
>  	if (!test_and_clear_bit(NFS_LAYOUT_RETURN, &lo->plh_flags))
>  		return;
> -	clear_bit(NFS_INO_LAYOUTCOMMIT, &NFS_I(inode)->flags);
>  	pnfs_return_layout(inode);
>  }
>  
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index c6bbb53..b9d0682 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -417,6 +417,16 @@ should_free_lseg(struct pnfs_layout_range *lseg_range,
>  	       lo_seg_intersecting(lseg_range, recall_range);
>  }
>  
> +static bool lseg_dec_and_remove_zero(struct pnfs_layout_segment *lseg,

I'm adding a 'pnfs' prefix for looks...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
