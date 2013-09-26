Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:18713 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754390Ab3IZWBw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Sep 2013 18:01:52 -0400
Date: Thu, 26 Sep 2013 18:01:43 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Benny Halevy <bhalevy@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC v0 04/49] pnfsd: don't set up back channel on
 create_session for ds
Message-ID: <20130926220142.GC24894@pad.fieldses.org>
References: <52447EA0.7070004@primarydata.com>
 <1380220807-12857-1-git-send-email-bhalevy@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1380220807-12857-1-git-send-email-bhalevy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 26, 2013 at 02:40:07PM -0400, Benny Halevy wrote:
> From: Dean Hildebrand <seattleplus@gmail.com>

I don't understand why we need to do this.

Also: based on the previous patch I believe we set the
EXCHGID4_FLAG_USE_PNFS_MDS bit in the reply unconditionally, so
regardless of what the client requests we're permitting it to use this
client as a MDS (or plain non-pnfs) server, so I'm not sure it matters
what the client requested.

Could you just drop this patch?  Unless you have some good argument for
it.

--b.

> 
> [was pnfsd: Add use of pnfs exchange flags]
> Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
> [pnfsd: define a is_ds_only_session helper]
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
> ---
>  fs/nfsd/nfs4state.c       | 4 ++++
>  include/uapi/linux/nfs4.h | 7 +++++++
>  2 files changed, 11 insertions(+)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 21c15fc..2c973e6 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1953,6 +1953,10 @@ static __be32 nfsd4_check_cb_sec(struct nfsd4_cb_sec *cbs)
>  			status = nfserr_seq_misordered;
>  			goto out_free_conn;
>  		}
> +
> +		if (is_ds_only_session(unconf->cl_exchange_flags))
> +			cr_ses->flags &= ~SESSION4_BACK_CHAN;
> +
>  		old = find_confirmed_client_by_name(&unconf->cl_name, nn);
>  		if (old) {
>  			status = mark_client_expired(old);
> diff --git a/include/uapi/linux/nfs4.h b/include/uapi/linux/nfs4.h
> index 788128e..028f5fc 100644
> --- a/include/uapi/linux/nfs4.h
> +++ b/include/uapi/linux/nfs4.h
> @@ -125,6 +125,13 @@
>  #define EXCHGID4_FLAG_USE_PNFS_DS		0x00040000
>  #define EXCHGID4_FLAG_MASK_PNFS			0x00070000
>  
> +static inline bool
> +is_ds_only_session(u32 exchange_flags)
> +{
> +	u32 mask = EXCHGID4_FLAG_USE_PNFS_DS | EXCHGID4_FLAG_USE_PNFS_MDS;
> +	return (exchange_flags & mask) == EXCHGID4_FLAG_USE_PNFS_DS;
> +}
> +
>  #define EXCHGID4_FLAG_UPD_CONFIRMED_REC_A	0x40000000
>  #define EXCHGID4_FLAG_CONFIRMED_R		0x80000000
>  /*
> -- 
> 1.8.3.1
> 
