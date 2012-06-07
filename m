Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 8bytes.org ([85.214.48.195]:56019 "EHLO
	h2027444.stratoserver.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754385Ab2FGPnM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Jun 2012 11:43:12 -0400
Received: from localhost (localhost [127.0.0.1])
	by h2027444.stratoserver.net (Postfix) with SMTP id 0FEC812AFE9
	for <linux-nfs@vger.kernel.org>; Thu,  7 Jun 2012 17:43:08 +0200 (CEST)
Date: Thu, 7 Jun 2012 17:43:07 +0200
From: Joerg Roedel <joro@8bytes.org>
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: NFS regression in v3.5-rc1: mount.nfs yells about incorrect
 mount option
Message-ID: <20120607154307.GQ12795@8bytes.org>
References: <20120607150456.GO12795@8bytes.org>
 <4FD0C4C2.8020605@netapp.com>
 <4FD0C613.7020400@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FD0C613.7020400@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 07, 2012 at 11:17:39AM -0400, Bryan Schumaker wrote:
> On 06/07/2012 11:12 AM, Bryan Schumaker wrote:
> commit cdf66442fab82916fe38f928b4f91815195a294c
> Author: Bryan Schumaker <bjschuma@netapp.com>
> Date:   Tue Jun 5 14:59:54 2012 -0400
> 
>     NFS4: Set parsed mount data version to 4
>     
>     This patch only affects mounting through "-t nfs4" since it doesn't set
>     up an nfs version to use in the mount data.  The nfs client was trying
>     to mount using NFS v0, causing either a BUG() or a protocol not
>     supported message.
>     
>     Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index ff656c0..bdd6731 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -2637,6 +2637,8 @@ static int nfs4_validate_mount_data(void *options,
>  	if (data == NULL)
>  		goto out_no_data;
>  
> +	args->version = 4;
> +
>  	switch (data->version) {
>  	case 1:
>  		if (data->host_addrlen > sizeof(args->nfs_server.address))

No, this doesn't fix it for me. Same behavior as with plain v3.5-rc1.


	Joerg


