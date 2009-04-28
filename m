From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 17/19] NFSD: Stricter buffer size checking in
	fs/nfsd/nfsctl.c
Date: Tue, 28 Apr 2009 12:31:30 -0400
Message-ID: <20090428163130.GL17891@fieldses.org>
References: <20090423231550.17283.24432.stgit@ingres.1015granger.net> <20090423233325.17283.71127.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:38383 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757931AbZD1Qba (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Apr 2009 12:31:30 -0400
In-Reply-To: <20090423233325.17283.71127.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 23, 2009 at 07:33:25PM -0400, Chuck Lever wrote:
> Clean up: For consistency, handle output buffer size checking in a
> other nfsctl functions the same way it's done for write_versions().

These all look fine to me, thanks.  Let me know when you want them
applied.

--b.

> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  fs/nfsd/nfsctl.c |   14 +++++++++-----
>  1 files changed, 9 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> index a152694..877e713 100644
> --- a/fs/nfsd/nfsctl.c
> +++ b/fs/nfsd/nfsctl.c
> @@ -695,8 +695,9 @@ static ssize_t write_threads(struct file *file, char *buf, size_t size)
>  		if (rv)
>  			return rv;
>  	}
> -	sprintf(buf, "%d\n", nfsd_nrthreads());
> -	return strlen(buf);
> +
> +	return scnprintf(buf, SIMPLE_TRANSACTION_LIMIT, "%d\n",
> +							nfsd_nrthreads());
>  }
>  
>  /**
> @@ -1197,7 +1198,9 @@ static ssize_t write_maxblksize(struct file *file, char *buf, size_t size)
>  		nfsd_max_blksize = bsize;
>  		mutex_unlock(&nfsd_mutex);
>  	}
> -	return sprintf(buf, "%d\n", nfsd_max_blksize);
> +
> +	return scnprintf(buf, SIMPLE_TRANSACTION_LIMIT, "%d\n",
> +							nfsd_max_blksize);
>  }
>  
>  #ifdef CONFIG_NFSD_V4
> @@ -1221,8 +1224,9 @@ static ssize_t __write_leasetime(struct file *file, char *buf, size_t size)
>  			return -EINVAL;
>  		nfs4_reset_lease(lease);
>  	}
> -	sprintf(buf, "%ld\n", nfs4_lease_time());
> -	return strlen(buf);
> +
> +	return scnprintf(buf, SIMPLE_TRANSACTION_LIMIT, "%ld\n",
> +							nfs4_lease_time());
>  }
>  
>  /**
> 
