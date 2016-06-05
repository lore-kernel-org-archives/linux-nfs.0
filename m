Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:34178 "EHLO
	mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752907AbcFEKje (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 5 Jun 2016 06:39:34 -0400
Received: by mail-qt0-f195.google.com with SMTP id 9so433695qtg.1
        for <linux-nfs@vger.kernel.org>; Sun, 05 Jun 2016 03:39:33 -0700 (PDT)
Message-ID: <1465122103.5944.0.camel@poochiereds.net>
Subject: Re: [PATCH] nfds: Fix NFSD_MDS_PR_KEY on 32-bit by adding ULL
 postfix
From: Jeff Layton <jlayton@poochiereds.net>
To: Geert Uytterhoeven <geert@linux-m68k.org>,
        "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Sun, 05 Jun 2016 06:21:43 -0400
In-Reply-To: <1465118633-2659-1-git-send-email-geert@linux-m68k.org>
References: <1465118633-2659-1-git-send-email-geert@linux-m68k.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 2016-06-05 at 11:23 +0200, Geert Uytterhoeven wrote:
> On 32-bit:
> 
>     fs/nfsd/blocklayout.c: In function ‘nfsd4_block_get_device_info_scsi’:
>     fs/nfsd/blocklayout.c:337: warning: integer constant is too large for ‘long’ type
>     fs/nfsd/blocklayout.c:344: warning: integer constant is too large for ‘long’ type
>     fs/nfsd/blocklayout.c: In function ‘nfsd4_scsi_fence_client’:
>     fs/nfsd/blocklayout.c:385: warning: integer constant is too large for ‘long’ type
> 
> Add the missing "ULL" postfix to 64-bit constant NFSD_MDS_PR_KEY to fix
> this.
> 
> Fixes: f99d4fbdae6765d0 ("nfsd: add SCSI layout support")
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> ---
> v2:
>   - Add Reviewed-by.
> 
> Despite Bruce's "Thanks, applying for 4.6.--b." on 2016-03-29, this
> still hasn't made it into next-20160603.
> ---
>  fs/nfsd/blocklayout.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/blocklayout.c b/fs/nfsd/blocklayout.c
> index e55b5242614da7a9..31f3df193bdbb47b 100644
> --- a/fs/nfsd/blocklayout.c
> +++ b/fs/nfsd/blocklayout.c
> @@ -290,7 +290,7 @@ out_free_buf:
>  	return error;
>  }
>  
> -#define NFSD_MDS_PR_KEY		0x0100000000000000
> +#define NFSD_MDS_PR_KEY		0x0100000000000000ULL
>  
>  /*
>   * We use the client ID as a unique key for the reservations.

Thanks!

Reviewed-by: Jeff Layton <jlayton@poochiereds.net>
