Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qe0-f47.google.com ([209.85.128.47]:54598 "EHLO
	mail-qe0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932189Ab3JNUcJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Oct 2013 16:32:09 -0400
MIME-Version: 1.0
In-Reply-To: <1381782256-2434-1-git-send-email-geyslan@gmail.com>
References: <1381782256-2434-1-git-send-email-geyslan@gmail.com>
Date: Mon, 14 Oct 2013 17:32:08 -0300
Message-ID: <CAGG-pURU_8p2-2EQH5hK_NX+1PjEBCMhe05KFVfvD3E0zXZuhQ@mail.gmail.com>
Subject: Re: [PATCH v2] nfs: Use PTR_ERR_OR_ZERO in 'nfs41_callback_up' function
From: =?UTF-8?Q?Geyslan_Greg=C3=B3rio_Bem?= <geyslan@gmail.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: schumaker.anna@gmail.com, linux-nfs@vger.kernel.org,
        LKML <linux-kernel@vger.kernel.org>,
        kernel-br <kernel-br@googlegroups.com>,
        "Geyslan G. Bem" <geyslan@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2013/10/14 Geyslan G. Bem <geyslan@gmail.com>:
> Use 'PTR_ERR_OR_ZERO()' rather than 'IS_ERR(...) ? PTR_ERR(...) : 0'.
>
> Signed-off-by: Geyslan G. Bem <geyslan@gmail.com>
> ---
>  fs/nfs/callback.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
>
> diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
> index 67cd732..073b4cf 100644
> --- a/fs/nfs/callback.c
> +++ b/fs/nfs/callback.c
> @@ -164,8 +164,7 @@ nfs41_callback_up(struct svc_serv *serv)
>                 svc_xprt_put(serv->sv_bc_xprt);
>                 serv->sv_bc_xprt = NULL;
>         }
> -       dprintk("--> %s return %ld\n", __func__,
> -               IS_ERR(rqstp) ? PTR_ERR(rqstp) : 0);
> +       dprintk("--> %s return %d\n", __func__, PTR_ERR_OR_ZERO(rqstp));
>         return rqstp;
>  }
>
> --
> 1.8.4
>
In this version (v2):
Format changed from %ld to %d.
