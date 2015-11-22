Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f43.google.com ([209.85.192.43]:35411 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751646AbbKVNEW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 22 Nov 2015 08:04:22 -0500
Received: by qgec40 with SMTP id c40so100383868qge.2
        for <linux-nfs@vger.kernel.org>; Sun, 22 Nov 2015 05:04:21 -0800 (PST)
Date: Sun, 22 Nov 2015 08:04:18 -0500
From: Jeff Layton <jlayton@poochiereds.net>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        kernel-janitors@vger.kernel.org
Subject: Re: [patch] nfsd: fix a warning message
Message-ID: <20151122080418.65d93f86@tlielax.poochiereds.net>
In-Reply-To: <20151121102850.GA7002@mwanda>
References: <20151121102850.GA7002@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 21 Nov 2015 13:28:50 +0300
Dan Carpenter <dan.carpenter@oracle.com> wrote:

> The WARN() macro takes a condition and a format string.  The condition
> was accidentally left out here so it just prints the function name
> instead of the message.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 6b800b5..7af023f 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -2240,7 +2240,8 @@ nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
>  	base = resp->cstate.data_offset;
>  	slot->sl_datalen = buf->len - base;
>  	if (read_bytes_from_xdr_buf(buf, base, slot->sl_data, slot->sl_datalen))
> -		WARN("%s: sessions DRC could not cache compound\n", __func__);
> +		WARN(1, "%s: sessions DRC could not cache compound\n",
> +		     __func__);
>  	return;
>  }
>  

Reviewed-by: Jeff Layton <jlayton@poochiereds.net>
