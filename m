Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f52.google.com ([209.85.161.52]:58136 "EHLO
	mail-fx0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752833Ab1GVNcm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Jul 2011 09:32:42 -0400
From: Miklos Szeredi <miklos@szeredi.hu>
To: Anand Avati <avati@gluster.com>
Cc: <fuse-devel@lists.sourceforge.net>, <linux-fsdevel@vger.kernel.org>,
        <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/2] fuse: permit O_DIRECT flag in open()
References: <1311323606-15040-1-git-send-email-avati@gluster.com>
	<1311323606-15040-2-git-send-email-avati@gluster.com>
Date: Fri, 22 Jul 2011 15:33:36 +0200
In-Reply-To: <1311323606-15040-2-git-send-email-avati@gluster.com> (Anand
	Avati's message of "Fri, 22 Jul 2011 01:33:26 -0700")
Message-ID: <87livqfnin.fsf@tucsk.pomaz.szeredi.hu>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Anand Avati <avati@gluster.com> writes:

> but do not permit setting of O_DIRECT flag via fcntl() (or unsetting)

Again, some more verbose description would be good, as well as a
Signed-off-by.

> ---
>  fs/fuse/file.c |   27 +++++++++++++++++++++++----
>  1 files changed, 23 insertions(+), 4 deletions(-)
>
> diff --git a/fs/fuse/file.c b/fs/fuse/file.c
> index 82a6646..f30a7c6 100644
> --- a/fs/fuse/file.c
> +++ b/fs/fuse/file.c
> @@ -154,6 +154,18 @@ int fuse_do_open(struct fuse_conn *fc, u64 nodeid, struct file *file,
>  		return err;
>  	}
>  
> +        if (file->f_flags & O_DIRECT) {

Please use tabs, not spaces.

Before submission you should run your patch through
scripts/checkpatch.pl to filter out such problems.

> +                /* set fuse_direct_io_file_operations as fops in
> +                   fuse_finish_open as though the FS enforced direct_io
> +                */
> +                outarg.open_flags |= FOPEN_DIRECT_IO;

As I said earlier, I don't like this.  Rather the userspace filesystem
should set FOPEN_DIRECT_IO on O_DIRECT if it wants to.

And if the userspace filesystem has not set FOPEN_DIRECT_IO and O_DIRECT
is set then we should return -EINVAL.

Thanks,
Miklos

> +
> +                /* make VFS believe we don't support O_DIRECT till we
> +                   implement a_ops->direct_IO
> +                */
> +                file->f_flags &= ~O_DIRECT;
> +        }
> +
>  	if (isdir)
>  		outarg.open_flags &= ~FOPEN_DIRECT_IO;
>  
> @@ -193,10 +205,6 @@ int fuse_open_common(struct inode *inode, struct file *file, bool isdir)
>  	struct fuse_conn *fc = get_fuse_conn(inode);
>  	int err;
>  
> -	/* VFS checks this, but only _after_ ->open() */
> -	if (file->f_flags & O_DIRECT)
> -		return -EINVAL;
> -
>  	err = generic_file_open(inode, file);
>  	if (err)
>  		return err;
> @@ -2132,6 +2140,15 @@ int fuse_notify_poll_wakeup(struct fuse_conn *fc,
>  	return 0;
>  }
>  
> +
> +static int fuse_check_flags(struct file *filp, int flags)
> +{
> +        if ((filp->f_flags ^ flags) & O_DIRECT)
> +                return -EINVAL;
> +	return 0;
> +}
> +
> +
>  static const struct file_operations fuse_file_operations = {
>  	.llseek		= fuse_file_llseek,
>  	.read		= do_sync_read,
> @@ -2149,6 +2166,7 @@ static const struct file_operations fuse_file_operations = {
>  	.unlocked_ioctl	= fuse_file_ioctl,
>  	.compat_ioctl	= fuse_file_compat_ioctl,
>  	.poll		= fuse_file_poll,
> +        .check_flags    = fuse_check_flags,
>  };
>  
>  static const struct file_operations fuse_direct_io_file_operations = {
> @@ -2165,6 +2183,7 @@ static const struct file_operations fuse_direct_io_file_operations = {
>  	.unlocked_ioctl	= fuse_file_ioctl,
>  	.compat_ioctl	= fuse_file_compat_ioctl,
>  	.poll		= fuse_file_poll,
> +        .check_flags    = fuse_check_flags,
>  	/* no splice_read */
>  };
