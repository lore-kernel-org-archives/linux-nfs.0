From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH v2] reduce NFS stack usage
Date: Thu, 25 Sep 2003 14:36:36 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F7335B4.1070002@RedHat.com>
References: <mailman.1064420466.30286.linux-kernel2news@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A2ayo-0006DX-00
	for <nfs@lists.sourceforge.net>; Thu, 25 Sep 2003 11:36:42 -0700
Received: from pix-525-pool.redhat.com ([66.187.233.200] helo=lacrosse.corp.redhat.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A2aym-0006OF-Vi
	for nfs@lists.sourceforge.net; Thu, 25 Sep 2003 11:36:41 -0700
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <mailman.1064420466.30286.linux-kernel2news@redhat.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hey Jeff,

Question:
Why are only nfs_lookup_revalidate() and nfs_readdir()
a problem and not the other 4 ops (like nfs_lookup())?
Is the case only those two showed up in the stack overflow
oops trace?

Also, not like there much choice in matter, but I wonder what
type of performance hit (if any) there will be by making
these routines call kmalloc()... lookups and readdirs are
pretty popular ops...

SteveD.

Jeff Garzik wrote:
> David Mansfield spotted a bug in a memset() call, in my initial patch.
> 
> Attached is an updated version.  The only change is 
> s/sizeof(my_entry)/sizeof(*my_entry)/ in the memset.
> 
>     Jeff
> 
> 
> 
> ------------------------------------------------------------------------
> 
> 
> ===== fs/nfs/dir.c 1.12 vs edited =====
> --- 1.12/fs/nfs/dir.c	Tue Oct 15 00:59:27 2002
> +++ edited/fs/nfs/dir.c	Mon Sep 22 15:08:27 2003
> @@ -349,14 +349,25 @@
>  {
>  	struct dentry	*dentry = filp->f_dentry;
>  	struct inode	*inode = dentry->d_inode;
> -	nfs_readdir_descriptor_t my_desc,
> -			*desc = &my_desc;
> -	struct nfs_entry my_entry;
> +	nfs_readdir_descriptor_t *desc;
> +	struct nfs_entry *my_entry;
>  	long		res;
> +	int		rc = -EINVAL;
> +	void		*mem;
> +
> +	mem = kmalloc(sizeof(struct nfs_entry) +
> +		      sizeof(nfs_readdir_descriptor_t), GFP_KERNEL);
> +	if (!mem)
> +		return -ENOMEM;
> +
> +	my_entry = mem;
> +	desc = mem + sizeof(struct nfs_entry);
>  
>  	res = nfs_revalidate(dentry);
> -	if (res < 0)
> -		return res;
> +	if (res < 0) {
> +		rc = (int) res;
> +		goto out;
> +	}
>  
>  	/*
>  	 * filp->f_pos points to the file offset in the page cache.
> @@ -365,11 +376,11 @@
>  	 * itself.
>  	 */
>  	memset(desc, 0, sizeof(*desc));
> -	memset(&my_entry, 0, sizeof(my_entry));
> +	memset(my_entry, 0, sizeof(*my_entry));
>  
>  	desc->file = filp;
>  	desc->target = filp->f_pos;
> -	desc->entry = &my_entry;
> +	desc->entry = my_entry;
>  	desc->decode = NFS_PROTO(inode)->decode_dirent;
>  
>  	while(!desc->entry->eof) {
> @@ -393,11 +404,16 @@
>  			break;
>  		}
>  	}
> +
>  	if (desc->error < 0)
> -		return desc->error;
> -	if (res < 0)
> -		return res;
> -	return 0;
> +		rc = desc->error;
> +	else if (res < 0)
> +		rc = res;
> +	/* fall through */
> +
> +out:
> +	kfree(mem);
> +	return rc;
>  }
>  
>  /*
> @@ -476,13 +492,22 @@
>  	struct inode *dir;
>  	struct inode *inode;
>  	int error;
> -	struct nfs_fh fhandle;
> -	struct nfs_fattr fattr;
> +	struct nfs_fh *fhandle;
> +	struct nfs_fattr *fattr;
> +	void *mem;
> +	int rc = 0;
>  
>  	lock_kernel();
>  	dir = dentry->d_parent->d_inode;
>  	inode = dentry->d_inode;
>  
> +	mem = kmalloc(sizeof(struct nfs_fh) + sizeof(struct nfs_fattr),
> +		      GFP_KERNEL);
> +	if (!mem)
> +		goto out_bad;
> +	fhandle = mem;
> +	fattr = mem + sizeof(struct nfs_fh);
> +
>  	if (!inode) {
>  		if (nfs_neg_need_reval(dir, dentry))
>  			goto out_bad;
> @@ -505,18 +530,19 @@
>  	if (NFS_STALE(inode))
>  		goto out_bad;
>  
> -	error = NFS_PROTO(dir)->lookup(dir, &dentry->d_name, &fhandle, &fattr);
> +	error = NFS_PROTO(dir)->lookup(dir, &dentry->d_name, fhandle, fattr);
>  	if (error)
>  		goto out_bad;
> -	if (memcmp(NFS_FH(inode), &fhandle, sizeof(struct nfs_fh))!= 0)
> +	if (memcmp(NFS_FH(inode), fhandle, sizeof(struct nfs_fh))!= 0)
>  		goto out_bad;
> -	if ((error = nfs_refresh_inode(inode, &fattr)) != 0)
> +	if ((error = nfs_refresh_inode(inode, fattr)) != 0)
>  		goto out_bad;
>  
>  	nfs_renew_times(dentry);
>   out_valid:
> -	unlock_kernel();
> -	return 1;
> + 	rc = 1;
> +	goto out;
> +
>   out_bad:
>  	NFS_CACHEINV(dir);
>  	if (inode && S_ISDIR(inode->i_mode)) {
> @@ -528,8 +554,14 @@
>  		shrink_dcache_parent(dentry);
>  	}
>  	d_drop(dentry);
> +	rc = 0;
> +	/* fall through */
> +
> +out:
>  	unlock_kernel();
> -	return 0;
> +	if (mem)
> +		kfree(mem);
> +	return rc;
>  }
>  
>  /*
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 
> 



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
