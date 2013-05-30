Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:20798 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750811Ab3E3Uv7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 May 2013 16:51:59 -0400
Message-ID: <51A7BBEB.60005@netapp.com>
Date: Thu, 30 May 2013 16:51:55 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: Steve Dickson <SteveD@redhat.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 05/13] NFSv4.2: Added NFS v4.2 support to the NFS client
References: <1368719808-14584-1-git-send-email-SteveD@redhat.com> <1368719808-14584-6-git-send-email-SteveD@redhat.com>
In-Reply-To: <1368719808-14584-6-git-send-email-SteveD@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/16/2013 11:56 AM, Steve Dickson wrote:
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

8< snip >8

> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
> index 7764aca..4204600 100644
> --- a/include/linux/nfs4.h
> +++ b/include/linux/nfs4.h
> @@ -399,11 +399,15 @@ enum lock_type4 {
>  #define NFS4_VERSION 4
>  #define NFS4_MINOR_VERSION 0
>  
> +#if defined(CONFIG_NFS_V4_2)
> +#define NFS4_MAX_MINOR_VERSION 2
> +#else
>  #if defined(CONFIG_NFS_V4_1)
>  #define NFS4_MAX_MINOR_VERSION 1
>  #else
>  #define NFS4_MAX_MINOR_VERSION 0
>  #endif /* CONFIG_NFS_V4_1 */
> +#endif /* CONFIG_NFS_V4_2 */

Could this be done with a #elif so we don't need the nested endif-s?

~ Bryan

>  
>  #define NFS4_DEBUG 1
>  
> 

