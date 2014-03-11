Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f42.google.com ([209.85.216.42]:34426 "EHLO
	mail-qa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753644AbaCKVN6 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Mar 2014 17:13:58 -0400
Received: by mail-qa0-f42.google.com with SMTP id k15so9275048qaq.1
        for <linux-nfs@vger.kernel.org>; Tue, 11 Mar 2014 14:13:57 -0700 (PDT)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: [PATCH] mount.nfs: background mount now do directly into background
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <1394284964-12997-1-git-send-email-steved@redhat.com>
Date: Tue, 11 Mar 2014 17:13:55 -0400
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Message-Id: <E50361D2-FB5A-4A1D-BBE2-8DA25C09D865@primarydata.com>
References: <1394284964-12997-1-git-send-email-steved@redhat.com>
To: Dickson Steve <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 8, 2014, at 8:22, Steve Dickson <SteveD@redhat.com> wrote:

> Modern day kernel will no longer return all timeout
> errors instead the process spins endlessly in the kernel.
> This behavior will cause the foreground mount to hang, never
> allowing the mount to go into background.
> 
> So this patch eliminates the foreground mount cause
> background mounts to go directly into background
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
> utils/mount/stropts.c |   31 ++++++++-----------------------
> 1 files changed, 8 insertions(+), 23 deletions(-)
> 
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index a642394..92a7245 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -913,28 +913,6 @@ static int nfsmount_fg(struct nfsmount_info *mi)
> }
> 
> /*
> - * Handle "background" NFS mount [first try]
> - *
> - * Returns a valid mount command exit code.
> - *
> - * EX_BG should cause the caller to fork and invoke nfsmount_child.
> - */
> -static int nfsmount_parent(struct nfsmount_info *mi)
> -{
> -	if (nfs_try_mount(mi))
> -		return EX_SUCCESS;
> -
> -	/* retry background mounts when the server is not up */
> -	if (nfs_is_permanent_error(errno) && errno != EOPNOTSUPP) {
> -		mount_error(mi->spec, mi->node, errno);
> -		return EX_FAIL;
> -	}
> -
> -	sys_mount_errors(mi->hostname, errno, 1, 1);
> -	return EX_BG;
> -}
> -
> -/*
>  * Handle "background" NFS mount [retry daemon]
>  *
>  * Returns a valid mount command exit code: EX_SUCCESS if successful,
> @@ -982,7 +960,14 @@ static int nfsmount_child(struct nfsmount_info *mi)
> static int nfsmount_bg(struct nfsmount_info *mi)
> {
> 	if (!mi->child)
> -		return nfsmount_parent(mi);
> +		/* 
> +		 * Modern day kernels no longer return all 
> +		 * timeouts errors in all cases, instead 
> +		 * the process spins in the kernel, which 
> +		 * will hang a foreground mount. So background
> +		 * mounts have to go directly into background
> +		 */
> +		return EX_BG;
> 	else
> 		return nfsmount_child(mi);
> }

Hi Steve,

Doesn’t this mean that ‘mount.nfs’ will no longer attempt to wait for the mount to complete? That’s why I suggested having the parent set a timer, and then waiting for whichever comes first out of SIGCHLD or SIGALRM (indicating either that the child mount process is done mounting or that the timeout occurred).

Cheers
  Trond
_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

