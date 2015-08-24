Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:34422 "EHLO
	mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932640AbbHXNRB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Aug 2015 09:17:01 -0400
Received: by oiey141 with SMTP id y141so79643489oie.1
        for <linux-nfs@vger.kernel.org>; Mon, 24 Aug 2015 06:17:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1440282873-19972-1-git-send-email-xerofoify@gmail.com>
References: <1440282873-19972-1-git-send-email-xerofoify@gmail.com>
Date: Mon, 24 Aug 2015 09:17:00 -0400
Message-ID: <CAHQdGtRZ46fg06cd4e7SdDMbyLQekfw7iG=XYvHoXumnfEa3vQ@mail.gmail.com>
Subject: Re: [PATCH] nfs:Fix error handling in the function nfs_vm_page_mkwrite
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Nicholas Krause <xerofoify@gmail.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Aug 22, 2015 at 6:34 PM, Nicholas Krause <xerofoify@gmail.com> wrote:
> This fixes error handling in the function nfs_vm_page_mkwrite to
> properly check if the function wait_on_bit_action returned something
> other then zero as if so return to the caller of nfs_vm_page_mkwrite
> to signal that a internal failure has occurred when calling this
> function and should be handled by the caller.
>
> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> ---
>  fs/nfs/file.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
>
> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> index cc4fa1e..698851a 100644
> --- a/fs/nfs/file.c
> +++ b/fs/nfs/file.c
> @@ -612,8 +612,10 @@ static int nfs_vm_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
>         /* make sure the cache has finished storing the page */
>         nfs_fscache_wait_on_page_write(NFS_I(inode), page);
>
> -       wait_on_bit_action(&NFS_I(inode)->flags, NFS_INO_INVALIDATING,
> -                       nfs_wait_bit_killable, TASK_KILLABLE);
> +       ret = wait_on_bit_action(&NFS_I(inode)->flags, NFS_INO_INVALIDATING,
> +                                nfs_wait_bit_killable, TASK_KILLABLE);
> +       if (ret)
> +               goto out;
>
>         lock_page(page);
>         mapping = page_file_mapping(page);
> --
> 2.1.4
>

nfs_vm_page_mkwrite() is only allowed to return the value '0' or one
or more of the VM_FAULT_* flags. It may not return kernel error
values.

Trond
