Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f177.google.com ([209.85.160.177]:35739 "EHLO
	mail-yk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752120AbbCWQJ0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Mar 2015 12:09:26 -0400
Received: by ykfs63 with SMTP id s63so74930131ykf.2
        for <linux-nfs@vger.kernel.org>; Mon, 23 Mar 2015 09:09:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1427119769.16955.6.camel@primarydata.com>
References: <550BDAE0.2070409@gmail.com>
	<CAHQdGtSJ8GtC5DL2wh5BjyBBEEV_53pjvX-_CD4vCGkzHWY=2g@mail.gmail.com>
	<550F6964.4030005@gmail.com>
	<1427119769.16955.6.camel@primarydata.com>
Date: Mon, 23 Mar 2015 12:09:25 -0400
Message-ID: <CAHQdGtTn5me9ZBfv9D8qZOmp6MFc29ppn4DqD8hOuMqRgRY8Rg@mail.gmail.com>
Subject: Re: [PATCH] NFS4: Retry destroy session when getting -NFS4ERR_DELAY
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 23, 2015 at 10:09 AM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
> 8<---------------------------------------------------------------
> From 21fb62639ad69ecc5c443dba5b41ad2bd64c6e76 Mon Sep 17 00:00:00 2001
> From: Trond Myklebust <trond.myklebust@primarydata.com>
> Date: Mon, 23 Mar 2015 09:51:41 -0400
> Subject: [PATCH] NFSv4: Ensure that we drain the session before shutting it
>  down
>
> Kinglong Mee reports that the call to DESTROY_SESSION in NFSv4.1
> are racing with the asynchronous DELEGRETURN calls that precede it.
> This points to the root cause being that we're not waiting for the
> session to drain before we destroy it.
>
> This patch ensures that we do so for both NFSv4 and NFSv4.1.
>
> Reported-by: Kinglong Mee <kinglongmee@gmail.com>
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfs/nfs4_fs.h    |  3 +++
>  fs/nfs/nfs4client.c |  7 ++-----
>  fs/nfs/nfs4state.c  | 18 ++++++++++++++++++
>  3 files changed, 23 insertions(+), 5 deletions(-)
>
> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
> index fdef424b0cd3..594f53c3aee5 100644
> --- a/fs/nfs/nfs4_fs.h
> +++ b/fs/nfs/nfs4_fs.h
> @@ -257,6 +257,8 @@ extern int nfs4_set_rw_stateid(nfs4_stateid *stateid,
>                 const struct nfs_lock_context *l_ctx,
>                 fmode_t fmode);
>
> +extern void nfs40_shutdown_session(struct nfs_client *clp);
> +
>  #if defined(CONFIG_NFS_V4_1)
>  static inline struct nfs4_session *nfs4_get_session(const struct nfs_server *server)
>  {
> @@ -269,6 +271,7 @@ extern int nfs41_setup_sequence(struct nfs4_session *session,
>  extern int nfs41_sequence_done(struct rpc_task *, struct nfs4_sequence_res *);
>  extern int nfs4_proc_create_session(struct nfs_client *, struct rpc_cred *);
>  extern int nfs4_proc_destroy_session(struct nfs4_session *, struct rpc_cred *);
> +extern void nfs41_shutdown_session(struct nfs_client *clp, struct nfs4_session *session);
>  extern int nfs4_proc_get_lease_time(struct nfs_client *clp,
>                 struct nfs_fsinfo *fsinfo);
>  extern int nfs4_proc_layoutcommit(struct nfs4_layoutcommit_data *data,
> diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
> index 86d6214ea022..bdabbf9b6322 100644
> --- a/fs/nfs/nfs4client.c
> +++ b/fs/nfs/nfs4client.c
> @@ -160,7 +160,7 @@ void nfs41_shutdown_client(struct nfs_client *clp)
>  {
>         if (nfs4_has_session(clp)) {
>                 nfs4_shutdown_ds_clients(clp);
> -               nfs4_destroy_session(clp->cl_session);
> +               nfs41_shutdown_session(clp, clp->cl_session);
>                 nfs4_destroy_clientid(clp);
>         }
>
> @@ -169,10 +169,7 @@ void nfs41_shutdown_client(struct nfs_client *clp)
>
>  void nfs40_shutdown_client(struct nfs_client *clp)
>  {
> -       if (clp->cl_slot_tbl) {
> -               nfs4_shutdown_slot_table(clp->cl_slot_tbl);
> -               kfree(clp->cl_slot_tbl);
> -       }
> +       nfs40_shutdown_session(clp);
>  }
>
>  struct nfs_client *nfs4_alloc_client(const struct nfs_client_initdata *cl_init)
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index f95e3b58bbc3..54fa7e2bc3e3 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -2134,6 +2134,18 @@ out_unlock:
>         return status;
>  }
>
> +void nfs40_shutdown_session(struct nfs_client *clp)
> +{
> +       struct nfs4_slot_table  *tbl = clp->cl_slot_tbl;
> +
> +       if (tbl) {
> +               nfs4_drain_slot_tbl(tbl);
> +               nfs4_shutdown_slot_table(tbl);
> +               clp->cl_slot_tbl = NULL;
> +               kfree(tbl);
> +       }
> +}
> +
>  #ifdef CONFIG_NFS_V4_1
>  void nfs4_schedule_session_recovery(struct nfs4_session *session, int err)
>  {
> @@ -2314,6 +2326,12 @@ static int nfs4_bind_conn_to_session(struct nfs_client *clp)
>         }
>         return 0;
>  }
> +
> +void nfs41_shutdown_session(struct nfs_client *clp, struct nfs4_session *session)
> +{
> +       nfs4_begin_drain_session(clp);

Argh. We can't quite do this, because we do want all outstanding RPC
calls to complete, not just the ones that have already been allocated
slots. Let me respin.

> +       nfs4_destroy_session(session);
> +}
>  #else /* CONFIG_NFS_V4_1 */
>  static int nfs4_reset_session(struct nfs_client *clp) { return 0; }
>
> --
> 2.1.0
>
>
>
>



-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
