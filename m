Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:52162 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753910Ab1GFPdZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Jul 2011 11:33:25 -0400
Date: Wed, 6 Jul 2011 11:33:24 -0400
To: Michal Schmidt <mschmidt@redhat.com>
Cc: linux-nfs@vger.kernel.org, Trond Myklebust <trond@netapp.com>
Subject: Re: [PATCH] sunrpc: add MODULE_ALIAS to match the filesystem name
Message-ID: <20110706153324.GA30349@fieldses.org>
References: <20110701224712.12393.10369.stgit@localhost6.localdomain6>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110701224712.12393.10369.stgit@localhost6.localdomain6>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, Jul 02, 2011 at 12:47:12AM +0200, Michal Schmidt wrote:
> sunrpc implements the rpc_pipefs filesystem type.
> Add the alias to have the module requested automatically by the kernel
> when the filesystem is mounted.

Makes sense to me.--b.

> 
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
> ---
> 
>  net/sunrpc/rpc_pipe.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
> index 72bc536..c1d1996 100644
> --- a/net/sunrpc/rpc_pipe.c
> +++ b/net/sunrpc/rpc_pipe.c
> @@ -1084,3 +1084,6 @@ void unregister_rpc_pipefs(void)
>  	kmem_cache_destroy(rpc_inode_cachep);
>  	unregister_filesystem(&rpc_pipe_fs_type);
>  }
> +
> +/* Make 'mount -t rpc_pipefs ...' autoload this module. */
> +MODULE_ALIAS("rpc_pipefs");
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
