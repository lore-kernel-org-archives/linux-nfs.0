Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f179.google.com ([209.85.216.179]:48072 "EHLO
	mail-qc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933139Ab3JNUdS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Oct 2013 16:33:18 -0400
MIME-Version: 1.0
In-Reply-To: <1381782256-2434-2-git-send-email-geyslan@gmail.com>
References: <1381782256-2434-1-git-send-email-geyslan@gmail.com>
	<1381782256-2434-2-git-send-email-geyslan@gmail.com>
Date: Mon, 14 Oct 2013 17:33:17 -0300
Message-ID: <CAGG-pUTZGHjzVYj2r0Df_ehUz27FL8=bPCQ5FMBxScN-NNTO2A@mail.gmail.com>
Subject: Re: [PATCH v2] nfs: Use PTR_ERR_OR_ZERO in 'nfs/nfs4super.c'
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
>  fs/nfs/nfs4super.c | 12 ++++++------
>  1 file changed, 6 insertions(+), 6 deletions(-)
>
> diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
> index e26acdd..65ab0a0 100644
> --- a/fs/nfs/nfs4super.c
> +++ b/fs/nfs/nfs4super.c
> @@ -261,9 +261,9 @@ struct dentry *nfs4_try_mount(int flags, const char *dev_name,
>
>         res = nfs_follow_remote_path(root_mnt, export_path);
>
> -       dfprintk(MOUNT, "<-- nfs4_try_mount() = %ld%s\n",
> -                       IS_ERR(res) ? PTR_ERR(res) : 0,
> -                       IS_ERR(res) ? " [error]" : "");
> +       dfprintk(MOUNT, "<-- nfs4_try_mount() = %d%s\n",
> +                PTR_ERR_OR_ZERO(res),
> +                IS_ERR(res) ? " [error]" : "");
>         return res;
>  }
>
> @@ -319,9 +319,9 @@ static struct dentry *nfs4_referral_mount(struct file_system_type *fs_type,
>         data->mnt_path = export_path;
>
>         res = nfs_follow_remote_path(root_mnt, export_path);
> -       dprintk("<-- nfs4_referral_mount() = %ld%s\n",
> -                       IS_ERR(res) ? PTR_ERR(res) : 0,
> -                       IS_ERR(res) ? " [error]" : "");
> +       dprintk("<-- nfs4_referral_mount() = %d%s\n",
> +               PTR_ERR_OR_ZERO(res),
> +               IS_ERR(res) ? " [error]" : "");
>         return res;
>  }
>
> --
> 1.8.4
>

In this version (v2):
Format changed from %ld to %d.
