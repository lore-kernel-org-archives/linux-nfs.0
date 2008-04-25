From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] NFS: Only warn on unrecognized mount options
Date: Fri, 25 Apr 2008 07:33:42 -0400
Message-ID: <20080425073342.6326a4a3@tleilax.poochiereds.net>
References: <20080411202800.31268.3495.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:45626 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751430AbYDYLeK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Apr 2008 07:34:10 -0400
In-Reply-To: <20080411202800.31268.3495.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 11 Apr 2008 16:28:43 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

> To provide compatibility with automounters who use a common set of mount
> options for all file systems, change the NFS in-kernel mount option parser
> to ignore mount options it doesn't recognize.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> Take 2.
> 
>  fs/nfs/super.c |    7 ++-----
>  1 files changed, 2 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index f921902..cbf2b37 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -1044,7 +1044,8 @@ static int nfs_parse_mount_options(char *raw,
>  			break;
>  
>  		default:
> -			goto out_unknown;
> +			dfprintk(MOUNT, "NFS: unrecognized mount option '%s'"
> +					" ignored\n", p);
>  		}
>  	}
>  
> @@ -1070,10 +1071,6 @@ out_unrec_xprt:
>  out_unrec_sec:
>  	printk(KERN_INFO "NFS: unrecognized security flavor\n");
>  	return 0;
> -
> -out_unknown:
> -	printk(KERN_INFO "NFS: unknown mount option: %s\n", p);
> -	return 0;
>  }
>  
>  /*
> 


Sorry for late reply on this...

I wonder if we should make this conditional on the "-s" (sloppy)
option? I think autofs will use that option when it mounts. There are a
couple of ways we could approach this:

1) have -s set a mount flag (which means getting a new MS_SLOPPY flag
added to the VFS).

2) have -s make mount.nfs prepend an implicit "sloppy," to the option
string. That would get parsed first and you could make the behavior of
unrecognized mount options be dependent upon that.

#2 sounds fairly easy to do, actually...

-- 
Jeff Layton <jlayton@redhat.com>
