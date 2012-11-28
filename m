Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47400 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932301Ab2K1PMZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Nov 2012 10:12:25 -0500
Date: Wed, 28 Nov 2012 10:12:23 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, devel@openvz.org
Subject: Re: [PATCH] nfsd: remove redundant declarations
Message-ID: <20121128151223.GH11651@fieldses.org>
References: <20121127114220.13915.21738.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121127114220.13915.21738.stgit@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 27, 2012 at 02:42:20PM +0300, Stanislav Kinsbursky wrote:
> This is a cleanup patch. Functions nfsd_pool_stats_open() and
> nfsd_pool_stats_release() are declared in fs/nfsd/nfsd.h.

OK, applying.

--b.

> 
> Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
> ---
>  fs/nfsd/nfsctl.c |    3 ---
>  1 files changed, 0 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> index 7e41bd1..d902f83 100644
> --- a/fs/nfsd/nfsctl.c
> +++ b/fs/nfsd/nfsctl.c
> @@ -186,9 +186,6 @@ static struct file_operations supported_enctypes_ops = {
>  };
>  #endif /* CONFIG_SUNRPC_GSS or CONFIG_SUNRPC_GSS_MODULE */
>  
> -extern int nfsd_pool_stats_open(struct inode *inode, struct file *file);
> -extern int nfsd_pool_stats_release(struct inode *inode, struct file *file);
> -
>  static const struct file_operations pool_stats_operations = {
>  	.open		= nfsd_pool_stats_open,
>  	.read		= seq_read,
> 
