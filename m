Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:33555 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964799AbbJ0ROM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Oct 2015 13:14:12 -0400
MIME-Version: 1.0
In-Reply-To: <1445728636-10109-3-git-send-email-tao.peng@primarydata.com>
References: <1445728636-10109-1-git-send-email-tao.peng@primarydata.com> <1445728636-10109-3-git-send-email-tao.peng@primarydata.com>
From: Steve French <smfrench@gmail.com>
Date: Tue, 27 Oct 2015 12:13:52 -0500
Message-ID: <CAH2r5mt1e5LigOh4Xyj5NCFUrSjTOajKjeYZsR2mE1rHE93uKg@mail.gmail.com>
Subject: Re: [PATCH 2/9] cifs: add .copy_file_range file operation
To: Peng Tao <tao.peng@primarydata.com>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Christoph Hellwig <hch@infradead.org>, Zach Brown <zab@zabbo.net>,
        Darren Hart <dvhart@linux.intel.com>,
        Jeff Layton <jeff.layton@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-btrfs@vger.kernel.org,
        "linux-cifs@vger.kernel.org" <linux-cifs@vger.kernel.org>,
        Steve French <steve.french@primarydata.com>,
        samba-technical <samba-technical@lists.samba.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Patch looks fine, but it points out a Kconfig problem with cifs.ko.
Need to remove the

         #ifdef CONFIG_CIFS_POSIX

around the statements like:

         .unlocked_ioctl = cifs_ioctl,
         .copy_file_range = cifs_file_copy_range,

Copy offload does not require support for the old CIFS POSIX
extensions (or even cifs at all) - it works fine over SMB3.
Alternatively you can move the copy_file_range to the end of the
struct file_operations in your patch, and I can remove the
CONFIG_CIFS_POSIX around cifs_ioctl in a different patch that I put in
my tree - whichever you prefer.

Originally the first ioctl that cifs supported did require the CIFS
POSIX extensions because it used an info level defined in the CIFS
UNIX/POSIX extensions.  With later additions to cifs_ioctl that
restriction is now obsolete.  Later ioctls have been added that work
over SMB3, and do not require the CIFS POSIX extensions (such as copy
offload).   The patch that originally introduced the CIFS_POSIX ifdef
around this ioctl was

commit c67593a03129967eae8939c4899767182eb6d6cd
Author: Steve French <smfrench@austin.rr.com>
Date:   Thu Apr 28 22:41:04 2005 -0700

    [PATCH] cifs: Enable ioctl support in POSIX extensions to handle lsattr

but obviously now we don't need the CONFIG_CIFS_POSIX ifdef around the
ioctl functions.

