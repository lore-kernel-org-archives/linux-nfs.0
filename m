Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:11113 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934822Ab3DJT7o convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Apr 2013 15:59:44 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs: remove unnecessary check for NULL inode->i_flock
 from nfs_delegation_claim_locks
Date: Wed, 10 Apr 2013 19:59:28 +0000
Message-ID: <1365623982.8465.75.camel@leira.trondhjem.org>
References: <1365622608-21015-1-git-send-email-jlayton@redhat.com>
In-Reply-To: <1365622608-21015-1-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2013-04-10 at 15:36 -0400, Jeff Layton wrote:
> The second check was added in commit 65b62a29 but it will never be true.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/nfs/delegation.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
> index f30bd1e..57db324 100644
> --- a/fs/nfs/delegation.c
> +++ b/fs/nfs/delegation.c
> @@ -71,10 +71,8 @@ static int nfs_delegation_claim_locks(struct nfs_open_context *ctx, struct nfs4_
>  	int status = 0;
>  
>  	if (inode->i_flock == NULL)
> -		return 0;
> -
> -	if (inode->i_flock == NULL)
>  		goto out;
> +
>  	/* Protect inode->i_flock using the file locks lock */
>  	lock_flocks();
>  	for (fl = inode->i_flock; fl != NULL; fl = fl->fl_next) {

Thanks! Applied...
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
