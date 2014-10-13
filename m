Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f170.google.com ([209.85.213.170]:51116 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753060AbaJMPZt convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Oct 2014 11:25:49 -0400
Received: by mail-ig0-f170.google.com with SMTP id hn15so14064931igb.3
        for <linux-nfs@vger.kernel.org>; Mon, 13 Oct 2014 08:25:49 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH 2/2] NFS: Fix a bogus warning in nfs_generic_pgio
From: Weston Andros Adamson <dros@primarydata.com>
In-Reply-To: <1413212839-6665-2-git-send-email-trond.myklebust@primarydata.com>
Date: Mon, 13 Oct 2014 11:25:43 -0400
Cc: Steve Dickson <SteveD@redhat.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Message-Id: <A509B179-9699-403D-AF0B-6212474C6EDA@primarydata.com>
References: <1413212839-6665-1-git-send-email-trond.myklebust@primarydata.com> <1413212839-6665-2-git-send-email-trond.myklebust@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Oct 13, 2014, at 11:07 AM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> It is OK for pageused == pagecount in the loop, as long as we don't add
> another entry to the *pages array. Move the test so that it only triggers
> in that case.
> 
> Reported-by: Steve Dickson <SteveD@redhat.com>
> Fixes: bba5c1887a92 (nfs: disallow duplicate pages in pgio page vectors)
> Cc: Weston Andros Adamson <dros@primarydata.com>
> Cc: stable@vger.kernel.org # 3.16.x
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
> fs/nfs/pagelist.c | 7 +++----
> 1 file changed, 3 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
> index 08085de879ed..ed0db61f8543 100644
> --- a/fs/nfs/pagelist.c
> +++ b/fs/nfs/pagelist.c
> @@ -752,12 +752,11 @@ int nfs_generic_pgio(struct nfs_pageio_descriptor *desc,
> 		nfs_list_remove_request(req);
> 		nfs_list_add_request(req, &hdr->pages);
> 
> -		if (WARN_ON_ONCE(pageused >= pagecount))
> -			return nfs_pgio_error(desc, hdr);
> -
> 		if (!last_page || last_page != req->wb_page) {
> -			*pages++ = last_page = req->wb_page;
> 			pageused++;
> +			if (pageused > pagecount)
> +				break;
> +			*pages++ = last_page = req->wb_page;

This looks right.  Thanks Trond!

-dros

> 		}
> 	}
> 	if (WARN_ON_ONCE(pageused != pagecount))
> -- 
> 1.9.3
> 