On Sat, Oct 24, 2015 at 6:17 PM, Peng Tao <tao.peng@primarydata.com> wrote:
> Signed-off-by: Peng Tao <tao.peng@primarydata.com>
> ---
>  fs/cifs/cifsfs.c |  22 ++++++++++++
>  fs/cifs/cifsfs.h |   4 ++-
>  fs/cifs/ioctl.c  | 100 +++++++++++++++++++++++++++++++------------------------
>  3 files changed, 82 insertions(+), 44 deletions(-)
>
> diff --git a/fs/cifs/cifsfs.c b/fs/cifs/cifsfs.c
> index e739950..6ef7c3c 100644
> --- a/fs/cifs/cifsfs.c
> +++ b/fs/cifs/cifsfs.c
> @@ -910,6 +910,22 @@ const struct inode_operations cifs_symlink_inode_ops = {
>  #endif
>  };
>
> +#ifdef CONFIG_CIFS_POSIX
> +ssize_t cifs_file_copy_range(struct file *file_in, loff_t pos_in,
> +                            struct file *file_out, loff_t pos_out,
> +                            size_t len, unsigned int flags)
> +{
> +       unsigned int xid;
> +       int rc;
> +
> +       xid = get_xid();
> +       rc = cifs_file_clone_range(xid, file_in, file_out, pos_in,
> +                                  len, pos_out, true);
> +       free_xid(xid);
> +       return rc < 0 ? rc : len;
> +}
> +#endif
> +
>  const struct file_operations cifs_file_ops = {
>         .read_iter = cifs_loose_read_iter,
>         .write_iter = cifs_file_write_iter,
> @@ -923,6 +939,7 @@ const struct file_operations cifs_file_ops = {
>         .llseek = cifs_llseek,
>  #ifdef CONFIG_CIFS_POSIX
>         .unlocked_ioctl = cifs_ioctl,
> +       .copy_file_range = cifs_file_copy_range,
>  #endif /* CONFIG_CIFS_POSIX */
>         .setlease = cifs_setlease,
>         .fallocate = cifs_fallocate,
> @@ -941,6 +958,7 @@ const struct file_operations cifs_file_strict_ops = {
>         .llseek = cifs_llseek,
>  #ifdef CONFIG_CIFS_POSIX
>         .unlocked_ioctl = cifs_ioctl,
> +       .copy_file_range = cifs_file_copy_range,
>  #endif /* CONFIG_CIFS_POSIX */
>         .setlease = cifs_setlease,
>         .fallocate = cifs_fallocate,
> @@ -959,6 +977,7 @@ const struct file_operations cifs_file_direct_ops = {
>         .splice_read = generic_file_splice_read,
>  #ifdef CONFIG_CIFS_POSIX
>         .unlocked_ioctl  = cifs_ioctl,
> +       .copy_file_range = cifs_file_copy_range,
>  #endif /* CONFIG_CIFS_POSIX */
>         .llseek = cifs_llseek,
>         .setlease = cifs_setlease,
> @@ -977,6 +996,7 @@ const struct file_operations cifs_file_nobrl_ops = {
>         .llseek = cifs_llseek,
>  #ifdef CONFIG_CIFS_POSIX
>         .unlocked_ioctl = cifs_ioctl,
> +       .copy_file_range = cifs_file_copy_range,
>  #endif /* CONFIG_CIFS_POSIX */
>         .setlease = cifs_setlease,
>         .fallocate = cifs_fallocate,
> @@ -994,6 +1014,7 @@ const struct file_operations cifs_file_strict_nobrl_ops = {
>         .llseek = cifs_llseek,
>  #ifdef CONFIG_CIFS_POSIX
>         .unlocked_ioctl = cifs_ioctl,
> +       .copy_file_range = cifs_file_copy_range,
>  #endif /* CONFIG_CIFS_POSIX */
>         .setlease = cifs_setlease,
>         .fallocate = cifs_fallocate,
> @@ -1011,6 +1032,7 @@ const struct file_operations cifs_file_direct_nobrl_ops = {
>         .splice_read = generic_file_splice_read,
>  #ifdef CONFIG_CIFS_POSIX
>         .unlocked_ioctl  = cifs_ioctl,
> +       .copy_file_range = cifs_file_copy_range,
>  #endif /* CONFIG_CIFS_POSIX */
>         .llseek = cifs_llseek,
>         .setlease = cifs_setlease,


Patch looks fine, but it points out a Kconfig problem with cifs.ko.
Need to remove the

#ifdef CONFIG_CIFS_POSIX

around the

         .unlocked_ioctl = cifs_ioctl,
         .copy_file_range = cifs_file_copy_range,

statements.  Alternatively you can move the copy_file_range to the end
of the struct file_operations in your patch, and I can remove the
CONFIG_CIFS_POSIX around cifs_ioctl in a different patch that I put in
my tree - whichever you prefer.

Originally the first ioctl that cifs supported did require the CIFS
POSIX extensions because it used an info level defined in the CIFS
UNIX/POSIX extensions.  With later additions to cifs_ioctl that
restriction is now obsolete.  Later ioctls have been added that work
over SMB3, and do not require the CIFS POSIX extensions (such as copy
offload).  See patch

-- 
Thanks,

Steve
