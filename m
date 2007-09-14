From: Greg Banks <gnb@sgi.com>
Subject: Re: [NFS] [PATH 10/19] xfs: new export ops
Date: Sat, 15 Sep 2007 01:22:16 +1000
Message-ID: <20070914152216.GI21965@sgi.com>
References: <20070830131641.GK6834@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, linux-fsdevel@vger.kernel.org
To: Christoph Hellwig <hch@lst.de>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070830131641.GK6834@lst.de>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Thu, Aug 30, 2007 at 03:16:41PM +0200, Christoph Hellwig wrote:
> -#if XFS_BIG_INUMS
>  	bhv_vfs_t		*vfs = vfs_from_sb(inode->i_sb);
>  
> -	if (!(vfs->vfs_flag & VFS_32BITINODES)) {
> -		/* filesystem may contain 64bit inode numbers */
> -		is64 = XFS_FILEID_TYPE_64FLAG;
> -	}
> -#endif
>  
>  	/* Directories don't need their parent encoded, they have ".." */
>  	if (S_ISDIR(inode->i_mode))
> -	    connectable = 0;
> +		fileid_type = FILEID_INO32_GEN;
> +	else
> +		fileid_type = FILEID_INO32_GEN_PARENT;
> +
> +	/* filesystem may contain 64bit inode numbers */
> +	if (!(vfs->vfs_flag & VFS_32BITINODES))
> +		fileid_type |= XFS_FILEID_TYPE_64FLAG;

Not really a comment on your patches, but I got the original logic
wrong here.  The VFS_32BITINODES flag only affects newly allocated
inodes and is no guarantee that any particular inode is < 2^32-1.
It's possible for an unlucky user to perform a sequence of mounts
and IO which results in large inode numbers despite the presence of
that flag; we recently saw this happen by accident on a customer site.
So the right thing to do is probably to check the inode number against
(u32)~0.  Unfortunately, given the current encoding scheme, you have to
check both the inode and the parent inode, which complicates the logic.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
Apparently, I'm Bedevere.  Which MPHG character are you?
I don't speak for SGI.
