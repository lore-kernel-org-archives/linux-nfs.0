Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55791 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750806Ab1JTLwZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Oct 2011 07:52:25 -0400
Date: Thu, 20 Oct 2011 07:52:24 -0400
To: Benny Halevy <benny@tonian.com>
Cc: " J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        Benny Halevy <bhalevy@tonian.com>
Subject: Re: [PATCH 5/7] nfsd4: implement NFS4_SHARE_WANT_NO_DELEG,
 NFS4_OPEN_DELEGATE_NONE_EXT
Message-ID: <20111020115224.GH5444@fieldses.org>
References: <4E9F82FC.2000904@tonian.com>
 <1319076801-13474-1-git-send-email-benny@tonian.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1319076801-13474-1-git-send-email-benny@tonian.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 19, 2011 at 07:13:21PM -0700, Benny Halevy wrote:
> From: Benny Halevy <bhalevy@tonian.com>
> 
> Respect client request for not getting a delegation in NFSv4.1
> Appropriately return delegation "type" NFS4_OPEN_DELEGATE_NONE_EXT
> and WND4_NOT_WANTED reason.

As I read it, if we're going to implement part of this, then we have to
implement all of it.  ("If the server supports the new _WANT_ flags and
the client sends one or more of the new flags, then in the event the
server does not return a delegation, it MUST return a delegation type of
OPEN_DELEGATE_NONE_EXT.  The field ond_why in the reply indicates why no
delegation was returned and will be one of....")

As long as we don't implement any want flags, we escape that MUST.

So I'd rather put this aside till it's more complete.

--b.

> 
> Signed-off-by: Benny Halevy <bhalevy@tonian.com>
> ---
>  fs/nfsd/nfs4state.c  |   10 ++++++++--
>  fs/nfsd/nfs4xdr.c    |    3 +++
>  include/linux/nfs4.h |   15 ++++++++++++++-
>  3 files changed, 25 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index ec361bb..5c3377c 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -2931,15 +2931,21 @@ static int nfs4_set_delegation(struct nfs4_delegation *dp, int flag)
>  	update_stateid(&stp->st_stid.sc_stateid);
>  	memcpy(&open->op_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
>  
> -	if (nfsd4_has_session(&resp->cstate))
> +	if (nfsd4_has_session(&resp->cstate)) {
>  		open->op_openowner->oo_flags |= NFS4_OO_CONFIRMED;
>  
> +		if (open->op_share_access & NFS4_SHARE_WANT_NO_DELEG) {
> +			open->op_delegate_type = NFS4_OPEN_DELEGATE_NONE_EXT;
> +			goto nodeleg;
> +		}
> +	}
> +
>  	/*
>  	* Attempt to hand out a delegation. No error return, because the
>  	* OPEN succeeds even if we fail.
>  	*/
>  	nfs4_open_delegation(current_fh, open, stp);
> -
> +nodeleg:
>  	status = nfs_ok;
>  
>  	dprintk("%s: stateid=" STATEID_FMT "\n", __func__,
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 706ada1..1a419c0 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -2842,6 +2842,9 @@ static __be32 nfsd4_encode_bind_conn_to_session(struct nfsd4_compoundres *resp,
>  		WRITE32(0);   /* XXX: is NULL principal ok? */
>  		ADJUST_ARGS();
>  		break;
> +	case NFS4_OPEN_DELEGATE_NONE_EXT: /* 4.1 */
> +		WRITE32(WND4_NOT_WANTED);	/* only reason for now */
> +		break;
>  	default:
>  		BUG();
>  	}
> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
> index 32345c2..8cdde4d 100644
> --- a/include/linux/nfs4.h
> +++ b/include/linux/nfs4.h
> @@ -441,7 +441,20 @@ enum limit_by4 {
>  enum open_delegation_type4 {
>  	NFS4_OPEN_DELEGATE_NONE = 0,
>  	NFS4_OPEN_DELEGATE_READ = 1,
> -	NFS4_OPEN_DELEGATE_WRITE = 2
> +	NFS4_OPEN_DELEGATE_WRITE = 2,
> +	NFS4_OPEN_DELEGATE_NONE_EXT = 3, /* 4.1 */
> +};
> +
> +enum why_no_delegation4 { /* new to v4.1 */
> +	WND4_NOT_WANTED = 0,
> +	WND4_CONTENTION = 1,
> +	WND4_RESOURCE = 2,
> +	WND4_NOT_SUPP_FTYPE = 3,
> +	WND4_WRITE_DELEG_NOT_SUPP_FTYPE = 4,
> +	WND4_NOT_SUPP_UPGRADE = 5,
> +	WND4_NOT_SUPP_DOWNGRADE = 6,
> +	WND4_CANCELLED = 7,
> +	WND4_IS_DIR = 8,
>  };
>  
>  enum lock_type4 {
> -- 
> 1.7.6
> 
