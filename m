Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx141.netapp.com ([216.240.21.12]:11869 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750719AbbANNkb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Jan 2015 08:40:31 -0500
Message-ID: <54B671C6.7060306@Netapp.com>
Date: Wed, 14 Jan 2015 08:40:22 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Tom Haynes <thomas.haynes@primarydata.com>
CC: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 42/49] nfs41: add range to layoutreturn args
References: <1420590534-84063-1-git-send-email-loghyr@primarydata.com> <1420590534-84063-43-git-send-email-loghyr@primarydata.com> <54B56EB8.2060703@Netapp.com> <20150113194245.GB90833@kitty> <54B5774D.7030907@Netapp.com> <20150113225042.GE90833@kitty>
In-Reply-To: <20150113225042.GE90833@kitty>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/13/2015 05:50 PM, Tom Haynes wrote:
> On Tue, Jan 13, 2015 at 02:51:41PM -0500, Anna Schumaker wrote:
>> I still think we should hold off until partial file returns are added, making it less likely that somebody will introduce a bug in the meantime.
>>
> 
> Can you live with this:

Yes, I like that much better!  Thanks!

Anna

> 
>  fs/nfs/nfs4xdr.c        | 6 +++---
>  fs/nfs/pnfs.c           | 4 +++-
>  include/linux/nfs_xdr.h | 2 +-
>  3 files changed, 7 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index 3c3ff63..56d4c91 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -2012,11 +2012,11 @@ encode_layoutreturn(struct xdr_stream *xdr,
>         p = reserve_space(xdr, 16);
>         *p++ = cpu_to_be32(0);          /* reclaim. always 0 for now */
>         *p++ = cpu_to_be32(args->layout_type);
> -       *p++ = cpu_to_be32(args->iomode);
> +       *p++ = cpu_to_be32(args->range.iomode);
>         *p = cpu_to_be32(RETURN_FILE);
>         p = reserve_space(xdr, 16);
> -       p = xdr_encode_hyper(p, 0);
> -       p = xdr_encode_hyper(p, NFS4_MAX_UINT64);
> +       p = xdr_encode_hyper(p, args->range.offset);
> +       p = xdr_encode_hyper(p, args->range.length);
>         spin_lock(&args->inode->i_lock);
>         encode_nfs4_stateid(xdr, &args->stateid);
>         spin_unlock(&args->inode->i_lock);
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 685af4f..9549b89 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -916,7 +916,9 @@ pnfs_send_layoutreturn(struct pnfs_layout_hdr *lo, nfs4_stateid stateid,
>         lrp->args.stateid = stateid;
>         lrp->args.layout_type = NFS_SERVER(ino)->pnfs_curr_ld->id;
>         lrp->args.inode = ino;
> -       lrp->args.iomode = iomode;
> +       lrp->args.range.iomode = iomode;
> +       lrp->args.range.offset = 0;
> +       lrp->args.range.length = NFS4_MAX_UINT64;
>         lrp->args.layout = lo;
>         lrp->clp = NFS_SERVER(ino)->nfs_client;
>         lrp->cred = lo->plh_lc_cred;
> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
> index 6400a1e..3637923 100644
> --- a/include/linux/nfs_xdr.h
> +++ b/include/linux/nfs_xdr.h
> @@ -293,7 +293,7 @@ struct nfs4_layoutreturn_args {
>         struct nfs4_sequence_args seq_args;
>         struct pnfs_layout_hdr *layout;
>         struct inode *inode;
> -       enum pnfs_iomode iomode;
> +       struct pnfs_layout_range range;
>         nfs4_stateid stateid;
>         __u32   layout_type;
>  };
> 

