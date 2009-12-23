From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] improve the performance of large sequential write NFS
 workloads
Date: Wed, 23 Dec 2009 19:05:51 +0100
Message-ID: <20091223180551.GD3159@quack.suse.cz>
References: <1261015420.1947.54.camel@serenity>
 <1261037877.27920.36.camel@laptop>
 <20091219122033.GA11360@localhost>
 <1261232747.1947.194.camel@serenity>
 <20091222015907.GA6223@localhost>
 <1261578107.2606.11.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wu Fengguang <fengguang.wu@intel.com>,
	Steve Rago <sar@nec-labs.com>,
	Peter Zijlstra <peterz@infradead.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"jens.axboe" <jens.axboe@oracle.com>,
	Peter Staubach <staubach@redhat.com>, Jan Kara <jack@suse.cz>,
	Arjan van de Ven <arjan@infradead.org>,
	Ingo Molnar <mingo@elte.hu>, linux-fsdevel@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756721AbZLWSGH@vger.kernel.org>
In-Reply-To: <1261578107.2606.11.camel@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed 23-12-09 15:21:47, Trond Myklebust wrote:
> On Tue, 2009-12-22 at 09:59 +0800, Wu Fengguang wrote: 
> > 1) normal fs sets I_DIRTY_DATASYNC when extending i_size, however NFS
> >    will set the flag for any pages written -- why this trick? To
> >    guarantee the call of nfs_commit_inode()? Which unfortunately turns
> >    almost every server side NFS write into sync writes..
> > 
> >  writeback_single_inode:
> >     do_writepages
> >       nfs_writepages
> >         nfs_writepage ----[short time later]---> nfs_writeback_release*
> >                                                    nfs_mark_request_commit
> >                                                      __mark_inode_dirty(I_DIRTY_DATASYNC);
> >                                     
> >     if (I_DIRTY_SYNC || I_DIRTY_DATASYNC)  <---- so this will be true for most time
> >       write_inode
> >         nfs_write_inode
> >           nfs_commit_inode
> 
> 
> I have been working on a fix for this. We basically do want to ensure
> that NFS calls commit (otherwise we're not finished cleaning the dirty
> pages), but we want to do it _after_ we've waited for all the writes to
> complete. See below...
> 
> Trond
> 
> ------------------------------------------------------------------------------------------------------ 
> VFS: Add a new inode state: I_UNSTABLE_PAGES
> 
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> Add a new inode state to enable the vfs to commit the nfs unstable pages to
> stable storage once the write back of dirty pages is done.
  Hmm, does your patch really help?

> @@ -474,6 +482,18 @@ writeback_single_inode(struct inode *inode, struct writeback_control *wbc)
>  	}
>  
>  	spin_lock(&inode_lock);
> +	/*
> +	 * Special state for cleaning NFS unstable pages
> +	 */
> +	if (inode->i_state & I_UNSTABLE_PAGES) {
> +		int err;
> +		inode->i_state &= ~I_UNSTABLE_PAGES;
> +		spin_unlock(&inode_lock);
> +		err = commit_unstable_pages(inode, wait);
> +		if (ret == 0)
> +			ret = err;
> +		spin_lock(&inode_lock);
> +	}
  I don't quite understand this chunk: We've called writeback_single_inode
because it had some dirty pages. Thus it has I_DIRTY_DATASYNC set and a few
lines above your chunk, we've called nfs_write_inode which sent commit to
the server. Now here you sometimes send the commit again? What's the
purpose?

> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index faa0918..4f129b3 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -99,17 +99,14 @@ u64 nfs_compat_user_ino64(u64 fileid)
>  
>  int nfs_write_inode(struct inode *inode, int sync)
>  {
> +	int flags = 0;
>  	int ret;
>  
> -	if (sync) {
> -		ret = filemap_fdatawait(inode->i_mapping);
> -		if (ret == 0)
> -			ret = nfs_commit_inode(inode, FLUSH_SYNC);
> -	} else
> -		ret = nfs_commit_inode(inode, 0);
> -	if (ret >= 0)
> +	if (sync)
> +		flags = FLUSH_SYNC;
> +	ret = nfs_commit_inode(inode, flags);
> +	if (ret > 0)
>  		return 0;
> -	__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
>  	return ret;
>  }
>  

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR
