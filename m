Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f171.google.com ([209.85.220.171]:37271 "EHLO
	mail-vc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751143AbaHCPjS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 Aug 2014 11:39:18 -0400
Received: by mail-vc0-f171.google.com with SMTP id hq11so9616732vcb.16
        for <linux-nfs@vger.kernel.org>; Sun, 03 Aug 2014 08:39:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <53DE56C7.2080407@gmail.com>
References: <53DE56C7.2080407@gmail.com>
Date: Sun, 3 Aug 2014 11:39:17 -0400
Message-ID: <CAHQdGtQRhmvWWizba58ApjrcWwPt-E8uUNNT4DYJNF2YXncSWw@mail.gmail.com>
Subject: Re: [PATCH] NFS: Update clientid in RELEASE_LOCKOWNER RPC after
 re-register clientid
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Aug 3, 2014 at 11:35 AM, Kinglong Mee <kinglongmee@gmail.com> wrote:
> Fix Commit 60ea681299 (NFS: Migration support for RELEASE_LOCKOWNER)
> If getting expired error, client will enter a infinite loop as,
>
> client                            server
>    RELEASE_LOCKOWNER(old clid) ----->
>                 <--- expired error
>    RENEW(old clid)             ----->
>                 <--- expired error
>    SETCLIENTID                 ----->
>                 <--- a new clid
>    SETCLIENTID_CONFIRM (new clid) -->
>                 <--- ok
>    RELEASE_LOCKOWNER(old clid) ----->
>                 <--- expired error
>    RENEW(new clid)             ----->
>                 <-- ok
>    RELEASE_LOCKOWNER(old clid) ----->
>                 <--- expired error
>    RENEW(new clid)             ----->
>                 <-- ok
>                 ... ...
>
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfs/nfs4proc.c | 7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
>
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 285ad53..6c4e6c1 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -5834,8 +5834,11 @@ struct nfs_release_lockowner_data {
>  static void nfs4_release_lockowner_prepare(struct rpc_task *task, void *calldata)
>  {
>         struct nfs_release_lockowner_data *data = calldata;
> -       nfs40_setup_sequence(data->server,
> -                               &data->args.seq_args, &data->res.seq_res, task);
> +       struct nfs_server *server = data->server;
> +
> +       nfs40_setup_sequence(server, &data->args.seq_args,
> +                                &data->res.seq_res, task);
> +       data->args.lock_owner.clientid = server->nfs_client->cl_clientid;
>         data->timestamp = jiffies;
>  }
>

Hi Kinglong,

If the lease expired, the server will also have forgotten about our
lockowner, and so we shouldn't need to re-send the release_lockowner.

Cheers
  Trond


-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
