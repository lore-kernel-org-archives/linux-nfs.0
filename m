Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f174.google.com ([209.85.160.174]:36573 "EHLO
	mail-yk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754446AbbGHSu5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Jul 2015 14:50:57 -0400
Received: by ykey15 with SMTP id y15so19626045yke.3
        for <linux-nfs@vger.kernel.org>; Wed, 08 Jul 2015 11:50:57 -0700 (PDT)
Date: Wed, 8 Jul 2015 14:50:52 -0400
From: Jeff Layton <jeff.layton@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFSv4.2/flexfiles: Fix a typo in the flexfiles
 layoutstats code
Message-ID: <20150708145052.35666606@tlielax.poochiereds.net>
In-Reply-To: <1436379987-4388-1-git-send-email-trond.myklebust@primarydata.com>
References: <1436379987-4388-1-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed,  8 Jul 2015 20:26:27 +0200
Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfs/flexfilelayout/flexfilelayout.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
> index c12951b9551e..b3289d701eea 100644
> --- a/fs/nfs/flexfilelayout/flexfilelayout.c
> +++ b/fs/nfs/flexfilelayout/flexfilelayout.c
> @@ -1852,7 +1852,7 @@ ff_layout_mirror_prepare_stats(struct nfs42_layoutstat_args *args,
>  	struct nfs42_layoutstat_devinfo *devinfo;
>  	int i;
>  
> -	for (i = 0; i <= FF_LAYOUT_MIRROR_COUNT(pls); i++) {
> +	for (i = 0; i < FF_LAYOUT_MIRROR_COUNT(pls); i++) {
>  		if (*dev_count >= dev_limit)
>  			break;
>  		mirror = FF_LAYOUT_COMP(pls, i);

Reviewed-by: Jeff Layton <jeff.layton@primarydata.com>
