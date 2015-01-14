Return-Path: linux-kernel-owner@vger.kernel.org
Date: Wed, 14 Jan 2015 16:50:57 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] nfsd: nfs4state: Remove unused function
Message-ID: <20150114215057.GA7071@fieldses.org>
References: <1421182644-8258-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1421182644-8258-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 13, 2015 at 09:57:24PM +0100, Rickard Strandqvist wrote:
> Remove the function renew_client() that is not used anywhere.
> 
> This was partially found by using a static code analysis program called cppcheck.

Huh.  OK, queueing up for 3.20.--b.

> 
> Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
> ---
>  fs/nfsd/nfs4state.c |   10 ----------
>  1 file changed, 10 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index e9c3afe..5d63c5c 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -150,16 +150,6 @@ renew_client_locked(struct nfs4_client *clp)
>  	clp->cl_time = get_seconds();
>  }
>  
> -static inline void
> -renew_client(struct nfs4_client *clp)
> -{
> -	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
> -
> -	spin_lock(&nn->client_lock);
> -	renew_client_locked(clp);
> -	spin_unlock(&nn->client_lock);
> -}
> -
>  static void put_client_renew_locked(struct nfs4_client *clp)
>  {
>  	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
> -- 
> 1.7.10.4
> 
