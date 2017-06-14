Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ot0-f193.google.com ([74.125.82.193]:36315 "EHLO
        mail-ot0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751665AbdFNTci (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Jun 2017 15:32:38 -0400
MIME-Version: 1.0
In-Reply-To: <20170614185335.58193-1-kolga@netapp.com>
References: <5bca6687-ac03-72ef-f38e-6759a0fbb1d6@gmail.com> <20170614185335.58193-1-kolga@netapp.com>
From: Amir Goldstein <amir73il@gmail.com>
Date: Wed, 14 Jun 2017 22:32:37 +0300
Message-ID: <CAOQ4uxhSS1s2ZYZbhzmRdw1N+DS6bc_RFHZSmeeM96uidesmuQ@mail.gmail.com>
Subject: Re: [PATCH 1/1] [RFC] 64bit copy_file_range system call
To: Olga Kornievskaia <kolga@netapp.com>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@lst.de>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 14, 2017 at 9:53 PM, Olga Kornievskaia <kolga@netapp.com> wrote:
>
> This is a proposal to allow 64bit count to copy and return as
> a result of a copy_file_range. No attempt was made to share code
> with the 32bit function because 32bit interface should probably
> get depreciated.
>
> Why use 64bit? Current uses of 32bit are by clone_file_range()
> which could use 64bit count and NFS copy_file_range also supports
> 64bit count value.
>
> Also with this proposal off-the-bet allow the userland to copy
> between different mount points.
>
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
...
> +
> +       /*
> +        * Try cloning first, this is supported by more file systems, and
> +        * more efficient if both clone and copy are supported (e.g. NFS).
> +        */
> +       if (file_in->f_op->clone_file_range) {
> +               ret = file_in->f_op->clone_file_range(file_in, pos_in,
> +                               file_out, pos_out, len);
> +               if (ret == 0) {
> +                       ret = len;
> +                       goto done;
> +               }
> +       }
> +
> +       if (file_out->f_op->copy_file_range64) {
> +               ret = file_out->f_op->copy_file_range64(file_in, pos_in,
> +                                       file_out, pos_out, len, flags);
> +               if (ret != -EOPNOTSUPP)
> +                       goto done;
> +       }
> +
> +       ret = do_splice_direct(file_in, &pos_in, file_out, &pos_out,
> +                       len > MAX_RW_COUNT ? MAX_RW_COUNT : len, 0);
> +

Olga,

I know this is copied from vfs_copy_file_range() as is, so my comment
applies to the origin function as well, but it is easier to change the new
function without changing userspace behavior, so..

A while back, either Dave Chinner or Christoph suggested that I use
vfs_copy_file_range() from ovl_copy_up_data() instead of calling
vfs_clone_file_range() and falling back to do_splice_direct() loop.
Then Christoph added the clone_file_range attempt into
vfs_copy_file_range(), which was one part of the work.

However, ovl_copy_up_data() uses a killable loop of do_splice_direct()
calls with smaller chunks, so it is not the same as vfs_copy_file_range().

I wonder if it makes sense to use a similar killable loop in the new
function?
I wonder, for reference, if NFS implementation of copy_file_range64()
is killable?

Amir.
