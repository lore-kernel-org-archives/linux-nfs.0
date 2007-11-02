From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: LTP ustat01 test fails on NFSROOT
Date: Fri, 2 Nov 2007 09:28:23 -0500 (CDT)
Message-ID: <Pine.LNX.4.64.0711020927530.25341@blarg.am.freescale.net>
References: <CBDE987B-0713-4D62-8122-054183E75410@kernel.crashing.org>
	<1193188894.27073.20.camel@heimdal.trondhjem.org>
	<1954B8FA-6E29-4FB7-86B0-EA43AF8F2AAF@kernel.crashing.org>
	<2B2C1270-60FB-4830-A62C-D0357D2E1FB3@kernel.crashing.org>
	<1193335168.7705.39.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Morton <akpm@osdl.org>, neilb@suse.de,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	bfields@fieldses.org, nfs@lists.sourceforge.net
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1InxWW-0006Vk-Qv
	for nfs@lists.sourceforge.net; Fri, 02 Nov 2007 07:29:24 -0700
Received: from gate.crashing.org ([63.228.1.57]
	ident=[U2FsdGVkX1+txDDTJZyOMM6RHh+NnzoLc3x3nmq9JXM=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1InxWc-0006X6-2j
	for nfs@lists.sourceforge.net; Fri, 02 Nov 2007 07:29:30 -0700
In-Reply-To: <1193335168.7705.39.camel@heimdal.trondhjem.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thu, 25 Oct 2007, Trond Myklebust wrote:

> Could you please try the following patch?
>
> Cheers
>   Trond

Its a new month so I'll ping again about sending this fix upstream to
linus for 2.6.24 :) ?

- k

> --------------------------------- CUT HERE -----------------------------
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date: Thu, 25 Oct 2007 13:56:10 -0400
> NFS: Fix the ustat() regression
>
> Since 2.6.18, the superblock sb->s_root has been a dummy dentry with a
> dummy inode. This breaks ustat(), which actually uses sb->s_root in a
> vfstat() call.
>
> Fix this by making the s_root a dummy alias to the directory inode that was
> used when creating the superblock.
>
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
>
>  fs/nfs/getroot.c |   81 ++++++++++++++++++------------------------------------
>  1 files changed, 27 insertions(+), 54 deletions(-)
>
> diff --git a/fs/nfs/getroot.c b/fs/nfs/getroot.c
> index 522e5ad..0ee4384 100644
> --- a/fs/nfs/getroot.c
> +++ b/fs/nfs/getroot.c
> @@ -43,6 +43,25 @@
>  #define NFSDBG_FACILITY		NFSDBG_CLIENT
>
>  /*
> + * Set the superblock root dentry.
> + * Note that this function frees the inode in case of error.
> + */
> +static int nfs_superblock_set_dummy_root(struct super_block *sb, struct inode *inode)
> +{
> +	/* The mntroot acts as the dummy root dentry for this superblock */
> +	if (sb->s_root == NULL) {
> +		sb->s_root = d_alloc_root(inode);
> +		if (sb->s_root == NULL) {
> +			iput(inode);
> +			return -ENOMEM;
> +		}
> +		/* Circumvent igrab(): we know the inode is not being freed */
> +		atomic_inc(&inode->i_count);
> +	}
> +	return 0;
> +}
> +
> +/*
>   * get an NFS2/NFS3 root dentry from the root filehandle
>   */
>  struct dentry *nfs_get_root(struct super_block *sb, struct nfs_fh *mntfh)
> @@ -54,33 +73,6 @@ struct dentry *nfs_get_root(struct super_block *sb, struct nfs_fh *mntfh)
>  	struct inode *inode;
>  	int error;
>
> -	/* create a dummy root dentry with dummy inode for this superblock */
> -	if (!sb->s_root) {
> -		struct nfs_fh dummyfh;
> -		struct dentry *root;
> -		struct inode *iroot;
> -
> -		memset(&dummyfh, 0, sizeof(dummyfh));
> -		memset(&fattr, 0, sizeof(fattr));
> -		nfs_fattr_init(&fattr);
> -		fattr.valid = NFS_ATTR_FATTR;
> -		fattr.type = NFDIR;
> -		fattr.mode = S_IFDIR | S_IRUSR | S_IWUSR;
> -		fattr.nlink = 2;
> -
> -		iroot = nfs_fhget(sb, &dummyfh, &fattr);
> -		if (IS_ERR(iroot))
> -			return ERR_PTR(PTR_ERR(iroot));
> -
> -		root = d_alloc_root(iroot);
> -		if (!root) {
> -			iput(iroot);
> -			return ERR_PTR(-ENOMEM);
> -		}
> -
> -		sb->s_root = root;
> -	}
> -
>  	/* get the actual root for this mount */
>  	fsinfo.fattr = &fattr;
>
> @@ -96,6 +88,10 @@ struct dentry *nfs_get_root(struct super_block *sb, struct nfs_fh *mntfh)
>  		return ERR_PTR(PTR_ERR(inode));
>  	}
>
> +	error = nfs_superblock_set_dummy_root(sb, inode);
> +	if (error != 0)
> +		return ERR_PTR(error);
> +
>  	/* root dentries normally start off anonymous and get spliced in later
>  	 * if the dentry tree reaches them; however if the dentry already
>  	 * exists, we'll pick it up at this point and use it as the root
> @@ -241,33 +237,6 @@ struct dentry *nfs4_get_root(struct super_block *sb, struct nfs_fh *mntfh)
>
>  	dprintk("--> nfs4_get_root()\n");
>
> -	/* create a dummy root dentry with dummy inode for this superblock */
> -	if (!sb->s_root) {
> -		struct nfs_fh dummyfh;
> -		struct dentry *root;
> -		struct inode *iroot;
> -
> -		memset(&dummyfh, 0, sizeof(dummyfh));
> -		memset(&fattr, 0, sizeof(fattr));
> -		nfs_fattr_init(&fattr);
> -		fattr.valid = NFS_ATTR_FATTR;
> -		fattr.type = NFDIR;
> -		fattr.mode = S_IFDIR | S_IRUSR | S_IWUSR;
> -		fattr.nlink = 2;
> -
> -		iroot = nfs_fhget(sb, &dummyfh, &fattr);
> -		if (IS_ERR(iroot))
> -			return ERR_PTR(PTR_ERR(iroot));
> -
> -		root = d_alloc_root(iroot);
> -		if (!root) {
> -			iput(iroot);
> -			return ERR_PTR(-ENOMEM);
> -		}
> -
> -		sb->s_root = root;
> -	}
> -
>  	/* get the info about the server and filesystem */
>  	error = nfs4_server_capabilities(server, mntfh);
>  	if (error < 0) {
> @@ -289,6 +258,10 @@ struct dentry *nfs4_get_root(struct super_block *sb, struct nfs_fh *mntfh)
>  		return ERR_PTR(PTR_ERR(inode));
>  	}
>
> +	error = nfs_superblock_set_dummy_root(sb, inode);
> +	if (error != 0)
> +		return ERR_PTR(error);
> +
>  	/* root dentries normally start off anonymous and get spliced in later
>  	 * if the dentry tree reaches them; however if the dentry already
>  	 * exists, we'll pick it up at this point and use it as the root
>

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
