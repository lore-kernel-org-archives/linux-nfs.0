From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] nfsd: declare several functions of nfs4callback as
 static
Date: Sat, 1 Jan 2011 16:21:10 -0500
Message-ID: <20110101212110.GA23699@fieldses.org>
References: <1292505954-26290-1-git-send-email-kirill@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Kirill A. Shutsemov" <kirill@shutemov.name>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1292505954-26290-1-git-send-email-kirill@shutemov.name>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 16, 2010 at 03:25:54PM +0200, Kirill A. Shutsemov wrote:
> From: Kirill A. Shutemov <kirill@shutemov.name>
> 
> setup_callback_client(), nfsd4_release_cb() and nfsd4_process_cb_update()
> do not have users outside the translation unit. Let's declare it as
> static.

Thanks, applying for 2.6.38.--b.

> 
> Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
> ---
>  fs/nfsd/nfs4callback.c |    7 ++++---
>  1 files changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> index a95150d..515a9b1 100644
> --- a/fs/nfsd/nfs4callback.c
> +++ b/fs/nfsd/nfs4callback.c
> @@ -474,7 +474,8 @@ static int max_cb_time(void)
>  /* Reference counting, callback cleanup, etc., all look racy as heck.
>   * And why is cl_cb_set an atomic? */
>  
> -int setup_callback_client(struct nfs4_client *clp, struct nfs4_cb_conn *conn)
> +static int setup_callback_client(struct nfs4_client *clp,
> +		struct nfs4_cb_conn *conn)
>  {
>  	struct rpc_timeout	timeparms = {
>  		.to_initval	= max_cb_time(),
> @@ -750,13 +751,13 @@ void nfsd4_shutdown_callback(struct nfs4_client *clp)
>  	flush_workqueue(callback_wq);
>  }
>  
> -void nfsd4_release_cb(struct nfsd4_callback *cb)
> +static void nfsd4_release_cb(struct nfsd4_callback *cb)
>  {
>  	if (cb->cb_ops->rpc_release)
>  		cb->cb_ops->rpc_release(cb);
>  }
>  
> -void nfsd4_process_cb_update(struct nfsd4_callback *cb)
> +static void nfsd4_process_cb_update(struct nfsd4_callback *cb)
>  {
>  	struct nfs4_cb_conn conn;
>  	struct nfs4_client *clp = cb->cb_clp;
> -- 
> 1.7.3.3
> 
