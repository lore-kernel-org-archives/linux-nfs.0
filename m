Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f176.google.com ([209.85.220.176]:50830 "EHLO
	mail-vc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755875AbbBIRih (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Feb 2015 12:38:37 -0500
Received: by mail-vc0-f176.google.com with SMTP id la4so1586663vcb.7
        for <linux-nfs@vger.kernel.org>; Mon, 09 Feb 2015 09:38:35 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1423501065-14320-1-git-send-email-tigran.mkrtchyan@desy.de>
References: <1423501065-14320-1-git-send-email-tigran.mkrtchyan@desy.de>
Date: Mon, 9 Feb 2015 12:38:35 -0500
Message-ID: <CAHQdGtSGS5oJGbjUGBiQ=J6yvx=uQOPzegt2iL-yPVMp3nTapQ@mail.gmail.com>
Subject: Re: [PATCH] nfs: do not initialize back channel with DS
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Tigran,

On Mon, Feb 9, 2015 at 11:57 AM, Tigran Mkrtchyan
<tigran.mkrtchyan@desy.de> wrote:
> Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
> ---
>  fs/nfs/nfs4proc.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
>
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 2e7c9f7..7f9674d 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -7236,9 +7236,12 @@ static int _nfs4_proc_create_session(struct nfs_client *clp,
>                 .rpc_cred = cred,
>         };
>         int status;
> +       int flags = SESSION4_PERSIST;
>
>         nfs4_init_channel_attrs(&args);
> -       args.flags = (SESSION4_PERSIST | SESSION4_BACK_CHAN);
> +       if (!is_ds_only_client(clp))
> +               flags |= SESSION4_BACK_CHAN;
> +       args.flags = flags;
>
>         status = rpc_call_sync(session->clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
>         trace_nfs4_create_session(clp, status);

Why is this useful? If the server doesn't want to create a back
channel, then it just clears that flag in the csr_flags field in the
reply.

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
