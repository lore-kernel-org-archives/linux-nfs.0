Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:59510 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756534Ab2IJVq3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Sep 2012 17:46:29 -0400
Date: Mon, 10 Sep 2012 17:46:28 -0400
To: Malahal Naineni <malahal@us.ibm.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFSD: pass null terminated buf to kstrtouint()
Message-ID: <20120910214628.GA11563@fieldses.org>
References: <1347204347-23706-1-git-send-email-malahal@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1347204347-23706-1-git-send-email-malahal@us.ibm.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Sep 09, 2012 at 10:25:47AM -0500, Malahal Naineni wrote:
> The 'buf' is prepared with null termination with intention of using it for
> this purpose, but 'name' is passed instead!

Thanks!--b.

> 
> Signed-off-by: Malahal Naineni <malahal@us.ibm.com>
> ---
>  fs/nfsd/nfs4idmap.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4idmap.c b/fs/nfsd/nfs4idmap.c
> index fdc91a6..ccfe0d0 100644
> --- a/fs/nfsd/nfs4idmap.c
> +++ b/fs/nfsd/nfs4idmap.c
> @@ -598,7 +598,7 @@ numeric_name_to_id(struct svc_rqst *rqstp, int type, const char *name, u32 namel
>  	/* Just to make sure it's null-terminated: */
>  	memcpy(buf, name, namelen);
>  	buf[namelen] = '\0';
> -	ret = kstrtouint(name, 10, id);
> +	ret = kstrtouint(buf, 10, id);
>  	return ret == 0;
>  }
>  
> -- 
> 1.7.0.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
