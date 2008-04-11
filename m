From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] NFS: Only warn on unrecognized mount options
Date: Fri, 11 Apr 2008 16:24:59 -0400
Message-ID: <1207945499.15646.11.camel@heimdal.trondhjem.org>
References: <20080411200249.28007.12509.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:56508 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759197AbYDKUZB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Apr 2008 16:25:01 -0400
In-Reply-To: <20080411200249.28007.12509.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Fri, 2008-04-11 at 16:03 -0400, Chuck Lever wrote:
> To provide compatibility with automounters who use a common set of mount
> options for all file systems, change the NFS in-kernel mount option parser
> to ignore mount options it doesn't recognize.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> Yet another NFS mount patch!  Build tested only.  Comments?
> 
>  fs/nfs/super.c |    7 ++-----
>  1 files changed, 2 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index f921902..a7201f0 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -1044,7 +1044,8 @@ static int nfs_parse_mount_options(char *raw,
>  			break;
>  
>  		default:
> -			goto out_unknown;
> +			printk(KERN_INFO "NFS: unrecognized mount option '%s'"
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

This isn't really a very good solution either. Spamming the syslog on
every option that is being ignored isn't going to help the folks with
the global automounter maps. Either the rules should be that 'all
options are allowed' or they should be that 'only recognised NFS options
are allowed'.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
