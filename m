From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] nfs4: handle situation where dentry wasn't revalidated
 on open
Date: Fri, 13 Nov 2009 09:13:52 -0500
Message-ID: <20091113091352.51bddfdb@tlielax.poochiereds.net>
References: <1258118636-1348-1-git-send-email-jlayton@redhat.com>
	<1258119000.7430.5.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org, ebiederm@xmission.com,
	adobriyan@gmail.com, viro@ZenIV.linux.org.uk, jamie@shareable.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1258119000.7430.5.camel@heimdal.trondhjem.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 13 Nov 2009 22:30:00 +0900
Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> On Fri, 2009-11-13 at 08:23 -0500, Jeff Layton wrote:
> > This patch is an alternate approach to fixing this problem that doesn't
> > rely on VFS changes...
> > 
> > Currently, the NFSv4 client code relies on the ->lookup and
> > ->d_revalidate codepaths to handle the open processing during lookup. In
> > certain situations (notably LAST_BIND symlinks and file bind mounts)
> > it's possible for the VFS to skip calling d_revalidate on a dentry that
> > it finds in the cache. If this is done on an open call, the file doesn't
> > get opened on the wire, no state is established and stateful operations
> > fail against it.
> > 
> > This patchset fixes this problem by taking advantage of the fact that we
> > can pass an open routine to lookup_instantiate_filp. A new open file
> > operation for NFSv4 is added that should only be called if the filp
> > wasn't instantiated during lookup. The original open routine is passed
> > to lookup_instantiate_filp to ensure no change in behavior there.
> > 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> <snip>
> > +/*
> > + * should only be called when VFS skips revalidation
> > + */
> > +int
> > +nfs4_open(struct inode *inode, struct file *filp)
> > +{
> > +	struct inode *dir = filp->f_path.dentry->d_parent->d_inode;
> > +	struct rpc_cred *cred;
> > +	struct nfs_open_context *ctx;
> > +
> > +	cred = rpc_lookup_cred();
> > +	if (IS_ERR(cred))
> > +		return PTR_ERR(cred);
> > +
> > +	ctx = alloc_nfs_open_context(filp->f_path.mnt, filp->f_path.dentry, cred);
> > +	if (ctx == NULL) {
> > +		put_rpccred(cred);
> > +		return -ENOMEM;
> > +	}
> > +
> > +	ctx->state = nfs4_do_open(dir, &filp->f_path, filp->f_mode, filp->f_flags, NULL, cred);
> > +	put_rpccred(cred);
> > +	if (IS_ERR(ctx->state)) {
> > +		put_nfs_open_context(ctx);
> > +		return PTR_ERR(ctx->state);
> > +	}
> > +	ctx->mode = filp->f_mode;
> > +	nfs_set_verifier(filp->f_path.dentry, nfs_save_change_attribute(dir));
> > +	nfs_file_set_open_context(filp, ctx);
> > +	put_nfs_open_context(ctx);
> > +	nfs_fscache_set_inode_cookie(inode, filp);
> > +	return 0;
> > +}
> > +
> 
> So what happens if the file has been renamed/deleted/replaced since the
> lookup occurred? You basically end up with a state that corresponds to a
> different file than the filp->f_path...
> 

Good point...

I suppose I could add a check that the state->inode is the right one.
I'm not certain what to do if they aren't though...

I suppose we'd need to unhash the old dentry, and instantiate a new one,
but it is OK to swap out the dentry in the f_path with the new one?
Maybe I should just wait for your overhaul of the open codepath...
-- 
Jeff Layton <jlayton@redhat.com>
