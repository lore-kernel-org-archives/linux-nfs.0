Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f51.google.com ([209.85.214.51]:42421 "EHLO
	mail-bw0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753667Ab1BVTzj convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Feb 2011 14:55:39 -0500
Received: by bwz10 with SMTP id 10so3643557bwz.10
        for <linux-nfs@vger.kernel.org>; Tue, 22 Feb 2011 11:55:38 -0800 (PST)
In-Reply-To: <1298310576-13523-8-git-send-email-iisaman@netapp.com>
References: <1298310576-13523-1-git-send-email-iisaman@netapp.com>
	<1298310576-13523-8-git-send-email-iisaman@netapp.com>
Date: Tue, 22 Feb 2011 11:55:38 -0800
Message-ID: <AANLkTikzhYto6dNgMODE5KcJWnumKuBVMvSoJROUZyKp@mail.gmail.com>
Subject: Re: [PATCH 7/7] NFSv4.1: pnfs filelayout driver write
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Feb 21, 2011 at 9:49 AM, Fred Isaman <iisaman@netapp.com> wrote:
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index b6b683d..a10f120 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -783,7 +783,7 @@ static int flush_task_priority(int how)
>        return RPC_PRIORITY_NORMAL;
>  }
>
> -static int nfs_initiate_write(struct nfs_write_data *data,
> +int nfs_initiate_write(struct nfs_write_data *data,
>                       struct rpc_clnt *clnt,
>                       const struct rpc_call_ops *call_ops,
>                       int how)
> @@ -833,6 +833,7 @@ static int nfs_initiate_write(struct nfs_write_data *data,
>  out:
>        return ret;
>  }
> +EXPORT_SYMBOL(nfs_initiate_write);
>

This should be EXPORT_SYMBOL_GPL.

Fred
