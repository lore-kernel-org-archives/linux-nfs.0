From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 1/2] nfs41: Move initialization of nfs4_opendata
 seq_res to nfs4_init_opendata_res
Date: Sat, 20 Jun 2009 14:52:41 -0400
Message-ID: <1245523961.5182.6.camel@heimdal.trondhjem.org>
References: <1245376884-3711-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:44323 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759993AbZFTSwl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 20 Jun 2009 14:52:41 -0400
In-Reply-To: <1245376884-3711-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2009-06-18 at 22:01 -0400, Benny Halevy wrote:
> nfs4_open_recover_helper clears opendata->o_res
> before calling nfs4_init_opendata_res, thus causing
> NFSv4.0 OPEN operations to be sent rather than nfsv4.1.
> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
> Trond, please add these two patches to the nfs41-for-2.6.31 series.
> Also availble on git://linux-nfs.org/~bhalevy/linux-pnfs.git nfs41-for-2.6.31
> 
>  fs/nfs/nfs4proc.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 57dabb8..04da834 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -680,6 +680,7 @@ static void nfs4_init_opendata_res(struct nfs4_opendata *p)
>  	p->o_res.server = p->o_arg.server;
>  	nfs_fattr_init(&p->f_attr);
>  	nfs_fattr_init(&p->dir_attr);
> +	p->o_res.seq_res.sr_slotid = NFS4_MAX_SLOT_TABLE;

This really needs cleaning up. The "magic sr_slotid value"
initialisation is littering the code, and you have to look _very_
carefully in order to figure out what NFS4_MAX_SLOT_TABLE actually
means.

I'm applying this patch for now, but come 2.6.32, I do expect a
changeset that gets rid of the sr_slotid magic value in favour of
something that documents what it is for.

>  }
>  
>  static struct nfs4_opendata *nfs4_opendata_alloc(struct path *path,
> @@ -711,7 +712,6 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct path *path,
>  	p->o_arg.server = server;
>  	p->o_arg.bitmask = server->attr_bitmask;
>  	p->o_arg.claim = NFS4_OPEN_CLAIM_NULL;
> -	p->o_res.seq_res.sr_slotid = NFS4_MAX_SLOT_TABLE;
>  	if (flags & O_EXCL) {
>  		u32 *s = (u32 *) p->o_arg.u.verifier.data;
>  		s[0] = jiffies;

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
