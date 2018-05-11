Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:44755 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751159AbeEKSaE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 11 May 2018 14:30:04 -0400
Received: by mail-lf0-f66.google.com with SMTP id h197-v6so9214309lfg.11
        for <linux-nfs@vger.kernel.org>; Fri, 11 May 2018 11:30:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180414194442.GA20044@jordon-HP-15-Notebook-PC>
References: <20180414194442.GA20044@jordon-HP-15-Notebook-PC>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Sat, 12 May 2018 00:00:02 +0530
Message-ID: <CAFqt6zaM7kBSm1kkEp1KKYS=o0Jp0Y-kEP5AXNqsrrppZrPqeQ@mail.gmail.com>
Subject: Re: [PATCH] fs: nfs: Adding new return type vm_fault_t
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, Matthew Wilcox <willy@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Apr 15, 2018 at 1:14 AM, Souptick Joarder <jrdr.linux@gmail.com> wrote:
> Use new return type vm_fault_t for page_mkwrite
> handler.
>
> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
> Reviewed-by: Matthew Wilcox <mawilcox@microsoft.com>
> ---
>  fs/nfs/file.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> index 81cca49..29553fd 100644
> --- a/fs/nfs/file.c
> +++ b/fs/nfs/file.c
> @@ -532,13 +532,13 @@ static void nfs_swap_deactivate(struct file *file)
>   * writable, implying that someone is about to modify the page through a
>   * shared-writable mapping
>   */
> -static int nfs_vm_page_mkwrite(struct vm_fault *vmf)
> +static vm_fault_t nfs_vm_page_mkwrite(struct vm_fault *vmf)
>  {
>         struct page *page = vmf->page;
>         struct file *filp = vmf->vma->vm_file;
>         struct inode *inode = file_inode(filp);
>         unsigned pagelen;
> -       int ret = VM_FAULT_NOPAGE;
> +       vm_fault_t ret = VM_FAULT_NOPAGE;
>         struct address_space *mapping;
>
>         dfprintk(PAGECACHE, "NFS: vm_page_mkwrite(%pD2(%lu), offset %lld)\n",
> --
> 1.9.1
>

Any comment for this patch ? We would like to get this patch
queued for 4.18.
