Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vx0-f174.google.com ([209.85.220.174]:49174 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030192Ab2CIWbG convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Mar 2012 17:31:06 -0500
Received: by vcqp1 with SMTP id p1so1845793vcq.19
        for <linux-nfs@vger.kernel.org>; Fri, 09 Mar 2012 14:31:06 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1331222633-2645-1-git-send-email-andros@netapp.com>
References: <1331222633-2645-1-git-send-email-andros@netapp.com>
Date: Fri, 9 Mar 2012 14:31:05 -0800
Message-ID: <CADnza46qMiagwV39sJU7E4AKY0KMFyyHNTAis_+PO-0b8955Yg@mail.gmail.com>
Subject: Re: [PATCH 1/1] NFSv4.1 cleanup DS stateid error handling
From: Fred Isaman <iisaman@netapp.com>
To: andros@netapp.com
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 8, 2012 at 8:03 AM,  <andros@netapp.com> wrote:
> From: Andy Adamson <andros@netapp.com>
>
> The error handler nfs4_state parameter is never NULL in the pNFS case as
> the open_context must carry an nfs_state.
>


Note Trond's argument is that with commit the state is avail for the
caller, so it need not be NULL.
But the caller filelayout_commit_done_cb() needs to be adjusted.
Currently commit to ds oopses
due to that.

Fred

> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/nfs4filelayout.c |    9 ++-------
>  1 files changed, 2 insertions(+), 7 deletions(-)
>
> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
> index b2d3bb5..768f6f8 100644
> --- a/fs/nfs/nfs4filelayout.c
> +++ b/fs/nfs/nfs4filelayout.c
> @@ -99,16 +99,12 @@ static int filelayout_async_handle_error(struct rpc_task *task,
>        case -NFS4ERR_DELEG_REVOKED:
>        case -NFS4ERR_ADMIN_REVOKED:
>        case -NFS4ERR_BAD_STATEID:
> -               if (state != NULL)
> -                       nfs_remove_bad_delegation(state->inode);
> +               nfs_remove_bad_delegation(state->inode);
>        case -NFS4ERR_OPENMODE:
> -               if (state == NULL)
> -                       break;
>                nfs4_schedule_stateid_recovery(mds_server, state);
>                goto wait_on_recovery;
>        case -NFS4ERR_EXPIRED:
> -               if (state != NULL)
> -                       nfs4_schedule_stateid_recovery(mds_server, state);
> +               nfs4_schedule_stateid_recovery(mds_server, state);
>                nfs4_schedule_lease_recovery(mds_client);
>                goto wait_on_recovery;
>        /* DS session errors */
> @@ -145,7 +141,6 @@ wait_on_recovery:
>        if (test_bit(NFS4CLNT_MANAGER_RUNNING, &mds_client->cl_state) == 0)
>                rpc_wake_up_queued_task(&mds_client->cl_rpcwaitq, task);
>        goto out;
> -
>  }
>
>  /* NFS_PROTO call done callback routines */
> --
> 1.7.6.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
