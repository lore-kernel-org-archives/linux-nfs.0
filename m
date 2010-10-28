Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx01.sz.bfs.de ([194.94.69.103]:26625 "EHLO mx01.sz.bfs.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754327Ab0J1HQL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Oct 2010 03:16:11 -0400
Message-ID: <4CC92338.7070304@bfs.de>
Date: Thu, 28 Oct 2010 09:16:08 +0200
From: walter harms <wharms@bfs.de>
Reply-To: wharms@bfs.de
To: Dan Carpenter <error27@gmail.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        kernel-janitors@vger.kernel.org
Subject: Re: [patch] nfs: check kmalloc() return
References: <20101028044403.GV6062@bicker>
In-Reply-To: <20101028044403.GV6062@bicker>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



Dan Carpenter schrieb:
> The decode_and_add_ds() should return NULL on failure.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>
> 
> diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
> index 51fe64a..098113c 100644
> --- a/fs/nfs/nfs4filelayoutdev.c
> +++ b/fs/nfs/nfs4filelayoutdev.c
> @@ -219,6 +219,8 @@ decode_and_add_ds(__be32 **pp, struct inode *inode)
>  		goto out_err;
>  	}
>  	buf = kmalloc(rlen + 1, GFP_KERNEL);
> +	if (!buf)
> +		goto out_err;
>  	buf[rlen] = '\0';
>  	memcpy(buf, r_addr, rlen);
>  

it seems that r_addr is a string, then kstdup() is emulated here.

re,
 wh



> --
> To unsubscribe from this list: send the line "unsubscribe kernel-janitors" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
