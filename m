From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [RFC 05/85] nfs41: Add Kconfig symbols for NFSv4.1
Date: Mon, 17 Nov 2008 15:27:35 +0200
Message-ID: <49217147.8000906@panasas.com>
References: <4918920E.3030301@panasas.com> <1226348320-7168-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: trond.myklebust@fys.uio.no, linux-nfs@vger.kernel.org
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.26]:8917 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752696AbYKQN1l (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Nov 2008 08:27:41 -0500
Received: by qw-out-2122.google.com with SMTP id 3so1178888qwe.37
        for <linux-nfs@vger.kernel.org>; Mon, 17 Nov 2008 05:27:39 -0800 (PST)
In-Reply-To: <1226348320-7168-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov. 10, 2008, 22:18 +0200, Benny Halevy <bhalevy@panasas.com> wrote:
> From: Ricardo Labiaga <ricardo.labiaga@netapp.com>
> 
> Added CONFIG_NFS_V4_1 and made it depend upon CONFIG_NFS_V4 and EXPERIMENTAL.
> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/Kconfig |    9 +++++++++
>  1 files changed, 9 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/Kconfig b/fs/Kconfig
> index 522469a..9363634 100644
> --- a/fs/Kconfig
> +++ b/fs/Kconfig
> @@ -1216,6 +1216,15 @@ config NFS_V4
>  
>  	  If unsure, say N.
>  
> +config NFS_V4_1
> +	bool "NFS client support for NFSv4.1 (EXPERIMENTAL)"

review 11-14: s/EXPERIMENTAL/DEVELOPER ONLY/

> +	depends on NFS_V4 && EXPERIMENTAL
> +	help
> +	  This option enables support for minor version 1 of the NFSv4 protocol
> +	  (draft-ietf-nfsv4-minorversion1) in the kernel's NFS client.
> +

	Unless you're an NFS developer, say N.

> +	  If unsure, say N.
> +
>  config ROOT_NFS
>  	bool "Root file system on NFS"
>  	depends on NFS_FS=y && IP_PNP
