From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] lockd: release reference to nsm_handle in
	nlm_host_rebooted
Date: Mon, 8 Feb 2010 16:19:08 -0500
Message-ID: <20100208211908.GB14942@fieldses.org>
References: <1265400552-8375-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53374 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751507Ab0BHVSp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Feb 2010 16:18:45 -0500
In-Reply-To: <1265400552-8375-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 05, 2010 at 03:09:12PM -0500, Jeff Layton wrote:
> nsm_reboot_lookup takes a reference to the nsm_handle that it returns,
> but nlm_host_rebooted never releases that reference.

Makes sense to me; I'll apply to the nfsd tree.

(How did you run across this?)

--b.

> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  fs/lockd/host.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/lockd/host.c b/fs/lockd/host.c
> index 4600c20..bb464d1 100644
> --- a/fs/lockd/host.c
> +++ b/fs/lockd/host.c
> @@ -479,8 +479,8 @@ again:	mutex_lock(&nlm_host_mutex);
>  			}
>  		}
>  	}
> -
>  	mutex_unlock(&nlm_host_mutex);
> +	nsm_release(nsm);
>  }
>  
>  /*
> -- 
> 1.6.6
> 
