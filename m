Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:51236 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754154Ab3ETTGI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 May 2013 15:06:08 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Steve Dickson <SteveD@redhat.com>
CC: "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 05/13] NFSv4.2: Added NFS v4.2 support to the NFS client
Date: Mon, 20 May 2013 19:06:05 +0000
Message-ID: <1369076762.6115.18.camel@leira.trondhjem.org>
References: <1368719808-14584-1-git-send-email-SteveD@redhat.com>
	 <1368719808-14584-6-git-send-email-SteveD@redhat.com>
In-Reply-To: <1368719808-14584-6-git-send-email-SteveD@redhat.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-05-16 at 11:56 -0400, Steve Dickson wrote:
> From: Steve Dickson <steved@redhat.com>
> 
> This enable NFSv4.2 support. To enable this code the
> CONFIG_NFS_V4_2 Kconfig define needs to be set and
> the -o v4.2 mount option need to be used.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  fs/nfs/Kconfig        |  9 +++++++++
>  fs/nfs/callback.c     |  1 +
>  fs/nfs/callback_xdr.c |  6 +++---
>  fs/nfs/nfs4client.c   |  5 +++++
>  fs/nfs/nfs4proc.c     | 15 +++++++++++++++
>  fs/nfs/super.c        |  7 ++++++-
>  include/linux/nfs4.h  |  4 ++++
>  7 files changed, 43 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
> index 13ca196..79c500e 100644
> --- a/fs/nfs/Kconfig
> +++ b/fs/nfs/Kconfig
> @@ -104,6 +104,15 @@ config NFS_V4_1
>  
>  	  If unsure, say N.
>  
> +config NFS_V4_2
> +	bool "NFS client support for NFSv4.2"
> +	depends on NFS_V4_1
> +	help
> +	  This option enables support for minor version 1 of the NFSv4 protocol
> +	  in the kernel's NFS client.
> +
> +	  If unsure, say N.
> +

N

I want to enable support for minor version 2!

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
