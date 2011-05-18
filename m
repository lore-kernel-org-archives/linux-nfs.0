Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:33239 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752659Ab1ERT3C (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 May 2011 15:29:02 -0400
Date: Wed, 18 May 2011 15:29:00 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Daniel Mack <zonque@gmail.com>
Cc: linux-nfs@vger.kernel.org, Trond Myklebust <Trond.Myklebust@netapp.com>,
        Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 2/2] nfsd: make local functions static
Message-ID: <20110518192900.GA18905@fieldses.org>
References: <1305556694-6513-1-git-send-email-zonque@gmail.com>
 <1305556694-6513-2-git-send-email-zonque@gmail.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1305556694-6513-2-git-send-email-zonque@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, May 16, 2011 at 04:38:14PM +0200, Daniel Mack wrote:
> This also fixes a number of sparse warnings.

Applying for 2.6.40, thanks.

--b.

> 
> Signed-off-by: Daniel Mack <zonque@gmail.com>
> Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
> Cc: J. Bruce Fields <bfields@fieldses.org>
> Cc: Neil Brown <neilb@suse.de>
> ---
>  fs/nfsd/nfs3xdr.c   |    2 +-
>  fs/nfsd/nfs4state.c |    4 ++--
>  fs/nfsd/nfs4xdr.c   |    2 +-
>  3 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
> index ad48fac..08c6e36 100644
> --- a/fs/nfsd/nfs3xdr.c
> +++ b/fs/nfsd/nfs3xdr.c
> @@ -842,7 +842,7 @@ out:
>  	return rv;
>  }
>  
> -__be32 *encode_entryplus_baggage(struct nfsd3_readdirres *cd, __be32 *p, const char *name, int namlen)
> +static __be32 *encode_entryplus_baggage(struct nfsd3_readdirres *cd, __be32 *p, const char *name, int namlen)
>  {
>  	struct svc_fh	fh;
>  	int err;
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 4cf04e1..35f559b 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -2462,7 +2462,7 @@ find_delegation_file(struct nfs4_file *fp, stateid_t *stid)
>  	return NULL;
>  }
>  
> -int share_access_to_flags(u32 share_access)
> +static int share_access_to_flags(u32 share_access)
>  {
>  	share_access &= ~NFS4_SHARE_WANT_MASK;
>  
> @@ -2882,7 +2882,7 @@ out:
>  	return status;
>  }
>  
> -struct lock_manager nfsd4_manager = {
> +static struct lock_manager nfsd4_manager = {
>  };
>  
>  static void
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index c6766af..125b276 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -3120,7 +3120,7 @@ nfsd4_encode_destroy_session(struct nfsd4_compoundres *resp, int nfserr,
>  	return nfserr;
>  }
>  
> -__be32
> +static __be32
>  nfsd4_encode_sequence(struct nfsd4_compoundres *resp, int nfserr,
>  		      struct nfsd4_sequence *seq)
>  {
> -- 
> 1.7.5.1
> 
