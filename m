Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:31711 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751568AbaIYVBX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 25 Sep 2014 17:01:23 -0400
Message-ID: <54248295.7040001@Netapp.com>
Date: Thu, 25 Sep 2014 17:01:09 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSv3: Fix missing includes of nfs3_fs.h
References: <1411678544-47748-1-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1411678544-47748-1-git-send-email-trond.myklebust@primarydata.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Looks good to me, although I'm not sure how I missed that when I submitted my patches!

Anna

On 09/25/2014 04:55 PM, Trond Myklebust wrote:
> Silence a few warnings about missing symbols that are due to missing
> includes of nfs3_fs.h.
> 
> Fixes: 00a36a1090350 (NFS: Move v3 declarations out of internal.h)
> Fixes: cb8c20fa53ec2 (NFS: Move NFS v3 acl functions to nfs3_fs.h)
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfs/nfs3acl.c    | 1 +
>  fs/nfs/nfs3client.c | 1 +
>  2 files changed, 2 insertions(+)
> 
> diff --git a/fs/nfs/nfs3acl.c b/fs/nfs/nfs3acl.c
> index 24c6898159cc..658e586ca438 100644
> --- a/fs/nfs/nfs3acl.c
> +++ b/fs/nfs/nfs3acl.c
> @@ -7,6 +7,7 @@
>  #include <linux/nfsacl.h>
>  
>  #include "internal.h"
> +#include "nfs3_fs.h"
>  
>  #define NFSDBG_FACILITY	NFSDBG_PROC
>  
> diff --git a/fs/nfs/nfs3client.c b/fs/nfs/nfs3client.c
> index b3fc65ef39ca..8c1b437c5403 100644
> --- a/fs/nfs/nfs3client.c
> +++ b/fs/nfs/nfs3client.c
> @@ -1,6 +1,7 @@
>  #include <linux/nfs_fs.h>
>  #include <linux/nfs_mount.h>
>  #include "internal.h"
> +#include "nfs3_fs.h"
>  
>  #ifdef CONFIG_NFS_V3_ACL
>  static struct rpc_stat		nfsacl_rpcstat = { &nfsacl_program };
> 

