From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [RFC 49/85] nfs41: recover lease in _nfs4_lookup_root
Date: Mon, 17 Nov 2008 15:51:21 +0200
Message-ID: <492176D9.8030409@panasas.com>
References: <4918920E.3030301@panasas.com> <1226348809-8861-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: trond.myklebust@fys.uio.no, linux-nfs@vger.kernel.org
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([66.104.249.162]:10547 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752020AbYKQNvY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Nov 2008 08:51:24 -0500
In-Reply-To: <1226348809-8861-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov. 10, 2008, 22:26 +0200, Benny Halevy <bhalevy@panasas.com> wrote:
> This creates the nfsv4.1 session on mount.
> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfs/nfs4proc.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 749027d..179ea6c 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -1956,7 +1956,11 @@ static int _nfs4_lookup_root(struct nfs_server *server, struct nfs_fh *fhandle,
>  
>  	dprintk("--> %s\n", __func__);
>  	nfs_fattr_init(info->fattr);
> +	status = nfs4_recover_expired_lease(server);
> +	if (status != 0)
> +		goto out;

review 11-14: do that *only* for minorversion != 0

>  	status = nfs4_call_sync(server, &msg, &args, &res, 0);
> +out:
>  	dprintk("<-- %s status= %d\n", __func__, status);
>  	return status;
>  }
