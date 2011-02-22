Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:11268 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751195Ab1BVRIG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Feb 2011 12:08:06 -0500
Message-ID: <4D63ED74.1080502@panasas.com>
Date: Tue, 22 Feb 2011 09:08:04 -0800
From: Benny Halevy <bhalevy@panasas.com>
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: fix missing include
References: <1298390923-6547-1-git-send-email-tigran.mkrtchyan@desy.de>
In-Reply-To: <1298390923-6547-1-git-send-email-tigran.mkrtchyan@desy.de>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Thanks.  This pnfs specific, introduced in
c857ea8 pnfs_submit: signal layoutdriver commit

I'll fix it there...

Benny

On 2011-02-22 08:08, Tigran Mkrtchyan wrote:
> I got some compile time error:
> 
>   CC [M]  fs/nfsd/nfs4proc.o
> In file included from include/linux/nfsd/nfsd4_pnfs.h:39:0,
>                  from include/linux/nfsd/nfs4layoutxdr.h:38,
>                  from fs/nfsd/nfs4proc.c:37:
> include/linux/nfs_xdr.h:1124:15: error: field ‘refcount’ has incomplete type
> 
> and here is my attempt to fix it
> ---
>  include/linux/nfs_xdr.h |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
> index a965f9d..e4710b0 100644
> --- a/include/linux/nfs_xdr.h
> +++ b/include/linux/nfs_xdr.h
> @@ -5,6 +5,7 @@
>  #include <linux/nfs3.h>
>  #include <linux/nfs4.h>
>  #include <linux/sunrpc/sched.h>
> +#include <linux/kref.h>
>  
>  /*
>   * To change the maximum rsize and wsize supported by the NFS client, adjust
