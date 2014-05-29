Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ve0-f172.google.com ([209.85.128.172]:62155 "EHLO
	mail-ve0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932372AbaE2Rd1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 May 2014 13:33:27 -0400
Received: by mail-ve0-f172.google.com with SMTP id oz11so776542veb.17
        for <linux-nfs@vger.kernel.org>; Thu, 29 May 2014 10:33:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1401384351-21993-2-git-send-email-smayhew@redhat.com>
References: <1401384351-21993-1-git-send-email-smayhew@redhat.com>
	<1401384351-21993-2-git-send-email-smayhew@redhat.com>
Date: Thu, 29 May 2014 13:33:26 -0400
Message-ID: <CAHQdGtRzQVWHov8q6Ywzh2CGzcS5niEVLg7LuHmZFr6EjZbSUw@mail.gmail.com>
Subject: Re: [PATCH 1/1] nfs: Ensure NFS_MOUNT_TCP is correctly set for v4 mounts
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Scott Mayhew <smayhew@redhat.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 29, 2014 at 1:25 PM, Scott Mayhew <smayhew@redhat.com> wrote:
> The NFS_MOUNT_TCP flag needs to be correctly set in the nfs_server->flags
> field, otherwise remount operations are likely to run afoul of the flags
> check in nfs_compare_remount_data() on systems where /etc/mtab is
> symlinked to /proc/mounts.
>
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> ---
>  fs/nfs/super.c | 3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index 2cb5694..0ae4e73 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -2726,6 +2726,9 @@ static void nfs4_validate_mount_flags(struct nfs_parsed_mount_data *args)
>  {
>         args->flags &= ~(NFS_MOUNT_NONLM|NFS_MOUNT_NOACL|NFS_MOUNT_VER3|
>                          NFS_MOUNT_LOCAL_FLOCK|NFS_MOUNT_LOCAL_FCNTL);
> +
> +       if (args->nfs_server.protocol == XPRT_TRANSPORT_TCP)
> +               args->flags |= NFS_MOUNT_TCP;
>  }
>
>  /*
> --
> 1.9.0
>

Hi Scott,

Why can't we just apply the NFS_MOUNT_CMP_FLAGMASK to
nfs_compare_remount_data? NFS_MOUNT_TCP really is just legacy crud
from the bad old days of binary mount structures.

Cheers
  Trond

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
