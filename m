Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:36518 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753831AbbG0Wp5 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Jul 2015 18:45:57 -0400
Received: by igbij6 with SMTP id ij6so92464008igb.1
        for <linux-nfs@vger.kernel.org>; Mon, 27 Jul 2015 15:45:57 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2102\))
Subject: Re: [PATCH 1/2] NFS: Fix a memory leak in nfs_do_recoalesce
From: Weston Andros Adamson <dros@primarydata.com>
In-Reply-To: <1438007656-11662-1-git-send-email-trond.myklebust@primarydata.com>
Date: Mon, 27 Jul 2015 18:45:55 -0400
Cc: linux-nfs list <linux-nfs@vger.kernel.org>
Message-Id: <7EFAC23D-9CE9-4BB7-B280-9C19FBAB5B59@primarydata.com>
References: <1438007656-11662-1-git-send-email-trond.myklebust@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

ACK to both.

Good catch, thanks!

-dros



> On Jul 27, 2015, at 10:34 AM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> 
> If the function exits early, then we must put those requests that were
> not processed back onto the &mirror->pg_list so they can be cleaned up
> by nfs_pgio_error().
> 
> Fixes: a7d42ddb30997 ("nfs: add mirroring support to pgio layer")
> Cc: stable@vger.kernel.org # v4.0+
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
> fs/nfs/pagelist.c | 5 ++++-
> 1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git PATCH v2fs/nfs/pagelist.c b/fs/nfs/pagelist.c
> index 1da68d3b1eda..8ea5920fb777 100644
> --- PATCH v2fs/nfs/pagelist.c	
> +++ b/fs/nfs/pagelist.c
> @@ -1109,8 +1109,11 @@ static int nfs_do_recoalesce(struct nfs_pageio_descriptor *desc)
> 			nfs_list_remove_request(req);
> 			if (__nfs_pageio_add_request(desc, req))
> 				continue;
> -			if (desc->pg_error < 0)
> +			if (desc->pg_error < 0) {
> +				list_splice_tail(&head, &mirror->pg_list);
> +				mirror->pg_recoalesce = 1;
> 				return 0;
> +			}
> 			break;
> 		}
> 	} while (mirror->pg_recoalesce);
> -- 
> 2.4.3
> 

