Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35241 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752934AbbDBRWi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Apr 2015 13:22:38 -0400
Message-ID: <551D7ADD.3060505@RedHat.com>
Date: Thu, 02 Apr 2015 13:22:37 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@lst.de>
CC: linux-nfs@vger.kernel.org, Ben Hutchings <ben@decadent.org.uk>,
        Cyril Brulebois <kibi@debian.org>
Subject: Re: [PATCH 2/2] mount.nfs.man, nfs.man: Update distinction between
 fstypes
References: <1427876624-28066-1-git-send-email-hch@lst.de> <1427876624-28066-2-git-send-email-hch@lst.de>
In-Reply-To: <1427876624-28066-2-git-send-email-hch@lst.de>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/01/2015 04:23 AM, Christoph Hellwig wrote:
> From: Ben Hutchings <ben@decadent.org.uk>
> 
> ---
Committed.. 

steved.

>  utils/mount/mount.nfs.man | 12 ++++++++----
>  1 file changed, 8 insertions(+), 4 deletions(-)
> 
> diff --git a/utils/mount/mount.nfs.man b/utils/mount/mount.nfs.man
> index 1a4561b..15a82d5 100644
> --- a/utils/mount/mount.nfs.man
> +++ b/utils/mount/mount.nfs.man
> @@ -15,16 +15,20 @@ is meant to be used by the
>  .BR mount (8)
>  command for mounting NFS shares. This subcommand, however, can also be used as a standalone command with limited functionality.
>  
> -.BR mount.nfs4 
> -is used for mounting NFSv4 file system, while 
> -.BR mount.nfs 
> -is used to mount NFS file systems versions 3 or 2.
>  .I remotetarget 
>  is a server share usually in the form of 
>  .BR servername:/path/to/share.
>  .I dir 
>  is the directory on which the file system is to be mounted.
>  
> +Under Linux 2.6.32 and later kernel versions,
> +.BR mount.nfs
> +can mount all NFS file system versions.  Under earlier Linux kernel versions,
> +.BR mount.nfs4
> +must be used for mounting NFSv4 file systems while
> +.BR mount.nfs
> +must be used for NFSv3 and v2.
> +
>  .SH OPTIONS
>  .TP
>  .BI "\-r"
> 
