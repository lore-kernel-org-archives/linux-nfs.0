Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:50203 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752421Ab1ASTmr convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Jan 2011 14:42:47 -0500
Received: from sacrsexc1-prd.hq.netapp.com (sacrsexc1-prd.hq.netapp.com [10.99.115.27])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id p0JJgj02018469
	for <linux-nfs@vger.kernel.org>; Wed, 19 Jan 2011 11:42:47 -0800 (PST)
Subject: Re: [PATCH 1/1] NFS: fix handling of malloc failure during
 nfs_flush_multi()
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Fred Isaman <iisaman@netapp.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <1295464730-29568-1-git-send-email-iisaman@netapp.com>
References: <1295464730-29568-1-git-send-email-iisaman@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 19 Jan 2011 14:42:12 -0500
Message-ID: <1295466132.3444.47.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-01-19 at 14:18 -0500, Fred Isaman wrote: 
> Cleanup of the allocated list entries should not call
> put_nfs_open_context() on each entry, as the context will
> always be NULL, causing an oops.
> 
> Signed-off-by: Fred Isaman <iisaman@netapp.com>
> ---
>  fs/nfs/write.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index 10d648e..c8278f4 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -932,7 +932,7 @@ out_bad:
>  	while (!list_empty(&list)) {
>  		data = list_entry(list.next, struct nfs_write_data, pages);
>  		list_del(&data->pages);
> -		nfs_writedata_release(data);
> +		nfs_writedata_free(data);
>  	}
>  	nfs_redirty_request(req);
>  	return -ENOMEM;

Yep. That looks like a long standing bug. Will apply...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

