Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:21936 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753404Ab1BPSt4 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Feb 2011 13:49:56 -0500
Subject: Re: [PATCH pNFS wave 3 Version 2 18/18] NFSv4.1: lseg documentation
Content-Type: text/plain; charset=us-ascii
From: Andy Adamson <andros@netapp.com>
In-Reply-To: <1297759143-2045-19-git-send-email-andros@netapp.com>
Date: Wed, 16 Feb 2011 13:49:54 -0500
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org,
        Fred Isaman <iisaman@netapp.com>
Message-Id: <ACB81E1B-B6D7-49CA-9B1A-9B5DCFBD78B6@netapp.com>
References: <1297759143-2045-1-git-send-email-andros@netapp.com> <1297759143-2045-19-git-send-email-andros@netapp.com>
To: andros@netapp.com
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

This should be authored by Fred 

-->Andy

On Feb 15, 2011, at 3:39 AM, andros@netapp.com wrote:

> From: Andy Adamson <andros@netapp.com>
> 
> Signed-off-by: Fred Isaman <iisaman@netapp.com>
> ---
> Documentation/filesystems/nfs/pnfs.txt |    7 +++++++
> 1 files changed, 7 insertions(+), 0 deletions(-)
> 
> diff --git a/Documentation/filesystems/nfs/pnfs.txt b/Documentation/filesystems/nfs/pnfs.txt
> index bc0b9cf..983e14a 100644
> --- a/Documentation/filesystems/nfs/pnfs.txt
> +++ b/Documentation/filesystems/nfs/pnfs.txt
> @@ -46,3 +46,10 @@ data server cache
> file driver devices refer to data servers, which are kept in a module
> level cache.  Its reference is held over the lifetime of the deviceid
> pointing to it.
> +
> +lseg
> +----
> +lseg maintains an extra reference corresponding to the NFS_LSEG_VALID
> +bit which holds it in the pnfs_layout_hdr's list.  When the final lseg
> +is removed from the pnfs_layout_hdr's list, the NFS_LAYOUT_DESTROYED
> +bit is set, preventing any new lsegs from being added.
> -- 
> 1.7.2.3
> 

