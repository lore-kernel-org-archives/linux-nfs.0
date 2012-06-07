Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:57605 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752904Ab2FGVJP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Jun 2012 17:09:15 -0400
Message-ID: <4FD1186D.9060503@panasas.com>
Date: Fri, 8 Jun 2012 00:09:01 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Idan Kedar <idank@tonian.com>
CC: <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] pnfs-obj: disable unloading the module when mounted
References: <1339095991-26753-1-git-send-email-idank@tonian.com> <1339095991-26753-2-git-send-email-idank@tonian.com>
In-Reply-To: <1339095991-26753-2-git-send-email-idank@tonian.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/07/2012 10:06 PM, Idan Kedar wrote:

> or the kernel will oops.
> 


Perfect Thanks

> Signed-off-by: Idan Kedar <idank@tonian.com>
> ---
>  fs/nfs/objlayout/objio_osd.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
> index 55d0128..b161f97 100644
> --- a/fs/nfs/objlayout/objio_osd.c
> +++ b/fs/nfs/objlayout/objio_osd.c
> @@ -551,6 +551,7 @@ static const struct nfs_pageio_ops objio_pg_write_ops = {
>  static struct pnfs_layoutdriver_type objlayout_type = {
>  	.id = LAYOUT_OSD2_OBJECTS,
>  	.name = "LAYOUT_OSD2_OBJECTS",
> +	.owner = THIS_MODULE,
>  	.flags                   = PNFS_LAYOUTRET_ON_SETATTR |
>  				   PNFS_LAYOUTRET_ON_ERROR,
>  


