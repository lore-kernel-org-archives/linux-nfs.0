Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:10174 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753353Ab2DPTzL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Apr 2012 15:55:11 -0400
Date: Mon, 16 Apr 2012 15:55:59 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, steved@redhat.com
Subject: Re: [PATCH 3/3] NFSv4: Minor cleanups for nfs4_handle_exception and
 nfs4_async_handle_error
Message-ID: <20120416155559.38485f32@corrin.poochiereds.net>
In-Reply-To: <1332887744-4222-3-git-send-email-Trond.Myklebust@netapp.com>
References: <1332887744-4222-1-git-send-email-Trond.Myklebust@netapp.com>
	<1332887744-4222-2-git-send-email-Trond.Myklebust@netapp.com>
	<1332887744-4222-3-git-send-email-Trond.Myklebust@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 27 Mar 2012 18:35:44 -0400
Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
>  fs/nfs/nfs4proc.c |   10 +++++-----
>  1 files changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 1933e67..f82bde0 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -270,7 +270,7 @@ static int nfs4_handle_exception(struct nfs_server *server, int errorcode, struc
>  		case 0:
>  			return 0;
>  		case -NFS4ERR_OPENMODE:
> -			if (nfs_have_delegation(inode, FMODE_READ)) {
> +			if (inode && nfs_have_delegation(inode, FMODE_READ)) {
>  				nfs_inode_return_delegation(inode);
>  				exception->retry = 1;
>  				return 0;
> @@ -282,10 +282,9 @@ static int nfs4_handle_exception(struct nfs_server *server, int errorcode, struc
>  		case -NFS4ERR_DELEG_REVOKED:
>  		case -NFS4ERR_ADMIN_REVOKED:
>  		case -NFS4ERR_BAD_STATEID:
> -			if (state != NULL)
> -				nfs_remove_bad_delegation(state->inode);
>  			if (state == NULL)
>  				break;
> +			nfs_remove_bad_delegation(state->inode);
>  			nfs4_schedule_stateid_recovery(server, state);
>  			goto wait_on_recovery;
>  		case -NFS4ERR_EXPIRED:
> @@ -3825,8 +3824,9 @@ nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
>  		case -NFS4ERR_DELEG_REVOKED:
>  		case -NFS4ERR_ADMIN_REVOKED:
>  		case -NFS4ERR_BAD_STATEID:
> -			if (state != NULL)
> -				nfs_remove_bad_delegation(state->inode);
> +			if (state == NULL)
> +				break;
> +			nfs_remove_bad_delegation(state->inode);
>  		case -NFS4ERR_OPENMODE:
>  			if (state == NULL)
>  				break;

Hi Trond,

We got several reports of oopses in Fedora that look like they would be
fixed by this patch. Here's the bug that's tracking them:

    https://bugzilla.redhat.com/show_bug.cgi?id=811138

The problem seems to be regression introduced by 3114ea7a. An inode
field was added to the nfs4_exception struct, but most of the callers
of nfs4_handle_exception set it to NULL.

Would it be reasonable to push this to stable too?

-- 
Jeff Layton <jlayton@redhat.com>
