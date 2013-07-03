Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:40412 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751837Ab3GCNTr convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Jul 2013 09:19:47 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.5 \(1508\))
Subject: Re: [PATCH] Disable NFS version 2
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1372856675-5520-1-git-send-email-steved@redhat.com>
Date: Wed, 3 Jul 2013 09:19:42 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <9A7F190A-2938-4A14-9125-330189DA8597@oracle.com>
References: <1372856675-5520-1-git-send-email-steved@redhat.com>
To: Steve Dickson <steved@redhat.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

I'm not opposed to this change, but we should have some public discussion about it first.

If we make this proposed upstream change, NFSv2 will be built far less often and will be a magnet for code rot.  It might make more sense to simply leave the "compile this out" choice up to distributions...?  I'd like to reduce the risk of the kernel carrying around code that no-one uses or compiles.  If we truly want this off by default everywhere, shouldn't we just remove it?  (Is that the eventual goal?)

Should the server also disable NFSv2 support by default?  If not, then why is the client special in this regard?

Finally, if we go with something like this change, does this patch also need to update the default configurations shipped with the kernel?


On Jul 3, 2013, at 9:04 AM, Steve Dickson <steved@redhat.com> wrote:

> This patch disables the NFS version 2 module from being compile by default.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
> fs/nfs/Kconfig | 4 ++--
> 1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
> index 13ca196..6831a01 100644
> --- a/fs/nfs/Kconfig
> +++ b/fs/nfs/Kconfig
> @@ -32,12 +32,12 @@ config NFS_FS
> config NFS_V2
> 	tristate "NFS client support for NFS version 2"
> 	depends on NFS_FS
> -	default y
> +	default n
> 	help
> 	  This option enables support for version 2 of the NFS protocol
> 	  (RFC 1094) in the kernel's NFS client.
> 
> -	  If unsure, say Y.
> +	  If unsure, say n.
> 
> config NFS_V3
> 	tristate "NFS client support for NFS version 3"
> -- 
> 1.8.1.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




