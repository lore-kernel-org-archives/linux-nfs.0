From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 1/1] NFS: map nfs_probe_fsinfo errors
Date: Thu, 04 Dec 2008 12:16:51 -0500
Message-ID: <1228411011.7475.6.camel@heimdal.trondhjem.org>
References: <1228410550-17040-1-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:1905 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752542AbYLDRRc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Dec 2008 12:17:32 -0500
Received: from sacrsexc2-prd.hq.netapp.com ([10.99.115.28])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mB4HHUH6000122
	for <linux-nfs@vger.kernel.org>; Thu, 4 Dec 2008 09:17:31 -0800 (PST)
In-Reply-To: <1228410550-17040-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2008-12-04 at 12:09 -0500, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Callers of nfs_probe_fsinfo return ERR_PTR errors. NFSv4 errors need to be
> mapped.
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/client.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index 7547600..e12495c 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -817,7 +817,7 @@ static int nfs_probe_fsinfo(struct nfs_server *server, struct nfs_fh *mntfh, str
>  
>  out_error:
>  	dprintk("nfs_probe_fsinfo: error = %d\n", -error);
> -	return error;
> +	return nfs4_map_errors(error);
>  }
>  
>  /*

No. This is still in generic code that is also called by both NFSv2 and
v3. We should _never_ be passing NFSv4 errors this far up the stack.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
