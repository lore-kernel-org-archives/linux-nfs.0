Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:53123 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753042Ab1FNCvl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Jun 2011 22:51:41 -0400
Message-ID: <4DF6CD66.80408@cn.fujitsu.com>
Date: Tue, 14 Jun 2011 10:54:30 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: Steve Dickson <SteveD@redhat.com>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] libexport.a: fix using bad index for loop at cltsetup()
References: <4DF6C46C.9030201@cn.fujitsu.com>
In-Reply-To: <4DF6C46C.9030201@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



Mi Jinlong 写道:
> At cltsetup(), for address checking, it should use clp's naddr for index, 
> not cltarg's naddr(and it's always zero here).

  After sending this patch, I find this problem was introduced by 6299a.

-- 
----
thanks
Mi Jinlong

> 
> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
> ---
>  support/export/nfsctl.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/support/export/nfsctl.c b/support/export/nfsctl.c
> index f89c644..2950a90 100644
> --- a/support/export/nfsctl.c
> +++ b/support/export/nfsctl.c
> @@ -78,7 +78,7 @@ cltsetup(struct nfsctl_client *cltarg, nfs_client *clp)
>  	str_tolower(cltarg->cl_ident);
>  
>  	j = 0;
> -	for (i = 0; i < cltarg->cl_naddr && i < NFSCLNT_ADDRMAX; i++) {
> +	for (i = 0; i < clp->m_naddr && i < NFSCLNT_ADDRMAX; i++) {
>  		const struct sockaddr_in *sin = get_addrlist_in(clp, i);
>  		if (sin->sin_family == AF_INET)
>  			cltarg->cl_addrlist[j++] = sin->sin_addr;

