From: Bryan Wu <cooloney@kernel.org>
Subject: Re: [PATCH] nfs client: kill compile warning on NOMMU machine
Date: Fri, 6 Feb 2009 00:24:37 +0800
Message-ID: <386072610902050824j6eeb8e9asde2c41ac5cf9815a@mail.gmail.com>
References: <1225962921-6424-1-git-send-email-cooloney@kernel.org>
	 <386072610902050102r3c3e41a3yfbb424411f2f40dc@mail.gmail.com>
	 <1233840498.7161.97.camel@heimdal.trondhjem.org>
	 <1233848265.7161.101.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rn-out-0910.google.com ([64.233.170.189]:12835 "EHLO
	rn-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751568AbZBEQYj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Feb 2009 11:24:39 -0500
In-Reply-To: <1233848265.7161.101.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 5, 2009 at 11:37 PM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
> On Thu, 2009-02-05 at 08:28 -0500, Trond Myklebust wrote:
>> On Thu, 2009-02-05 at 17:02 +0800, Bryan Wu wrote:
>> > Hi guys,
>> >
>> > Is it possible to merge this patch?
>>
>> NACK. Although it would be nice to get rid of the warning, this patch
>> does so at the price of even further obfuscating the fact that we're
>> just returning -ENOSYS in the no MMU case, and by causing
>> nfs_file_vm_ops (which is currently optimised away) to be compiled in
>> for no good reason at all.
>>
>> Trond
>
> How about the following compromise: we get rid of the special casing
> altogether and just always call generic_file_mmap. If the noMMU folks
> want further optimisations, then they can inline generic_file_mmap(), so
> that the compiler always takes the 'generic_file_mmap() failed' path.
>

Beautiful, I do love this one and would like to test it on our platform.

Thanks
-Bryan

> Cheers
>  Trond
> ------------------------------------------------------------
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date: Thu, 5 Feb 2009 10:23:36 -0500
> NFS: Kill the "defined but not used" compile error on nommu machines
>
> Bryan Wu reports that when compiling NFS on nommu machines he gets a
> "defined but not used" error on nfs_file_mmap().
>
> The easiest fix is simply to get rid of the special casing in NFS, and
> just always call generic_file_mmap() to set up the file.
>
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
>
>  fs/nfs/file.c |   12 +++++-------
>  1 files changed, 5 insertions(+), 7 deletions(-)
>
>
> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> index 404c19c..1eab9c9 100644
> --- a/fs/nfs/file.c
> +++ b/fs/nfs/file.c
> @@ -64,11 +64,7 @@ const struct file_operations nfs_file_operations = {
>        .write          = do_sync_write,
>        .aio_read       = nfs_file_read,
>        .aio_write      = nfs_file_write,
> -#ifdef CONFIG_MMU
>        .mmap           = nfs_file_mmap,
> -#else
> -       .mmap           = generic_file_mmap,
> -#endif
>        .open           = nfs_file_open,
>        .flush          = nfs_file_flush,
>        .release        = nfs_file_release,
> @@ -304,11 +300,13 @@ nfs_file_mmap(struct file * file, struct vm_area_struct * vma)
>        dprintk("NFS: mmap(%s/%s)\n",
>                dentry->d_parent->d_name.name, dentry->d_name.name);
>
> -       status = nfs_revalidate_mapping(inode, file->f_mapping);
> +       /* Note: generic_file_mmap() returns ENOSYS on nommu systems
> +        *       so we call that before revalidating the mapping
> +        */
> +       status = generic_file_mmap(file, vma);
>        if (!status) {
>                vma->vm_ops = &nfs_file_vm_ops;
> -               vma->vm_flags |= VM_CAN_NONLINEAR;
> -               file_accessed(file);
> +               status = nfs_revalidate_mapping(inode, file->f_mapping);
>        }
>        return status;
>  }
>
> --
> Trond Myklebust
> Linux NFS client maintainer
>
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
>
