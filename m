Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:42362 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752754AbeENQrp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 14 May 2018 12:47:45 -0400
Date: Mon, 14 May 2018 17:47:43 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Jeff Layton <jlayton@kernel.org>
Subject: Re: [RFC][PATCH] nfsd: vfs_mkdir() might succeed leaving dentry
 negative unhashed
Message-ID: <20180514164743.GI30522@ZenIV.linux.org.uk>
References: <20180511211339.GG30522@ZenIV.linux.org.uk>
 <20180514153216.GC7160@fieldses.org>
 <20180514154550.GH30522@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180514154550.GH30522@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 14, 2018 at 04:45:51PM +0100, Al Viro wrote:

> > > 	2) is nfserr_serverfail valid for situation when
> > > directory created by such vfs_mkdir() manages to disappear
> > > under us immediately afterwards?  Or should we return nfserr_stale
> > > instead?
> > 
> > We just got a successful result on the create and the parent's still
> > locked, so if somebody hits this I think we want them reporting a bug,
> > not wasting time trying to find a mistake in their own logic.
> 
> No.  Suppose it's NFS-over-NFS (and yes, I agree that it's a bad idea;
> somebody *has* done that).  Lookup after successful mkdir can legitimately
> fail if it's been removed server-side.
> 
> And we *will* need to allow nfs_mkdir() to return that way in some cases
> (== success with dentry passed to it left unhashed negative), I'm afraid ;-/

Consider the situation when you have NFS reexported - there's server S1,
exporting a filesystem to S2, which reexports it for client C.

On S2, process A does stat foo, gets ENOENT and proceeds to mkdir foo.  
Dentry of foo is passed to nfs_mkdir(), which calls e.g. nfs3_proc_mkdir(),
which calls nfs3_do_create(), which requests S1 to create the damn thing.
Then, after that succeeds, it calls nfs_instantiate().  There we would 
proceed to get the inode and call d_add(dentry, inode).

In the meanwhile, C, having figured out the fhandle S2 would assign to
foo (e.g. having spied upon the traffic, etc.) sends that fhandle to
S2.  nfs_fh_to_dentry() is called by process B on S2 (either knfsd, or,
in case if C==S2 and attacker has done open-by-fhandle - the caller
of open_by_handle(2)).  It gets the inode - the damn thing has been
created on S1 already.  That inode still has no dentries attached to
it (B has just set it up), so d_obtain_alias() creates one and attaches
to it.

Now A gets around to nfs_fhget() and finds the same inode.  Voila -
d_add(dentry, inode) and we are fucked; two dentries over the same
directory inode.  Fun starts very shortly when fs/exportfs/* code
is used by B to reconnect its dentry - the things really get bogus
once that constraint is violated.

The obvious solution would be to replace that d_add() with
	res = d_splice_alias(inode, dentry);
	if (IS_ERR(res)) {
		error = PTR_ERR(res);
		goto out_error;
	}
	dput(res);
	
leaving the dentry passed to nfs_mkdir() unhashed and negative if
we hit that race.  That's fine - the next lookup (e.g. the one
done by exportfs to reconnect the sucker) will find the right
dentry in dcache; it's just that it won't the one passed to
vfs_mkdir().

That's different from the local case - there mkdir gets the inumber,
inserts locked in-core inode with that inumber into icache and
only then proceeds to set on-disk data up.  Anyone guessing the
inumber (and thus the fhandle) will either get -ESTALE (if they
come first, as in this scenario) or find the in-core inode mkdir
is setting up and wait for it to be unlocked, at which point
d_obtain_alias() will already find it attached to dentry passed
to mkdir.

But that critically relies upon the icache search key being known
to mkdir *BEFORE* the on-disk metadata starts looking acceptable.
For NFS we really can't do that - there the key is S1's fhandle
and we don't get that until S1 has created the damn thing.

I don't see any variation of the trick used by local filesystems
that would not have this race; we really can end up with B getting
there first and creating directory inode with dentry attached to
it before A gets through.  Which, AFAICS, leaves only one solution -
let A put the dentry created by B in place of what had been passed
to A (and leave its argument unhashed).  Which is trivial to
implement (see above); however, it means that NFS itself is in
the same class as cgroup - its ->mkdir() may, in some cases,
end up succeeding and leaving its argument unhashed negative.
Note that dcache is perfectly fine after that - we have hashed
positive dentry with the right name and right parent, over the
inode for directory we'd just created; everything's fine, except
that it's not the struct dentry originally passed to vfs_mkdir().
