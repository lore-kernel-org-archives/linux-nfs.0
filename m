Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f41.google.com ([209.85.216.41]:63074 "EHLO
	mail-qa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750728AbbASNR4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Jan 2015 08:17:56 -0500
Received: by mail-qa0-f41.google.com with SMTP id bm13so23798664qab.0
        for <linux-nfs@vger.kernel.org>; Mon, 19 Jan 2015 05:17:56 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1421658911-18671-1-git-send-email-tao.peng@primarydata.com>
References: <1421658911-18671-1-git-send-email-tao.peng@primarydata.com>
Date: Mon, 19 Jan 2015 08:17:55 -0500
Message-ID: <CAABAsM7BTSjd04CzPXp15kwAc5ZJWEKL3OnZd-4izecDxD=Whg@mail.gmail.com>
Subject: Re: [PATCH v2] nfs: fix dio deadlock when O_DIRECT flag is flipped
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Peng Tao <tao.peng@primarydata.com>
Cc: linux-nfs@vger.kernel.org, Christoph Hellwig <hch@infradead.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Tao,

On Mon, Jan 19, 2015 at 4:15 AM, Peng Tao <tao.peng@primarydata.com> wrote:
> Running xfstest generic/036, we hit VM_BUG_ON() in nfs_direct_IO().
> 036 toggles O_DIRECT flag while IO is going on. We cannot simply remove
> the VM_BUG_ON() there because we'll have a deadlock in the code path.
> inode->i_mutex is taken when calling into ->direct_IO.
> And nfs_file_direct_write() would grab inode->i_mutex again.
>
> nfs_file_write() and generic_file_write_iter() checks for O_DIRECT twice,
> and it creates a race window if user space is playing with O_DIRECT flag.
> Fix it by calling generic_perform_write() instead, so that nfs_direct_IO()
> is only invoked in swap on nfs case.
>
> Suggested-by: Christoph Hellwig <hch@infradead.org>
> Signed-off-by: Peng Tao <tao.peng@primarydata.com>
> ---
>  fs/nfs/file.c | 41 ++++++++++++++++++++++++++++++++++++++++-
>  1 file changed, 40 insertions(+), 1 deletion(-)
>
> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> index 2ab6f00..e98604a 100644
> --- a/fs/nfs/file.c
> +++ b/fs/nfs/file.c
> @@ -662,6 +662,45 @@ static int nfs_need_sync_write(struct file *filp, struct inode *inode)
>         return 0;
>  }
>
> +static ssize_t nfs_file_buffer_write(struct kiocb *iocb, struct iov_iter *from)
> +{
> +       struct file *file = iocb->ki_filp;
> +       struct address_space *mapping = file->f_mapping;
> +       struct inode *inode = mapping->host;
> +       ssize_t result = 0;
> +       size_t count = iov_iter_count(from);
> +       loff_t pos = iocb->ki_pos;
> +       int ret;
> +
> +       mutex_lock(&inode->i_mutex);
> +       /* We can write back this queue in page reclaim */
> +       current->backing_dev_info = mapping->backing_dev_info;
> +       ret = generic_write_checks(file, &pos, &count, 0);
> +       if (ret)
> +               goto out;
> +
> +       if (!count)
> +               goto out;
> +
> +       iov_iter_truncate(from, count);
> +       ret = file_remove_suid(file);
> +       if (ret)
> +               goto out;
> +
> +       ret = file_update_time(file);
> +       if (ret)
> +               goto out;
> +
> +       result = generic_perform_write(file, from, pos);
> +       if (likely(result >= 0))
> +               iocb->ki_pos = pos + result;
> +
> +out:
> +       current->backing_dev_info = NULL;
> +       mutex_unlock(&inode->i_mutex);
> +       return result ? result : ret;
> +}
> +
>  ssize_t nfs_file_write(struct kiocb *iocb, struct iov_iter *from)
>  {
>         struct file *file = iocb->ki_filp;
> @@ -697,7 +736,7 @@ ssize_t nfs_file_write(struct kiocb *iocb, struct iov_iter *from)
>         if (!count)
>                 goto out;
>
> -       result = generic_file_write_iter(iocb, from);
> +       result = nfs_file_buffer_write(iocb, from);
>         if (result > 0)
>                 written = result;
>

I still haven't got an answer to my question as to why we need to do
all this if we don't actually want anything other than the swapfile
code to use nfs_direct_IO(}? The xfstest with toggling O_DIRECT at
random doesn't reflect any sane behaviour that we want to support; all
we want to do is ensure that it doesn't deadlock. Why wouldn't the
proposal that we add a line to return '0' if !IS_SWAPFILE(inode)
suffice?

Cheers
  Trond
