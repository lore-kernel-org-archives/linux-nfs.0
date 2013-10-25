Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f52.google.com ([209.85.212.52]:45204 "EHLO
	mail-vb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750861Ab3JYGJE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Oct 2013 02:09:04 -0400
MIME-Version: 1.0
In-Reply-To: <1382375414-5854-2-git-send-email-dros@netapp.com>
References: <1382375414-5854-1-git-send-email-dros@netapp.com> <1382375414-5854-2-git-send-email-dros@netapp.com>
From: William Dauchy <wdauchy@gmail.com>
Date: Fri, 25 Oct 2013 08:08:42 +0200
Message-ID: <CAJ75kXZNuUUCt+GVsupFVBymupj-GE6u3b34V3RNkDwdaMx7Mw@mail.gmail.com>
Subject: Re: [PATCH 1/5] NFSv4: fix NULL dereference in open recover
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>, stable@vger.kernel.org,
        Weston Andros Adamson <dros@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 21, 2013 at 7:10 PM, Weston Andros Adamson <dros@netapp.com> wrote:
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index d2b4845..000063e 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -1317,7 +1317,8 @@ _nfs4_opendata_reclaim_to_nfs4_state(struct nfs4_opendata *data)
>         struct nfs4_state *state = data->state;
>         int ret;
>
> -       if (!data->rpc_done) {
> +       /* allow cached opens (!rpc_done && !rpc_status) */
> +       if (!data->rpc_done && data->rpc_status) {
>                 ret = data->rpc_status;
>                 goto err;
>         }

I'm also getting this trace on a 3.10.x; Trond, could you validate this patch?

Thanks,
-- 
William
