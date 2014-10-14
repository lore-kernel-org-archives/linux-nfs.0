Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:46684 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751503AbaJNVWP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Oct 2014 17:22:15 -0400
Message-ID: <543D9404.90006@RedHat.com>
Date: Tue, 14 Oct 2014 17:22:12 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: Re: [PATCH 2/2] NFS: Fix a bogus warning in nfs_generic_pgio
References: <1413212839-6665-1-git-send-email-trond.myklebust@primarydata.com> <1413212839-6665-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1413212839-6665-2-git-send-email-trond.myklebust@primarydata.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/13/2014 11:07 AM, Trond Myklebust wrote:
> It is OK for pageused == pagecount in the loop, as long as we don't add
> another entry to the *pages array. Move the test so that it only triggers
> in that case.
> 
> Reported-by: Steve Dickson <SteveD@redhat.com>
> Fixes: bba5c1887a92 (nfs: disallow duplicate pages in pgio page vectors)
> Cc: Weston Andros Adamson <dros@primarydata.com>
> Cc: stable@vger.kernel.org # 3.16.x
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Tested-by: Steve Dickson <steved@redhat.com>

steved.
> ---
>  fs/nfs/pagelist.c | 7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
> index 08085de879ed..ed0db61f8543 100644
> --- a/fs/nfs/pagelist.c
> +++ b/fs/nfs/pagelist.c
> @@ -752,12 +752,11 @@ int nfs_generic_pgio(struct nfs_pageio_descriptor *desc,
>  		nfs_list_remove_request(req);
>  		nfs_list_add_request(req, &hdr->pages);
>  
> -		if (WARN_ON_ONCE(pageused >= pagecount))
> -			return nfs_pgio_error(desc, hdr);
> -
>  		if (!last_page || last_page != req->wb_page) {
> -			*pages++ = last_page = req->wb_page;
>  			pageused++;
> +			if (pageused > pagecount)
> +				break;
> +			*pages++ = last_page = req->wb_page;
>  		}
>  	}
>  	if (WARN_ON_ONCE(pageused != pagecount))
> 
