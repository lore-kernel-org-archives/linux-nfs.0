Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:57525 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751372Ab3JURdh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Oct 2013 13:33:37 -0400
Message-ID: <52656594.4080907@RedHat.com>
Date: Mon, 21 Oct 2013 13:34:12 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: linux-nfs@vger.kernel.org, edoutreleau@genoscope.cns.fr
Subject: Re: [PATCH] mount.nfs: print an error message when remount attempt
 fails
References: <1382363229-6343-1-git-send-email-jlayton@redhat.com>
In-Reply-To: <1382363229-6343-1-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 21/10/13 09:47, Jeff Layton wrote:
> Currently, mount.nfs returns an error code, but doesn't print anything
> when this occurs.
> 
> Reported-by: Eric Doutreleau <edoutreleau@genoscope.cns.fr>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
committed... 

steved.
> ---
>  utils/mount/stropts.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index 1dc38ef..a642394 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -1004,6 +1004,7 @@ static int nfs_remount(struct nfsmount_info *mi)
>  {
>  	if (nfs_sys_mount(mi, mi->options))
>  		return EX_SUCCESS;
> +	mount_error(mi->spec, mi->node, errno);
>  	return EX_FAIL;
>  }
>  
> -- 1.8.3.1
> 
