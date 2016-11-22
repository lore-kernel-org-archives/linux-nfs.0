Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:56934 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751028AbcKVVzq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 22 Nov 2016 16:55:46 -0500
Subject: Re: [PATCH] NFSv4.x: hide array-bounds warning
To: Arnd Bergmann <arnd@arndb.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>
References: <20161122205059.754211-1-arnd@arndb.de>
CC: <linux-nfs@vger.kernel.org>, <linux-kernel@vger.kernel.org>
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Message-ID: <138e311e-4972-5726-53c2-b4fddf2576ef@Netapp.com>
Date: Tue, 22 Nov 2016 16:53:33 -0500
MIME-Version: 1.0
In-Reply-To: <20161122205059.754211-1-arnd@arndb.de>
Content-Type: text/plain; charset="windows-1252"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, Arnd!  I'll send it for 4.9

Anna

On 11/22/2016 03:50 PM, Arnd Bergmann wrote:
> A correct bugfix introduced a harmless warning that shows up with gcc-7:
> 
> fs/nfs/callback.c: In function 'nfs_callback_up':
> fs/nfs/callback.c:214:14: error: array subscript is outside array bounds [-Werror=array-bounds]
> 
> What happens here is that the 'minorversion == 0' check tells the
> compiler that we assume minorversion can be something other than 0,
> but when CONFIG_NFS_V4_1 is disabled that would be invalid and
> result in an out-of-bounds access.
> 
> The added check for IS_ENABLED(CONFIG_NFS_V4_1) tells gcc that this
> really can't happen, which makes the code slightly smaller and also
> avoids the warning.
> 
> The bugfix that introduced the warning is marked for stable backports,
> we want this one backported to the same releases.
> 
> Fixes: 98b0f80c2396 ("NFSv4.x: Fix a refcount leak in nfs_callback_up_net")
> Cc: stable@vger.kernel.org # v3.7+
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  fs/nfs/callback.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
> index 532d8e242d4d..484bebc20bca 100644
> --- a/fs/nfs/callback.c
> +++ b/fs/nfs/callback.c
> @@ -197,7 +197,7 @@ static int nfs_callback_up_net(int minorversion, struct svc_serv *serv,
>  	}
>  
>  	ret = -EPROTONOSUPPORT;
> -	if (minorversion == 0)
> +	if (!IS_ENABLED(CONFIG_NFS_V4_1) || minorversion == 0)
>  		ret = nfs4_callback_up_net(serv, net);
>  	else if (xprt->ops->bc_up)
>  		ret = xprt->ops->bc_up(serv, net);
> 
