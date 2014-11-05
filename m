Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:53143 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755001AbaKEOuB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Nov 2014 09:50:01 -0500
Message-ID: <545A3916.1050906@Netapp.com>
Date: Wed, 5 Nov 2014 09:49:58 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Olga Kornievskaia <kolga@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/3] NFSv4: Ensure that we call FREE_STATEID when NFSv4.x
 stateids are revoked
References: <1415144188-17193-1-git-send-email-trond.myklebust@primarydata.com> <1415144188-17193-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1415144188-17193-2-git-send-email-trond.myklebust@primarydata.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Trond,

On 11/04/2014 06:36 PM, Trond Myklebust wrote:
> NFSv4.x (x>0) requires us to call TEST_STATEID+FREE_STATEID if a stateid is
> revoked. We will currently fail to do this if the stateid is a delegation.
>
> http://lkml.kernel.org/r/CAN-5tyHwG=Cn2Q9KsHWadewjpTTy_K26ee+UnSvHvG4192p-Xw@mail.gmail.com
> Cc: stable@vger.kernel.org
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfs/nfs4proc.c | 8 --------
>  1 file changed, 8 deletions(-)
>
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index d8f352d8c75f..6cf49af3092d 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -370,11 +370,6 @@ static int nfs4_handle_exception(struct nfs_server *server, int errorcode, struc
>  		case -NFS4ERR_DELEG_REVOKED:
>  		case -NFS4ERR_ADMIN_REVOKED:
>  		case -NFS4ERR_BAD_STATEID:
> -			if (inode != NULL && nfs4_have_delegation(inode, FMODE_READ)) {
> -				nfs_remove_bad_delegation(inode);
> -				exception->retry = 1;
> -				break;
> -			}
>  			if (state == NULL)
>  				break;
>  			ret = nfs4_schedule_stateid_recovery(server, state);
> @@ -4849,9 +4844,6 @@ nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
>  		case -NFS4ERR_DELEG_REVOKED:
>  		case -NFS4ERR_ADMIN_REVOKED:
>  		case -NFS4ERR_BAD_STATEID:
> -			if (state == NULL)
> -				break;
> -			nfs_remove_bad_delegation(state->inode);

Does filelayout_async_handle_error() need to be updated in the same way?  They are the only remaining caller of nfs_remove_bad_delegation().

Thanks,
Anna

>  		case -NFS4ERR_OPENMODE:
>  			if (state == NULL)
>  				break;

