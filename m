Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:33609 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752474AbcBVPec (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Feb 2016 10:34:32 -0500
Received: by mail-ob0-f174.google.com with SMTP id jq7so168136741obb.0
        for <linux-nfs@vger.kernel.org>; Mon, 22 Feb 2016 07:34:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1456154274-30487-9-git-send-email-deepa.kernel@gmail.com>
References: <1456154274-30487-1-git-send-email-deepa.kernel@gmail.com>
	<1456154274-30487-9-git-send-email-deepa.kernel@gmail.com>
Date: Mon, 22 Feb 2016 10:34:31 -0500
Message-ID: <CAHQdGtR26gqy7GzWui-bnb+W5W1PnUL_=okBZwz+XFmj_Q4A3A@mail.gmail.com>
Subject: Re: [PATCH 8/8] net: sunrpc: Replace CURRENT_TIME by current_fs_time()
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Deepa Dinamani <deepa.kernel@gmail.com>
Cc: Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        y2038@lists.linaro.org, Arnd Bergmann <arnd@arndb.de>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Network Devel Mailing List <netdev@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 22, 2016 at 10:17 AM, Deepa Dinamani <deepa.kernel@gmail.com> wrote:
>
> CURRENT_TIME macro is not appropriate for filesystems as it
> doesn't use the right granularity for filesystem timestamps.
> Use current_fs_time() instead.
>
> Signed-off-by: Deepa Dinamani <deepa.kernel@gmail.com>
> Cc: "J. Bruce Fields" <bfields@fieldses.org>
> Cc: Jeff Layton <jlayton@poochiereds.net>
> Cc: Trond Myklebust <trond.myklebust@primarydata.com>
> Cc: Anna Schumaker <anna.schumaker@netapp.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: linux-nfs@vger.kernel.org
> Cc: netdev@vger.kernel.org
> ---
>  net/sunrpc/rpc_pipe.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
>
> diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
> index 31789ef..bab3187 100644
> --- a/net/sunrpc/rpc_pipe.c
> +++ b/net/sunrpc/rpc_pipe.c
> @@ -477,7 +477,9 @@ rpc_get_inode(struct super_block *sb, umode_t mode)
>                 return NULL;
>         inode->i_ino = get_next_ino();
>         inode->i_mode = mode;
> -       inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
> +       inode->i_atime = current_fs_time(sb);
> +       inode->i_mtime = inode->i_atime;
> +       inode->i_ctime = inode->i_atime;
>         switch (mode & S_IFMT) {
>         case S_IFDIR:
>                 inode->i_fop = &simple_dir_operations;

Why would we care? This is a pseudo-fs. There is no expectation w.r.t.
timestamp accuracy or resolution.

Cheers,
  Trond
