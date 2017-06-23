Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:33582 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750932AbdFWOd1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Jun 2017 10:33:27 -0400
Received: by mail-qt0-f193.google.com with SMTP id c20so6081011qte.0
        for <linux-nfs@vger.kernel.org>; Fri, 23 Jun 2017 07:33:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170623142659.81480-2-kolga@netapp.com>
References: <20170623142659.81480-1-kolga@netapp.com> <20170623142659.81480-2-kolga@netapp.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Fri, 23 Jun 2017 10:33:25 -0400
Message-ID: <CAN-5tyG8gMDkEFGHzs0itjmujwWkVj8=7ORycx7NkYYXMarMgw@mail.gmail.com>
Subject: Re: [PATCH 1/1] PNFS for stateid errors retry against MDS first
To: Olga Kornievskaia <kolga@netapp.com>
Cc: Trond Myklebust <Trond.Myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 23, 2017 at 10:26 AM, Olga Kornievskaia <kolga@netapp.com> wrote:
> Upon receiving a stateid error such as BAD_STATEID, the client
> should retry the operation against the MDS before deciding to
> do stateid recovery.
>
> Previously, the code would initiate state recovery and it could
> lead to a race in a state manager that could chose an incorrect
> recovery method which would lead to the EIO failure for the
> application.
>
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
>  fs/nfs/filelayout/filelayout.c         | 28 ----------------------------
>  fs/nfs/flexfilelayout/flexfilelayout.c | 33 ---------------------------------
>  2 files changed, 61 deletions(-)
>
> diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
> index ce82da1..61dcb4b 100644
> --- a/fs/nfs/filelayout/filelayout.c
> +++ b/fs/nfs/filelayout/filelayout.c
> @@ -126,32 +126,13 @@ static int filelayout_async_handle_error(struct rpc_task *task,
>  {
>         struct pnfs_layout_hdr *lo = lseg->pls_layout;
>         struct inode *inode = lo->plh_inode;
> -       struct nfs_server *mds_server = NFS_SERVER(inode);
>         struct nfs4_deviceid_node *devid = FILELAYOUT_DEVID_NODE(lseg);
> -       struct nfs_client *mds_client = mds_server->nfs_client;
>         struct nfs4_slot_table *tbl = &clp->cl_session->fc_slot_table;
>
>         if (task->tk_status >= 0)
>                 return 0;
>
>         switch (task->tk_status) {
> -       /* MDS state errors */
> -       case -NFS4ERR_DELEG_REVOKED:
> -       case -NFS4ERR_ADMIN_REVOKED:
> -       case -NFS4ERR_BAD_STATEID:
> -       case -NFS4ERR_OPENMODE:
> -               if (state == NULL)
> -                       break;
> -               if (nfs4_schedule_stateid_recovery(mds_server, state) < 0)
> -                       goto out_bad_stateid;
> -               goto wait_on_recovery;
> -       case -NFS4ERR_EXPIRED:
> -               if (state != NULL) {
> -                       if (nfs4_schedule_stateid_recovery(mds_server, state) < 0)
> -                               goto out_bad_stateid;
> -               }
> -               nfs4_schedule_lease_recovery(mds_client);
> -               goto wait_on_recovery;
>         /* DS session errors */
>         case -NFS4ERR_BADSESSION:
>         case -NFS4ERR_BADSLOT:
> @@ -211,17 +192,8 @@ static int filelayout_async_handle_error(struct rpc_task *task,
>                         task->tk_status);
>                 return -NFS4ERR_RESET_TO_MDS;
>         }
> -out:
>         task->tk_status = 0;
>         return -EAGAIN;
> -out_bad_stateid:
> -       task->tk_status = -EIO;
> -       return 0;
> -wait_on_recovery:
> -       rpc_sleep_on(&mds_client->cl_rpcwaitq, task, NULL);
> -       if (test_bit(NFS4CLNT_MANAGER_RUNNING, &mds_client->cl_state) == 0)
> -               rpc_wake_up_queued_task(&mds_client->cl_rpcwaitq, task);
> -       goto out;
>  }
>
>  /* NFS_PROTO call done callback routines */
> diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
> index 23542dc..1f2ac3d 100644
> --- a/fs/nfs/flexfilelayout/flexfilelayout.c
> +++ b/fs/nfs/flexfilelayout/flexfilelayout.c
> @@ -1050,34 +1050,10 @@ static int ff_layout_async_handle_error_v4(struct rpc_task *task,
>  {
>         struct pnfs_layout_hdr *lo = lseg->pls_layout;
>         struct inode *inode = lo->plh_inode;
> -       struct nfs_server *mds_server = NFS_SERVER(inode);
> -
>         struct nfs4_deviceid_node *devid = FF_LAYOUT_DEVID_NODE(lseg, idx);
> -       struct nfs_client *mds_client = mds_server->nfs_client;
>         struct nfs4_slot_table *tbl = &clp->cl_session->fc_slot_table;
>
>         switch (task->tk_status) {
> -       /* MDS state errors */
> -       case -NFS4ERR_DELEG_REVOKED:
> -       case -NFS4ERR_ADMIN_REVOKED:
> -       case -NFS4ERR_BAD_STATEID:
> -               if (state == NULL)
> -                       break;
> -               nfs_remove_bad_delegation(state->inode, NULL);
> -       case -NFS4ERR_OPENMODE:
> -               if (state == NULL)
> -                       break;
> -               if (nfs4_schedule_stateid_recovery(mds_server, state) < 0)
> -                       goto out_bad_stateid;
> -               goto wait_on_recovery;
> -       case -NFS4ERR_EXPIRED:
> -               if (state != NULL) {
> -                       if (nfs4_schedule_stateid_recovery(mds_server, state) < 0)
> -                               goto out_bad_stateid;
> -               }
> -               nfs4_schedule_lease_recovery(mds_client);
> -               goto wait_on_recovery;
> -       /* DS session errors */
>         case -NFS4ERR_BADSESSION:
>         case -NFS4ERR_BADSLOT:
>         case -NFS4ERR_BAD_HIGH_SLOT:
> @@ -1137,17 +1113,8 @@ static int ff_layout_async_handle_error_v4(struct rpc_task *task,
>                         task->tk_status);
>                 return -NFS4ERR_RESET_TO_MDS;
>         }
> -out:
>         task->tk_status = 0;
>         return -EAGAIN;
> -out_bad_stateid:
> -       task->tk_status = -EIO;
> -       return 0;
> -wait_on_recovery:
> -       rpc_sleep_on(&mds_client->cl_rpcwaitq, task, NULL);
> -       if (test_bit(NFS4CLNT_MANAGER_RUNNING, &mds_client->cl_state) == 0)
> -               rpc_wake_up_queued_task(&mds_client->cl_rpcwaitq, task);
> -       goto out;
>  }
>
>  /* Retry all errors through either pNFS or MDS except for -EJUKEBOX */
> --
> 1.8.3.1
>

Trond, I pre-emptively added the same correction to the flexlayout as
I think it needs to do the same for the error but I haven't tested it.
Also this patch depends, on the PNFS fix EACCESS patch otherwise, it
leads to the same kernel oops on the umount.

> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
