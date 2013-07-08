Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:59953 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752975Ab3GHUQq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Jul 2013 16:16:46 -0400
Date: Mon, 8 Jul 2013 16:16:43 -0400
To: Jan Stancek <jstancek@redhat.com>
Cc: linux-nfs@vger.kernel.org, bfields@redhat.com, Trond.Myklebust@netapp.com
Subject: Re: [PATCH] NFS: fix NFSv3 with sec=krb5 and CONFIG_NFS_V3_ACL=y
Message-ID: <20130708201643.GI29071@fieldses.org>
References: <682ebd8ecc7309b18396da356a0feb38bfa41674.1372692346.git.jstancek@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <682ebd8ecc7309b18396da356a0feb38bfa41674.1372692346.git.jstancek@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 01, 2013 at 05:32:34PM +0200, Jan Stancek wrote:
> Starting with commit:
>   commit f994c43d19a9116727d4c228d3f13db595bff562
>   Author: Trond Myklebust <Trond.Myklebust@netapp.com>
>   Date:   Thu Nov 1 12:14:14 2012 -0400
>       SUNRPC: Clean up rpc_bind_new_program
> 
> operations on directory mounted with -onfsvers=3,tcp,sec=krb5 fail
> with Input/Output error after ~60 second timeout. This is presumably
> because upcalls for 'nfsacl' are not getting anywhere.
> 
> This patch enables pipe dir for nfsacl_program and changes its name
> to 'nfs'. This name will be used in upcalls and whole setup should
> work as it did in past - just with nfs/hostname principal.

I think this was the problem that nfs-utils commits

	a1f8afc560 gssd: Remove insane sanity checks of the service name
	a56989b665 gssd: Handle the target name correctly

were supposed to fix?

But perhaps the kernel needs a fix too to fix a regression with old
userspace.

--b.

> 
> Signed-off-by: Jan Stancek <jstancek@redhat.com>
> ---
>  fs/nfs/nfs3client.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/nfs3client.c b/fs/nfs/nfs3client.c
> index b3fc65e..09a7d06 100644
> --- a/fs/nfs/nfs3client.c
> +++ b/fs/nfs/nfs3client.c
> @@ -9,11 +9,12 @@ static const struct rpc_version *nfsacl_version[] = {
>  };
>  
>  const struct rpc_program nfsacl_program = {
> -	.name			= "nfsacl",
> +	.name			= "nfs",
>  	.number			= NFS_ACL_PROGRAM,
>  	.nrvers			= ARRAY_SIZE(nfsacl_version),
>  	.version		= nfsacl_version,
>  	.stats			= &nfsacl_rpcstat,
> +	.pipe_dir_name		= NFS_PIPE_DIRNAME,
>  };
>  
>  /*
> -- 
> 1.7.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
