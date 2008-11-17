From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [RFC 15/85] nfs41: Proper initialization of	nfs_client_initdata.rpc_ops
Date: Mon, 17 Nov 2008 15:41:57 +0200
Message-ID: <492174A5.5040207@panasas.com>
References: <4918920E.3030301@panasas.com> <1226348427-7684-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: trond.myklebust@fys.uio.no, linux-nfs@vger.kernel.org
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([66.104.249.162]:5282 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751439AbYKQNmB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Nov 2008 08:42:01 -0500
In-Reply-To: <1226348427-7684-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov. 10, 2008, 22:20 +0200, Benny Halevy <bhalevy@panasas.com> wrote:
> From: Ricardo Labiaga <ricardo.labiaga@netapp.com>
> 
> The rpc_ops needs to be initialized to the proper minor version clientops
> so that nfs_get_client() can find an existing nfs_client structure if
> a mount to the same server has already occurred.
> 
> This enables the traditional sharing of nfs_client structures, as well
> as fixes the problem where mounts of the same filesystem on the same
> mountpoint were not being detected correctly.
> 
> Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>

review 11-14: see if we can get rid of that since right now
nfs_v41_clientops == nfs_v40_clientops

> ---
>  fs/nfs/client.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index 4e8c641..11c845d 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -1028,6 +1028,8 @@ static int nfs4_set_client(struct nfs_server *server,
>  		.hostname = hostname,
>  		.addr = addr,
>  		.addrlen = addrlen,
> +		.rpc_ops =
> +			nfsv4_minorversion_clientops[server->minorversion],
>  		.proto = proto,
>  	};
>  	struct nfs_client *clp;
