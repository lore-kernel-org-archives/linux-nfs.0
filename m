From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] nfs: parenthesize NFS_*(inode) parameters
Date: Tue, 22 Jan 2008 13:58:21 -0500
Message-ID: <1201028301.30335.39.camel@heimdal.trondhjem.org>
References: <1201012083-9860-1-git-send-email-bhalevy@panasas.com>
	 <1201013438.30335.5.camel@heimdal.trondhjem.org>
	 <47960DA7.1010203@panasas.com>
	 <126C1947-AB76-4C93-95F7-2787081DBEC3@oracle.com>
	 <1201025443.30335.29.camel@heimdal.trondhjem.org>
	 <47963649.9020502@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, NFSv4@linux-nfs.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:29318 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752681AbYAVS6Y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Jan 2008 13:58:24 -0500
In-Reply-To: <47963649.9020502@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Tue, 2008-01-22 at 20:30 +0200, Benny Halevy wrote:

> > Ideally, we should get rid of NFS_FLAGS()/NFS_FLAGSP(). That too is just
> > obfuscating the code for no good reason.
> 
> I completely agree that NFS_FLAGSP is ugly.
> Initially I thought of changing &NFS_FLAGS(inode) to &NFS_I(inode)->flags
> and get rid of NFS_FLAGS, but I deferred to the most minimal change.
> Let me know if you want me to do that.

If you want to get rid of NFS_FLAGS(), then that would be great. Please
make that a separate patch, though.

> > 
> >>>  static void nfs_invalidate_inode(struct inode *inode)
> >>>  {
> >>> -	set_bit(NFS_INO_STALE, &NFS_FLAGS(inode));
> >>> +	set_bit(NFS_INO_STALE, NFS_FLAGSP(inode));
> >> Likewise for NFS_INO_STALE... A separate inline for setting  
> >> NFS_INO_STALE might be a little nicer.
> > 
> > Not an inline. Just convert the existing nfs_invalidate_inode() into an
> > nfs_invalidate_inode_locked(), and add a version that takes the lock.
> 
> I'm not sure I follow you...  All it does is setting the NFS_INO_STALE
> bit and calling nfs_zap_caches_locked.  What use case is there for 
> the unlocked case?

The current version _is_ an 'unlocked' version. nfs_update_inode() uses
it, since the caller already holds the spinlock.

> > 
> >>>  	nfs_zap_caches_locked(inode);
> >>>  }
> >>>
> >>> @@ -229,7 +229,7 @@ nfs_init_locked(struct inode *inode, void *opaque)
> >>>  	struct nfs_find_desc	*desc = (struct nfs_find_desc *)opaque;
> >>>  	struct nfs_fattr	*fattr = desc->fattr;
> >>>
> >>> -	NFS_FILEID(inode) = fattr->fileid;
> >>> +	set_nfs_fileid(inode, fattr->fileid);
> >>>  	nfs_copy_fh(NFS_FH(inode), desc->fh);
> >>>  	return 0;
> >>>  }
> >>> @@ -291,7 +291,7 @@ nfs_fhget(struct super_block *sb, struct nfs_fh  
> >>> *fh, struct nfs_fattr *fattr)
> >>>  			inode->i_fop = &nfs_dir_operations;
> >>>  			if (nfs_server_capable(inode, NFS_CAP_READDIRPLUS)
> >>>  			    && fattr->size <= NFS_LIMIT_READDIRPLUS)
> >>> -				set_bit(NFS_INO_ADVISE_RDPLUS, &NFS_FLAGS(inode));
> >>> +				set_bit(NFS_INO_ADVISE_RDPLUS, NFS_FLAGSP(inode));
> >> And for setting NFS_INO_ADVISE_RDPLUS.
> > 
> > Again, why?
> 
> The only good reason I can think of is abstracting the API to allow a different
> implementation in the future, but I see little benefits as for style or readability.

Even if we were planning on changing the implementation, the idea of
abstracting the API is a bit far-fetched: this bit is set in 1 location
and cleared in 2. Tracking those 3 lines of code is hardly a major
problem.

Trond
