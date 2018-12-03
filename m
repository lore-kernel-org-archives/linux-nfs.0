Return-Path: <SRS0=4jnv=OM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EF900C04EBF
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 10:03:54 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AD65220850
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 10:03:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="bGfyioR5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AD65220850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726154AbeLCKEO (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 3 Dec 2018 05:04:14 -0500
Received: from mail-yw1-f68.google.com ([209.85.161.68]:40447 "EHLO
        mail-yw1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725901AbeLCKEO (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Dec 2018 05:04:14 -0500
Received: by mail-yw1-f68.google.com with SMTP id r130so5131251ywg.7;
        Mon, 03 Dec 2018 02:03:53 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=CkPp3VOFgkD/i1HVkd1bxdKx2PAFg8dAJ6ulDFpsGH4=;
        b=bGfyioR55qyfTZOxz+YVGLJDyWGfwU/MmQo4bWru3WwFtjKA0ntiokMzybyvu30+uA
         gIqB00FM8Ks9Jhjl6KZ8vbFfrtjjcYU6s4c2RF/1OqoD3GG17ZYttfqkR7QWS0YxTROh
         mSnelGw/cp6puEhSBRxK+XAN9lUDyzklCmAVR/jTTKy35bszrL3NGN9On9U5sua/KkGy
         nMyYH30NvMExE5cqK6N409AhR0cawvQRsyY/vc/3PNSu9qw17rH679c31IjwgUI50NAl
         CWA4G99x/S5ybFsCOslLnj35w3rlJsn+vJhzfBmdbUYlH+mEPiW2tEp57HLVqPTNYHkY
         hBqA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=CkPp3VOFgkD/i1HVkd1bxdKx2PAFg8dAJ6ulDFpsGH4=;
        b=gqNs0g0y1CqxcyfnlOBDD59FN34NgNWmEXrWowmQcP/Gy31slVWO6sXkV4cc/v5Msz
         bINlsTfeGIbuK0aFu49nQsJjuVzWKFciEtN6Qm6Eloyu5emD+C2ju27qUouIxZv8Npyn
         zd/ybn/eBHKjjrgslY9hGruEBaONak2SjPQn/JFdWnw1UF7IGdhfG1P4zEFdU3sTpM4R
         PssTGi7h2Yooi07TWAvcJCZPicSTc/KsU9xvZsXu2QbbktJ4zo2ffSwVb/5y1PusR5JH
         al7Zx8at2E9UHsj3GkzXpvvxRBHD7GvCgYXONTL2vTnPlnwM7q4n+kQ0q8UVLovw0BAc
         dpiQ==
X-Gm-Message-State: AA+aEWbrGFdKudA7TRP5FqOU2EUV7A1IKlSckZ0AY0Bwu6xODYee8PZR
        fHeL1G4il0brxNNO2XERuiQEEuJHxu+vCDUPXLY=
X-Google-Smtp-Source: AFSGD/WHltBfJAi/FP+PUEguscS6Sh3zVMlrnGny+N0avpybJ2oNck8A4nu3xYV8J9dlPRpo5wCmlCNeNgNM7++g8g4=
X-Received: by 2002:a81:34d3:: with SMTP id b202mr15078459ywa.241.1543831432320;
 Mon, 03 Dec 2018 02:03:52 -0800 (PST)
MIME-Version: 1.0
References: <20181203083416.28978-1-david@fromorbit.com> <20181203083416.28978-3-david@fromorbit.com>
In-Reply-To: <20181203083416.28978-3-david@fromorbit.com>
From:   Amir Goldstein <amir73il@gmail.com>
Date:   Mon, 3 Dec 2018 12:03:41 +0200
Message-ID: <CAOQ4uxiSjmmm5OBx+K5qff4mtL5jSih71izWGQKjA_WQSLe=AA@mail.gmail.com>
Subject: Re: [PATCH 02/11] vfs: introduce generic_copy_file_range()
To:     Dave Chinner <david@fromorbit.com>
Cc:     linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-xfs <linux-xfs@vger.kernel.org>,
        Olga Kornievskaia <olga.kornievskaia@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        overlayfs <linux-unionfs@vger.kernel.org>,
        ceph-devel@vger.kernel.org, linux-cifs@vger.kernel.org,
        Miklos Szeredi <miklos@szeredi.hu>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Dec 3, 2018 at 10:34 AM Dave Chinner <david@fromorbit.com> wrote:
>
> From: Dave Chinner <dchinner@redhat.com>
>
> Right now if vfs_copy_file_range() does not use any offload
> mechanism, it falls back to calling do_splice_direct(). This fails
> to do basic sanity checks on the files being copied. Before we
> start adding this necessarily functionality to the fallback path,
> separate it out into generic_copy_file_range().
>
> generic_copy_file_range() has the same prototype as
> ->copy_file_range() so that filesystems can use it in their custom
> ->copy_file_range() method if they so choose.
>
> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> ---

Looks good.

Reviewed-by: Amir Goldstein <amir73il@gmail.com>

Question:
2 years ago you suggested that I covert the overlayfs copy up
code that does a do_direct_splice() with a loop of vfs_copy_file_range():
https://marc.info/?l=linux-fsdevel&m=147369468521525&w=2
We ended up with a slightly different solution, but with your recent
changes, I can get back to your original proposal.

Back then, I wondered whether it makes sense to push the killable
loop of shorter do_direct_splice() calls into the vfs helper.
What do you think about adding this to generic_copy_file_range()
now? (I can do that after your changes are merged).

The fact that userspace *can* enter a very long unkillable loop
with current copy_file_range() syscall doesn't mean that we
*should* persist this situation. After all, fixing the brokenness
of the existing interface is what you set out to do.

With that change in place, overlayfs could call only
vfs_copy_file_range() as you suggested and not as a fallback to
do_clone_file_range().

Thanks,
Amir.

>  fs/read_write.c    | 35 ++++++++++++++++++++++++++++++++---
>  include/linux/fs.h |  3 +++
>  2 files changed, 35 insertions(+), 3 deletions(-)
>
> diff --git a/fs/read_write.c b/fs/read_write.c
> index 09d1816cf3cf..50114694c98b 100644
> --- a/fs/read_write.c
> +++ b/fs/read_write.c
> @@ -1540,6 +1540,36 @@ COMPAT_SYSCALL_DEFINE4(sendfile64, int, out_fd, int, in_fd,
>  }
>  #endif
>
> +/**
> + * generic_copy_file_range - copy data between two files
> + * @file_in:   file structure to read from
> + * @pos_in:    file offset to read from
> + * @file_out:  file structure to write data to
> + * @pos_out:   file offset to write data to
> + * @len:       amount of data to copy
> + * @flags:     copy flags
> + *
> + * This is a generic filesystem helper to copy data from one file to another.
> + * It has no constraints on the source or destination file owners - the files
> + * can belong to different superblocks and different filesystem types. Short
> + * copies are allowed.
> + *
> + * This should be called from the @file_out filesystem, as per the
> + * ->copy_file_range() method.
> + *
> + * Returns the number of bytes copied or a negative error indicating the
> + * failure.
> + */
> +
> +ssize_t generic_copy_file_range(struct file *file_in, loff_t pos_in,
> +                           struct file *file_out, loff_t pos_out,
> +                           size_t len, unsigned int flags)
> +{
> +       return do_splice_direct(file_in, &pos_in, file_out, &pos_out,
> +                       len > MAX_RW_COUNT ? MAX_RW_COUNT : len, 0);
> +}
> +EXPORT_SYMBOL(generic_copy_file_range);
> +
>  /*
>   * copy_file_range() differs from regular file read and write in that it
>   * specifically allows return partial success.  When it does so is up to
> @@ -1611,9 +1641,8 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
>                         goto done;
>         }
>
> -       ret = do_splice_direct(file_in, &pos_in, file_out, &pos_out,
> -                       len > MAX_RW_COUNT ? MAX_RW_COUNT : len, 0);
> -
> +       ret = generic_copy_file_range(file_in, &pos_in, file_out, &pos_out,
> +                                       len, flags);
>  done:
>         if (ret > 0) {
>                 fsnotify_access(file_in);
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index c95c0807471f..a4478764cf63 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -1874,6 +1874,9 @@ extern ssize_t vfs_readv(struct file *, const struct iovec __user *,
>                 unsigned long, loff_t *, rwf_t);
>  extern ssize_t vfs_copy_file_range(struct file *, loff_t , struct file *,
>                                    loff_t, size_t, unsigned int);
> +extern ssize_t generic_copy_file_range(struct file *file_in, loff_t pos_in,
> +                               struct file *file_out, loff_t pos_out,
> +                               size_t len, unsigned int flags);
>  extern int generic_remap_file_range_prep(struct file *file_in, loff_t pos_in,
>                                          struct file *file_out, loff_t pos_out,
>                                          loff_t *count,
> --
> 2.19.1
>
