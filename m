From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 2/5] VFS: Add VFS helper functions for setting up
	private namespaces
Date: Tue, 23 Jun 2009 17:32:30 -0500
Message-ID: <20090623223230.GA30173@us.ibm.com>
References: <20090622190913.27923.31665.stgit@heimdal.trondhjem.org> <20090622190913.27923.61549.stgit@heimdal.trondhjem.org> <20090623201307.GA25760@us.ibm.com> <1245792589.5133.24.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1245792589.5133.24.camel@heimdal.trondhjem.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Quoting Trond Myklebust (Trond.Myklebust@netapp.com):
> On Tue, 2009-06-23 at 15:13 -0500, Serge E. Hallyn wrote:
> > Quoting Trond Myklebust (Trond.Myklebust@netapp.com):
> > > The purpose of this patch is to improve the remote mount path lookup
> > > support for distributed filesystems such as the NFSv4 client.
> > > 
> > > When given a mount command of the form "mount server:/foo/bar /mnt", the
> > > NFSv4 client is required to look up the filehandle for "server:/", and
> > > then look up each component of the remote mount path "foo/bar" in order
> > > to find the directory that is actually going to be mounted on /mnt.
> > > Following that remote mount path may involve following symlinks,
> > > crossing server-side mount points and even following referrals to
> > > filesystem volumes on other servers.
> > > 
> > > Since the standard VFS path lookup code already supports walking paths
> > > that contain all these features (using in-kernel automounts for
> > > following referrals) we would like to be able to reuse that rather than
> > > duplicate the full path traversal functionality in the NFSv4 client code.
> > > 
> > > This patch therefore defines a VFS helper function create_mnt_ns(), that
> > > sets up a temporary filesystem namespace and attaches a root filesystem to
> > > it. It exports the create_mnt_ns() and put_mnt_ns() function for use by
> > > filesystem modules.
> > > 
> > > Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> > 
> > This looks good, thanks.  Though I see no reason not to also switch over
> > init_mount_tree() to the new helper.
> > 
> > (Seems plausible that c/r code would use this as well)
> > 
> > Reviewed-by: Serge Hallyn <serue@us.ibm.com>
> > 
> > thanks,
> > -serge
> 
> Thanks for the review! I missed the code duplication in
> init_mount_tree(). Something like the following?

Yup.

(it keeps bugging me that the order of args to list_add() gets reversed
as a result, but clearly with both starting out empty it doesn't
matter..)

thanks,
-serge

> Cheers
>   Trond
> --------------------------------------------------------------------
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> VFS: Switch init_mount_tree() to use the new create_mnt_ns() helper
> 
> Eliminates some duplicated code...
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> 
>  fs/namespace.c |   11 ++---------
>  1 files changed, 2 insertions(+), 9 deletions(-)
> 
> 
> diff --git a/fs/namespace.c b/fs/namespace.c
> index a7bea8c..4a86b85 100644
> --- a/fs/namespace.c
> +++ b/fs/namespace.c
> @@ -2222,16 +2222,9 @@ static void __init init_mount_tree(void)
>  	mnt = do_kern_mount("rootfs", 0, "rootfs", NULL);
>  	if (IS_ERR(mnt))
>  		panic("Can't create rootfs");
> -	ns = kmalloc(sizeof(*ns), GFP_KERNEL);
> -	if (!ns)
> +	ns = create_mnt_ns(mnt);
> +	if (IS_ERR(ns))
>  		panic("Can't allocate initial namespace");
> -	atomic_set(&ns->count, 1);
> -	INIT_LIST_HEAD(&ns->list);
> -	init_waitqueue_head(&ns->poll);
> -	ns->event = 0;
> -	list_add(&mnt->mnt_list, &ns->list);
> -	ns->root = mnt;
> -	mnt->mnt_ns = ns;
> 
>  	init_task.nsproxy->mnt_ns = ns;
>  	get_mnt_ns(ns);
> 
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
