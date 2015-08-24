Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:33997 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754447AbbHXNMI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Aug 2015 09:12:08 -0400
Received: by obbfr1 with SMTP id fr1so112216485obb.1
        for <linux-nfs@vger.kernel.org>; Mon, 24 Aug 2015 06:12:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1440292628-22461-1-git-send-email-xerofoify@gmail.com>
References: <1440292628-22461-1-git-send-email-xerofoify@gmail.com>
Date: Mon, 24 Aug 2015 09:12:07 -0400
Message-ID: <CAHQdGtT3bh03QAWU2V3fTc1O-1+MKm-X5JEZhzHO_sAV=ABT_w@mail.gmail.com>
Subject: Re: [PATCH] nfs:Fix deadlock occurrence issue on error path in the
 function nfs_vm_page_mkwrite
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Nicholas Krause <xerofoify@gmail.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Aug 22, 2015 at 9:17 PM, Nicholas Krause <xerofoify@gmail.com> wrote:
>
> This fixes a possible deadlock occurrence issue on the error path
> in the function nfs_vm_page_mkwrite for checking if the calls to
> the functions nfs_flus_incompatible and nfs_updatepage have failed
> by incorrectly not jumping to the correct goto label out_unlock
> for unlocking the locked structure page pointer thus causing a
> deadlock due to not correctly unlocking the internal structure
> page pointer used by the function nfs_vm_page_mkwrite that had
> been previously locked with the function lock_page. Further more
> we also remove the goto label out as no error paths in this function
> now use this label and this label should be removed to avoid build
> warnings related to having a undefined label.
>
> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> ---
>  fs/nfs/file.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
>
> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> index cc4fa1e..fe68ecc 100644
> --- a/fs/nfs/file.c
> +++ b/fs/nfs/file.c
> @@ -629,12 +629,11 @@ static int nfs_vm_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
>         ret = VM_FAULT_LOCKED;
>         if (nfs_flush_incompatible(filp, page) == 0 &&
>             nfs_updatepage(filp, page, 0, pagelen) == 0)
> -               goto out;
> +               goto out_unlock;
>
>         ret = VM_FAULT_SIGBUS;
>  out_unlock:
>         unlock_page(page);
> -out:
>         return ret;
>  }
>
>

That's the success path that you are modifying, not the error path.
Furthermore, the return value is still VM_FAULT_LOCKED, which means
the caller expects the page to be returned in the locked state.

So NACK....

Trond
