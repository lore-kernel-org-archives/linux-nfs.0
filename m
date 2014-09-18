Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f179.google.com ([209.85.220.179]:51563 "EHLO
	mail-vc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932117AbaIRRHU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Sep 2014 13:07:20 -0400
Received: by mail-vc0-f179.google.com with SMTP id la4so637007vcb.38
        for <linux-nfs@vger.kernel.org>; Thu, 18 Sep 2014 10:07:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1411045997-3988-1-git-send-email-steved@redhat.com>
References: <1411045997-3988-1-git-send-email-steved@redhat.com>
Date: Thu, 18 Sep 2014 13:07:18 -0400
Message-ID: <CAHQdGtQqynEfDsYmq8MxsC_9zS9khaUcpqA=0-WGR7tbreEA9g@mail.gmail.com>
Subject: Re: [PATCH] [V2] NFSv4: nfs4_state_manager() vs. nfs_server_remove_lists()
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 18, 2014 at 9:13 AM, Steve Dickson <steved@redhat.com> wrote:
> There is a race between nfs4_state_manager() and
> nfs_server_remove_lists() that happens during a nfsv3 mount.
>
> The v3 mount notices there is already a supper block so
> nfs_server_remove_lists() called which uses the nfs_client_lock
> spin lock to synchronize access to the client list.
>
> At the same time nfs4_state_manager() is running through
> the client list looking for work to do, using the same
> lock. When nfs4_state_manager() wins the race to the
> list, a v3 client pointer is found and not ignored
> properly which causes the panic.
>
> Moving some protocol checks before the state checking
> avoids the panic.
>
> CC: Stable Tree <stable@vger.kernel.org>
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  fs/nfs/nfs4client.c | 38 ++++++++++++++++++++------------------
>  1 file changed, 20 insertions(+), 18 deletions(-)
>
> diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
> index 53e435a..ffdb28d 100644
> --- a/fs/nfs/nfs4client.c
> +++ b/fs/nfs/nfs4client.c
> @@ -482,6 +482,16 @@ int nfs40_walk_client_list(struct nfs_client *new,
>
>         spin_lock(&nn->nfs_client_lock);
>         list_for_each_entry(pos, &nn->nfs_client_list, cl_share_link) {
> +
> +               if (pos->rpc_ops != new->rpc_ops)
> +                       continue;
> +
> +               if (pos->cl_proto != new->cl_proto)
> +                       continue;
> +
> +               if (pos->cl_minorversion != new->cl_minorversion)
> +                       continue;
> +
>                 /* If "pos" isn't marked ready, we can't trust the
>                  * remaining fields in "pos" */
>                 if (pos->cl_cons_state > NFS_CS_READY) {
> @@ -501,15 +511,6 @@ int nfs40_walk_client_list(struct nfs_client *new,
>                 if (pos->cl_cons_state != NFS_CS_READY)
>                         continue;
>
> -               if (pos->rpc_ops != new->rpc_ops)
> -                       continue;
> -
> -               if (pos->cl_proto != new->cl_proto)
> -                       continue;
> -
> -               if (pos->cl_minorversion != new->cl_minorversion)
> -                       continue;
> -
>                 if (pos->cl_clientid != new->cl_clientid)
>                         continue;
>
> @@ -622,6 +623,16 @@ int nfs41_walk_client_list(struct nfs_client *new,
>
>         spin_lock(&nn->nfs_client_lock);
>         list_for_each_entry(pos, &nn->nfs_client_list, cl_share_link) {
> +
> +               if (pos->rpc_ops != new->rpc_ops)
> +                       continue;
> +
> +               if (pos->cl_proto != new->cl_proto)
> +                       continue;
> +
> +               if (pos->cl_minorversion != new->cl_minorversion)
> +                       continue;
> +
>                 /* If "pos" isn't marked ready, we can't trust the
>                  * remaining fields in "pos", especially the client
>                  * ID and serverowner fields.  Wait for CREATE_SESSION
> @@ -647,15 +658,6 @@ int nfs41_walk_client_list(struct nfs_client *new,
>                 if (pos->cl_cons_state != NFS_CS_READY)
>                         continue;
>
> -               if (pos->rpc_ops != new->rpc_ops)
> -                       continue;
> -
> -               if (pos->cl_proto != new->cl_proto)
> -                       continue;
> -
> -               if (pos->cl_minorversion != new->cl_minorversion)
> -                       continue;
> -
>                 if (!nfs4_match_clientids(pos, new))
>                         continue;
>
> --
> 1.8.3.1
>
Thanks. Applied...


-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
