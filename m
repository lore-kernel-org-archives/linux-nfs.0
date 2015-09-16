Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:36192 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752931AbbIPUwe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Sep 2015 16:52:34 -0400
Received: by obqa2 with SMTP id a2so159719761obq.3
        for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2015 13:52:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1442429367.24127.6.camel@localhost.localdomain>
References: <1442429367.24127.6.camel@localhost.localdomain>
Date: Wed, 16 Sep 2015 16:52:34 -0400
Message-ID: <CAHQdGtSWaeAyjeKFV5AxJPou_94esPnso5sQrA=wfep6m5qP5Q@mail.gmail.com>
Subject: Re: [PATCH] Use a separate superblock if mount requires a different
 security flavor
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Frank Filz <ffilzlnx@mindspring.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 16, 2015 at 2:49 PM, Frank Filz <ffilzlnx@mindspring.com> wrote:
> If a server has two exports from the same filesystem but with different
> security flavors allowed, when the client mounts first one and then the
> second, the same super block was being used. This resulted in the
> security flavor for the first export being applied to access to the
> second export.
>
> The fix is simply to check the security flavor of the nfs_server
> temporarily constructed for the second mount within nfs_compare_super.
>
> Signed-off-by: Frank S. Filz <ffilzlnx@mindspring.com>
> ---
>  fs/nfs/super.c | 3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index 084af10..44d60f1 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -2455,6 +2455,9 @@ static int nfs_compare_super(struct super_block
> *sb, void *data)
>         struct nfs_server *server = sb_mntdata->server, *old =
> NFS_SB(sb);
>         int mntflags = sb_mntdata->mntflags;
>
> +       if(old->client->cl_auth->au_flavor
> +          != server->client->cl_auth->au_flavor)
> +               return 0;

Isn't this check already being performed in
nfs_compare_mount_options()? As far as I can see, the difference is
that you are checking unconditionally, whereas
nfs_compare_mount_options only does so if there was a 'sec=' line
specified in the mount options.

Cheers
  Trond
