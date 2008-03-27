From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 2/3] SUNRPC: Remove PROC_FS dependency
Date: Thu, 27 Mar 2008 17:20:39 -0400
Message-ID: <20080327212039.GP32540@fieldses.org>
References: <20080327203447.5036.93689.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:33104 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759487AbYC0VUk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 27 Mar 2008 17:20:40 -0400
In-Reply-To: <20080327203447.5036.93689.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 27, 2008 at 04:34:47PM -0400, Chuck Lever wrote:
> Recently, commit 440bcc59 added a reverse dependency to fs/Kconfig to
> ensure that PROC_FS was enabled if SUNRPC_GSS was enabled.
> 
> Apparently this isn't necessary because the auth_gss components under
> net/sunrpc will build correctly even if PROC_FS is disabled, though
> RPCSEC_GSS will not work without /proc.

It's only server-side RPCSEC_GSS that won't work without /proc.

And it still bugs me a little that you can select both RPCSEC_GSS and
NFSD and end up with something that doesn't actually support server-side
GSS.

But I don't know what to do about that; so, fine, applied.--b.

> 
> It also violates the guideline in Documentation/kbuild/kconfig-language.txt
> that states "In general use select only for non-visible symbols (no prompts
> anywhere) and for symbols with no dependencies."
> 
> To address these issues, remove the dependency.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  fs/Kconfig |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/Kconfig b/fs/Kconfig
> index db67512..373ee37 100644
> --- a/fs/Kconfig
> +++ b/fs/Kconfig
> @@ -1668,7 +1668,6 @@ config NFSD
>  	select SUNRPC
>  	select EXPORTFS
>  	select NFS_ACL_SUPPORT if NFSD_V2_ACL
> -	select PROC_FS if SUNRPC_GSS
>  	help
>  	  Choose Y here if you want to allow other computers to access
>  	  files residing on this system using Sun's Network File System
> 
