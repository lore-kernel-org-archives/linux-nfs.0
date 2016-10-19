Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:40665 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935717AbcJSSv4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 19 Oct 2016 14:51:56 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: Re: [PATCH] nfs4: fix missing-braces warning
To: Arnd Bergmann <arnd@arndb.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>
References: <20161018152141.2774735-1-arnd@arndb.de>
CC: Jeff Layton <jlayton@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>,
        Andreas Gruenbacher <agruenba@redhat.com>,
        Andy Adamson <andros@netapp.com>, <linux-nfs@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
Message-ID: <e182f70d-c9ba-8e1d-fb7f-b81b2df98401@Netapp.com>
Date: Wed, 19 Oct 2016 14:51:20 -0400
MIME-Version: 1.0
In-Reply-To: <20161018152141.2774735-1-arnd@arndb.de>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Arnd (and Geert, if you're out there. I keep getting "relay access denied" when I try to CC you),

Thanks for the patches for this issue!  I've applied Arnd's version for 4.9-rc* since I think it looks a little cleaner.

Cheers,
Anna


On 10/18/2016 11:21 AM, Arnd Bergmann wrote:
> A bugfix introduced a harmless warning for update_open_stateid:
> 
> fs/nfs/nfs4proc.c:1548:2: error: missing braces around initializer [-Werror=missing-braces]
> 
> Removing the zero in the initializer will do the right thing here
> and initialize the entire structure to zero.
> 
> Fixes: 1393d9612ba0 ("NFSv4: Fix a race when updating an open_stateid")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  fs/nfs/nfs4proc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index ad917bd72b38..7897826d7c51 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -1545,7 +1545,7 @@ static int update_open_stateid(struct nfs4_state *state,
>  	struct nfs_client *clp = server->nfs_client;
>  	struct nfs_inode *nfsi = NFS_I(state->inode);
>  	struct nfs_delegation *deleg_cur;
> -	nfs4_stateid freeme = {0};
> +	nfs4_stateid freeme = { };
>  	int ret = 0;
>  
>  	fmode &= (FMODE_READ|FMODE_WRITE);
> 

