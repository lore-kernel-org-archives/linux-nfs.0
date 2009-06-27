From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [PATCH]pnfsd: make pnfs server return layout_blksize when
 the client asks for it
Date: Sat, 27 Jun 2009 18:53:29 +0300
Message-ID: <4A464079.3090805@panasas.com>
References: <318b7ac70906252004q61cfd571h1788e8fb448c46f5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: bfields@citi.umich.edu, linux-nfs@vger.kernel.org,
	pnfs@linux-nfs.org
To: Tao Guo <glorioustao@gmail.com>,
	Fredric Isaman <iisaman@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:7018
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753240AbZF0Pxe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Jun 2009 11:53:34 -0400
In-Reply-To: <318b7ac70906252004q61cfd571h1788e8fb448c46f5-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Tao,

I'd appreciate if you could send patches in plain text, otherwise
they are much harder to apply.

Fred: can you please verify this in your environment since I think that
only the block layout relies on that at the moment.

Please see comments below.

On Jun. 26, 2009, 6:04 +0300, Tao Guo <glorioustao@gmail.com> wrote:
> commit 717f53b333a8c4c5238b1192640ad5078c683f5f
> Author: Tao Guo <guotao-U4AKAne5IzAR5TUyvShJeg@public.gmane.org <mailto:guotao-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>>
> Date:   Fri Jun 26 10:46:13 2009 +0800
> 
>     pnfsd: make pnfs server return layout_blksize when the client asks
> for it.
>    
>     pnfs: replace lease_bitmap to length 3, instead of 2.
>    
>     Referred to commit 3e8c8312e4b...
> 
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index 95b7387..f264c15 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -2573,7 +2573,7 @@ static int nfs4_xdr_enc_setclientid_confirm(struct
> rpc_rqst *req, __be32 *p, str
>      struct compound_hdr hdr = {
>          .nops    = 0,
>      };
> -    const u32 lease_bitmap[2] = { FATTR4_WORD0_LEASE_TIME, 0 };
> +    const u32 lease_bitmap[3] = { FATTR4_WORD0_LEASE_TIME, 0, 0 };
>  
>      xdr_init_encode(&xdr, &req->rq_snd_buf, p);
>      encode_compound_hdr(&xdr, req, &hdr);

a. same should also be done in nfs4_xdr_enc_get_lease_time
b. please submit as separate patch as it fixes a bug independently.

> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 6959787..2854576 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -2345,6 +2345,13 @@ out_acl:
>              WRITE32(0);  /* length */
>      }
>  #endif /* CONFIG_PNFSD */
> +
> +    if (bmval2 & FATTR4_WORD2_LAYOUT_BLKSIZE) {
> +        if ((buflen -= 4) < 0)
> +            goto out_resource;
> +        WRITE32(stat.blksize);
> +    }
> +

let's put this inside the #ifdef CONFIG_PNFSD block for now.
I'm not 100% sure about returning stat.blksize for the layout_blksize
but that will do for now.

Thanks!

Benny

>      if (bmval2 & FATTR4_WORD2_SUPPATTR_EXCLCREAT) {
>          WRITE32(3);
>          WRITE32(NFSD_SUPPATTR_EXCLCREAT_WORD0);
> diff --git a/include/linux/nfsd/nfsd.h b/include/linux/nfsd/nfsd.h
> index 5177c54..056e012 100644
> --- a/include/linux/nfsd/nfsd.h
> +++ b/include/linux/nfsd/nfsd.h
> @@ -382,7 +382,8 @@ extern struct timeval    nfssvc_boot;
>  #endif /* CONFIG_PNFSD */
>  
>  #define NFSD4_1_SUPPORTED_ATTRS_WORD2 \
> -    (NFSD4_SUPPORTED_ATTRS_WORD2 | FATTR4_WORD2_SUPPATTR_EXCLCREAT)
> +    (NFSD4_SUPPORTED_ATTRS_WORD2 | FATTR4_WORD2_SUPPATTR_EXCLCREAT | \
> +     FATTR4_WORD2_LAYOUT_BLKSIZE)
>  
>  static inline u32 nfsd_suppattrs0(u32 minorversion)
>  {
> -- 
> tao.
> 
> 
> ------------------------------------------------------------------------
> 
> _______________________________________________
> pNFS mailing list
> pNFS@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs
