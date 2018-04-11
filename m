Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33560 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751972AbeDKOS5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 11 Apr 2018 10:18:57 -0400
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 035E731303A4
        for <linux-nfs@vger.kernel.org>; Wed, 11 Apr 2018 14:18:57 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-116-199.phx2.redhat.com [10.3.116.199])
        by smtp.corp.redhat.com (Postfix) with ESMTP id A3A4092A71
        for <linux-nfs@vger.kernel.org>; Wed, 11 Apr 2018 14:18:56 +0000 (UTC)
Subject: Re: [PATCH] mount.nfs: Fix auto protocol negotiation
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <20180410142952.10657-1-steved@redhat.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <da0256cc-626c-2a18-b0a8-1f8bb302ac05@RedHat.com>
Date: Wed, 11 Apr 2018 10:18:46 -0400
MIME-Version: 1.0
In-Reply-To: <20180410142952.10657-1-steved@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/10/2018 10:29 AM, Steve Dickson wrote:
> Commit 71b807e1 introduce a regression that
> caused v3 not to be tried when v4 was not
> supported by the server during auto negation.
> 
> A check of the type in nfs_nfs_version() was
> reverted back to only check for the "nfs4"
> string not the "nfs" string which fixed the
> problem.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed... 

steved.

> ---
>  utils/mount/network.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/utils/mount/network.c b/utils/mount/network.c
> index 9a2c878..e490399 100644
> --- a/utils/mount/network.c
> +++ b/utils/mount/network.c
> @@ -1279,8 +1279,8 @@ nfs_nfs_version(char *type, struct mount_options *options, struct nfs_version *v
>  		}
>  	}
>  
> -	if (!found && strncmp(type, "nfs", 3) == 0)
> -		version_val = "4";
> +	if (!found && strcmp(type, "nfs4") == 0)
> +		version_val = type + 3;
>  	else if (!found)
>  		return 1;
>  	else if (i <= 2 ) {
> 
