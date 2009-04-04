From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: bus errors on nfs writes in latest git
Date: Sat, 04 Apr 2009 12:19:09 -0400
Message-ID: <1238861949.8114.3.camel@heimdal.trondhjem.org>
References: <20090404161447.GE495@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, Nick Piggin <npiggin@suse.de>,
	linux-kernel@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:16795 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752596AbZDDQTW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 4 Apr 2009 12:19:22 -0400
In-Reply-To: <20090404161447.GE495@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2009-04-04 at 12:14 -0400, J. Bruce Fields wrote:
> My regular connecthon tests are reporting bus errors on the "write/read
> 30 MB file" on recent upstream kernels.  I'm travelling and haven't had
> a chance to do anything beyond kick off a dumb git-bisect, which pointed
> the blame at the following commit.  Any ideas?
> 
> --b.
> 
> 
> commit c2ec175c39f62949438354f603f4aa170846aabb
> Author: Nick Piggin <npiggin@suse.de>
> Date:   Tue Mar 31 15:23:21 2009 -0700
> 
>     mm: page_mkwrite change prototype to match fault
>     
>     Change the page_mkwrite prototype to take a struct vm_fault, and return
>     VM_FAULT_xxx flags.  There should be no functional change.
>     
>     This makes it possible to return much more detailed error information to
>     the VM (and also can provide more information eg.  virtual_address to the
>     driver, which might be important in some special cases).
>     
>     This is required for a subsequent fix.  And will also make it easier to
>     merge page_mkwrite() with fault() in future.
>     
>     Signed-off-by: Nick Piggin <npiggin@suse.de>
>     Cc: Chris Mason <chris.mason@oracle.com>
>     Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
>     Cc: Miklos Szeredi <miklos@szeredi.hu>
>     Cc: Steven Whitehouse <swhiteho@redhat.com>
>     Cc: Mark Fasheh <mfasheh@suse.com>
>     Cc: Joel Becker <joel.becker@oracle.com>
>     Cc: Artem Bityutskiy <dedekind@infradead.org>
>     Cc: Felix Blyakher <felixb@sgi.com>
>     Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>     Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
<snip>
> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> index 90f292b..cec7939 100644
> --- a/fs/nfs/file.c
> +++ b/fs/nfs/file.c
> @@ -451,8 +451,9 @@ const struct address_space_operations nfs_file_aops = {
>  	.launder_page = nfs_launder_page,
>  };
>  
> -static int nfs_vm_page_mkwrite(struct vm_area_struct *vma, struct page *page)
> +static int nfs_vm_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
>  {
> +	struct page *page = vmf->page;
>  	struct file *filp = vma->vm_file;
>  	struct dentry *dentry = filp->f_path.dentry;
>  	unsigned pagelen;
> @@ -483,6 +484,8 @@ static int nfs_vm_page_mkwrite(struct vm_area_struct *vma, struct page *page)
>  		ret = pagelen;
               ^^^^^^^^^^^^^^^^^^
This would explain it. I assume that we're actually supposed to return 0
in case of success.

>  out_unlock:
>  	unlock_page(page);
> +	if (ret)
> +		ret = VM_FAULT_SIGBUS;
>  	return ret;
>  }
>  


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
