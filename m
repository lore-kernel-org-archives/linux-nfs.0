Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:43807 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750755Ab1IPQhx convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Sep 2011 12:37:53 -0400
Received: by wwf22 with SMTP id 22so5323684wwf.1
        for <linux-nfs@vger.kernel.org>; Fri, 16 Sep 2011 09:37:52 -0700 (PDT)
In-Reply-To: <1316189659-8799-6-git-send-email-rees@umich.edu>
References: <1316189659-8799-1-git-send-email-rees@umich.edu> <1316189659-8799-6-git-send-email-rees@umich.edu>
From: Peng Tao <bergwolf@gmail.com>
Date: Sat, 17 Sep 2011 00:37:31 +0800
Message-ID: <CA+a=Yy5M=rE=KSkpAjj9139kf0oEGuwuFOKBvVR52S0tmDupuA@mail.gmail.com>
Subject: Re: [PATCH 5/5] pnfsblock: add missing rpc_put_mount and path_put
To: Jim Rees <rees@umich.edu>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        peter honeyman <honey@citi.umich.edu>,
        Jeff Layton <jlayton@redhat.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, Sep 17, 2011 at 12:14 AM, Jim Rees <rees@umich.edu> wrote:
> From: Peng Tao <bergwolf@gmail.com>
>
> Reported-by: Jeff Layton <jlayton@redhat.com>
This should really be
Reviewed-by: Jeff Layton <jlayton@redhat.com>
as Jeff has provided it in his previous mail.

Thanks,
Tao
> Signed-off-by: Peng Tao <peng_tao@emc.com>
> Signed-off-by: Jim Rees <rees@umich.edu>
> ---
>  fs/nfs/blocklayout/blocklayout.c |    8 ++++++--
>  1 files changed, 6 insertions(+), 2 deletions(-)
>
> diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
> index 7aace44..fef125d2 100644
> --- a/fs/nfs/blocklayout/blocklayout.c
> +++ b/fs/nfs/blocklayout/blocklayout.c
> @@ -1000,17 +1000,20 @@ static int __init nfs4blocklayout_init(void)
>                              mnt,
>                              NFS_PIPE_DIRNAME, 0, &path);
>        if (ret)
> -               goto out_remove;
> +               goto out_putrpc;
>
>        bl_device_pipe = rpc_mkpipe(path.dentry, "blocklayout", NULL,
>                                    &bl_upcall_ops, 0);
> +       path_put(&path);
>        if (IS_ERR(bl_device_pipe)) {
>                ret = PTR_ERR(bl_device_pipe);
> -               goto out_remove;
> +               goto out_putrpc;
>        }
>  out:
>        return ret;
>
> +out_putrpc:
> +       rpc_put_mount();
>  out_remove:
>        pnfs_unregister_layoutdriver(&blocklayout_type);
>        return ret;
> @@ -1023,6 +1026,7 @@ static void __exit nfs4blocklayout_exit(void)
>
>        pnfs_unregister_layoutdriver(&blocklayout_type);
>        rpc_unlink(bl_device_pipe);
> +       rpc_put_mount();
>  }
>
>  MODULE_ALIAS("nfs-layouttype4-3");
> --
> 1.7.6
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>



-- 
Thanks,
-Bergwolf
