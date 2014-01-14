Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([209.166.131.148]:39221 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751579AbaANPWj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jan 2014 10:22:39 -0500
Message-ID: <52D5562F.70701@panasas.com>
Date: Tue, 14 Jan 2014 17:22:23 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Weston Andros Adamson <dros@primarydata.com>
CC: <trond.myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>,
        Ganesha NFS List <nfs-ganesha-devel@lists.sourceforge.net>
Subject: Re: [PATCH] nfs4.1: properly handle ENOTSUP in SECINFO_NO_NAME
References: <1389650085-4128-1-git-send-email-dros@primarydata.com>
In-Reply-To: <1389650085-4128-1-git-send-email-dros@primarydata.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/13/2014 11:54 PM, Weston Andros Adamson wrote:
> Don't check for -NFS4ERR_NOTSUPP, it's already been mapped to -ENOTSUPP
> by nfs4_stat_to_errno.
> 
> This allows the client to mount v4.1 servers that don't support
> SECINFO_NO_NAME by falling back to the "guess and check" method of
> nfs4_find_root_sec.
> 
> Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
> ---
> 
> I found this trying to mount a pynfs filelayout server.
> 

Yes at last BAT Frank fixed Ganesha so it can work with new clients.

Linux client is the standard the rest of the world needs to comply 
(Resistance is futile ;-) )

Thanks
Boaz

>  fs/nfs/nfs4proc.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 15052b8..1d57b6a 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -7920,7 +7920,7 @@ nfs41_proc_secinfo_no_name(struct nfs_server *server, struct nfs_fh *fhandle,
>  		switch (err) {
>  		case 0:
>  		case -NFS4ERR_WRONGSEC:
> -		case -NFS4ERR_NOTSUPP:
> +		case -ENOTSUPP:
>  			goto out;
>  		default:
>  			err = nfs4_handle_exception(server, err, &exception);
> @@ -7954,7 +7954,7 @@ nfs41_find_root_sec(struct nfs_server *server, struct nfs_fh *fhandle,
>  	 * Fall back on "guess and check" method if
>  	 * the server doesn't support SECINFO_NO_NAME
>  	 */
> -	if (err == -NFS4ERR_WRONGSEC || err == -NFS4ERR_NOTSUPP) {
> +	if (err == -NFS4ERR_WRONGSEC || err == -ENOTSUPP) {
>  		err = nfs4_find_root_sec(server, fhandle, info);
>  		goto out_freepage;
>  	}
> 

