Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from elasmtp-spurfowl.atl.sa.earthlink.net ([209.86.89.66]:54061
	"EHLO elasmtp-spurfowl.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752187AbbFDPNX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Jun 2015 11:13:23 -0400
From: "Frank Filz" <ffilzlnx@mindspring.com>
To: "'Dominique Martinet'" <dominique.martinet@cea.fr>,
        <linux-nfs@vger.kernel.org>,
        "'Anna Schumaker'" <anna.schumaker@netapp.com>,
        "'Trond Myklebust'" <trond.myklebust@primarydata.com>
Cc: <linux-kernel@vger.kernel.org>
References: <1433430257-11894-1-git-send-email-dominique.martinet@cea.fr>
In-Reply-To: <1433430257-11894-1-git-send-email-dominique.martinet@cea.fr>
Subject: RE: [PATCH] NFSv4: handle nfs4_get_referral failure
Date: Thu, 4 Jun 2015 11:13:17 -0400
Message-ID: <004101d09ed8$fcbe7850$f63b68f0$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

More detail on this,

Basically what is going on is that a migration event has been detected in
nfs4_get_referral, but the migration recovery is not actually initiated.

We tripped over this because Ganesha intends to support referrals, but the
implementation is incomplete (not all FSALs support referrals, and we don't
necessarily change the fsid) and thus Ganesha's returning an NFS4ERR_MOVED
winds up looking like a migration event to the client (of course we don't
support migration either).

Thanks

Frank

> -----Original Message-----
> From: Dominique Martinet [mailto:dominique.martinet@cea.fr]
> Sent: Thursday, June 4, 2015 11:04 AM
> To: linux-nfs@vger.kernel.org; Anna Schumaker; Trond Myklebust
> Cc: linux-kernel@vger.kernel.org; Dominique Martinet; Frank S. Filz
> Subject: [PATCH] NFSv4: handle nfs4_get_referral failure
> 
> nfs4_proc_lookup_common is supposed to return a posix error, we have to
> handle any error returned that isn't errno
> 
> Reported-by: Olga Kornievskaia <kolga@netapp.com>
> Signed-off-by: Frank S. Filz <ffilzlnx@mindspring.com>
> Signed-off-by: Dominique Martinet <dominique.martinet@cea.fr>
> ---
> 
> Other way of fixing it would be to return something like -EIO directly in
> nfs4_get_referral, but I believe handling exception is the right thing to
do.
> Only other return code atm is -ENOMEM which probably isn't recoverable?
> 
>  fs/nfs/nfs4proc.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c index 627f37c..e7fbf24
> 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -3356,6 +3356,8 @@ static int nfs4_proc_lookup_common(struct
> rpc_clnt **clnt, struct inode *dir,
>  			goto out;
>  		case -NFS4ERR_MOVED:
>  			err = nfs4_get_referral(client, dir, name, fattr,
> fhandle);
> +			if (err == -NFS4ERR_MOVED)
> +				err =
> nfs4_handle_exception(NFS_SERVER(dir), err, &exception);
>  			goto out;
>  		case -NFS4ERR_WRONGSEC:
>  			err = -EPERM;
> --
> 2.4.2

