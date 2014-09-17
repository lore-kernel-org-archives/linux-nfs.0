Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f177.google.com ([209.85.220.177]:61620 "EHLO
	mail-vc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754363AbaIQOzN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Sep 2014 10:55:13 -0400
Received: by mail-vc0-f177.google.com with SMTP id la4so1384612vcb.36
        for <linux-nfs@vger.kernel.org>; Wed, 17 Sep 2014 07:55:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1410965448-6110-1-git-send-email-steved@redhat.com>
References: <1410965448-6110-1-git-send-email-steved@redhat.com>
Date: Wed, 17 Sep 2014 10:55:11 -0400
Message-ID: <CAHQdGtQv4BPmD5s77=sFmyjT+64+65A8j3nEu_z-woNOGkGAng@mail.gmail.com>
Subject: Re: [PATCH] NFSv4: nfs4_state_manager() vs. nfs_server_remove_lists()
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 17, 2014 at 10:50 AM, Steve Dickson <steved@redhat.com> wrote:
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
>  fs/nfs/nfs4client.c | 19 ++++++++++---------
>  1 file changed, 10 insertions(+), 9 deletions(-)
>
> diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
> index 53e435a..7ff4c02 100644
> --- a/fs/nfs/nfs4client.c
> +++ b/fs/nfs/nfs4client.c
> @@ -622,6 +622,16 @@ int nfs41_walk_client_list(struct nfs_client *new,
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
> @@ -647,15 +657,6 @@ int nfs41_walk_client_list(struct nfs_client *new,
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

Don't we need the same fix in nfs40_walk_client_list?

Cheers
  Trond

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
