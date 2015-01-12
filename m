Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f176.google.com ([209.85.220.176]:63884 "EHLO
	mail-vc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751000AbbALXD2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Jan 2015 18:03:28 -0500
Received: by mail-vc0-f176.google.com with SMTP id hq12so7561697vcb.7
        for <linux-nfs@vger.kernel.org>; Mon, 12 Jan 2015 15:03:27 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1421103310-25755-1-git-send-email-king.feruke@gmail.com>
References: <1421103310-25755-1-git-send-email-king.feruke@gmail.com>
Date: Mon, 12 Jan 2015 18:03:27 -0500
Message-ID: <CAHQdGtR-8MHXWVcYun1-_w632miEg7Tfrnih1q9Z_SNYSd=kSw@mail.gmail.com>
Subject: Re: [PATCH] nfs: correct typo in nfs Kconfig
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Kevin Mulvey <king.feruke@gmail.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>,
        Kevin Mulvey <kmulvey@linux.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 12, 2015 at 5:55 PM, Kevin Mulvey <king.feruke@gmail.com> wrote:
> From: Kevin Mulvey <kmulvey@linux.com>
>
> The help section of NFS_V3_ACL currently mentions the "noacl" option
> but the correct syntax is "no_acl".
>
> Signed-off-by: Kevin Mulvey <kmulvey@linux.com>
> ---
>  fs/nfs/Kconfig | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
> index 3dece03..7de164b 100644
> --- a/fs/nfs/Kconfig
> +++ b/fs/nfs/Kconfig
> @@ -65,7 +65,7 @@ config NFS_V3_ACL
>           applications to access and modify ACLs on files on the server.
>
>           Most NFS servers don't support the Solaris NFSv3 ACL protocol
> -         extension.  You can choose N here or specify the "noacl" mount
> +         extension.  You can choose N here or specify the "no_acl" mount
>           option to prevent your NFS client from trying to use the NFSv3
>           ACL protocol.
>

Not in the Linux kernel:
http://lxr.free-electrons.com/source/fs/nfs/super.c#L121


-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
