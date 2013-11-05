Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-la0-f45.google.com ([209.85.215.45]:39078 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750732Ab3KEDAZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Nov 2013 22:00:25 -0500
MIME-Version: 1.0
In-Reply-To: <1383614186-8039-1-git-send-email-jlayton@redhat.com>
References: <1383614186-8039-1-git-send-email-jlayton@redhat.com>
Date: Mon, 4 Nov 2013 21:00:23 -0600
Message-ID: <CADT32eJ_cqej0wnjKOZk1x0UtRqoNy201hFt8hQLLShjcbp3Dg@mail.gmail.com>
Subject: Re: [PATCH] [RFC] vfs: don't revalidate dentries that serve as mountpoints
From: Shirish Pargaonkar <shirishpargaonkar@gmail.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: viro@zeniv.linux.org.uk, linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
        chutzpah@gentoo.org, liguangc@cn.ibm.com
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For a similar issue in cifs vfs (samba bugzilla 8950), I was going to try
unset the bit DCACHE_OP_REVALIDATE of d_flags of the
dentry.  Would something like work for the mountpoint dentry?



On Mon, Nov 4, 2013 at 7:16 PM, Jeff Layton <jlayton@redhat.com> wrote:
> We had a couple of reports of people that are mounting NFS filesystems,
> and then bind mounting certain local files onto dentries in that nfs
> mount (sort of like a poor-man's unionmount).
>
> This all works well until the dentry serving as the mountpoint fails
> d_revalidate. The dentry will end up being invalidated which makes the
> bind mount unreachable via pathwalk.
>
> It doesn't make much sense to me to allow dentries to serve as
> mountpoints to end up invalidated, so there's no real point in
> attempting to d_revalidate them at all.
>
> Reported-by: Patrick McLean <chutzpah@gentoo.org>
> Reported-by: Guang Cheng Li <liguangc@cn.ibm.com>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/namei.c | 3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/fs/namei.c b/fs/namei.c
> index caa2805..5b10ad0 100644
> --- a/fs/namei.c
> +++ b/fs/namei.c
> @@ -585,6 +585,9 @@ drop_root_mnt:
>
>  static inline int d_revalidate(struct dentry *dentry, unsigned int flags)
>  {
> +       /* dentries that serve as mountpoints are always considered valid */
> +       if (d_mountpoint(dentry))
> +               return 1;
>         return dentry->d_op->d_revalidate(dentry, flags);
>  }
>
> --
> 1.8.3.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
