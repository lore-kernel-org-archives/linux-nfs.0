From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] [PATCH 2/14] locks: factor out generic/filesystem switch from test_lock
Date: Sat, 3 Feb 2007 20:52:41 -0500
Message-ID: <20070204015241.GH7588@fieldses.org>
References: <5cdd83858bf5c75e14742bbd03b462f5ec4997fe.1170479265.git.bfields@citi.umich.edu> <1170549125.5749.1.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net,
	Marc Eshel <eshel@almaden.ibm.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1170549125.5749.1.camel@lade.trondhjem.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Sat, Feb 03, 2007 at 04:32:05PM -0800, Trond Myklebust wrote:
> On Sat, 2007-02-03 at 00:33 -0500, J. Bruce Fields wrote:
> > From: J. Bruce Fields <bfields@snoopy.citi.umich.edu> - unquoted
> > +int vfs_test_lock(struct file *filp, struct file_lock *fl, struct file_lock *conf)
> > +{
> > +	int error;
> > +
> > +	conf->fl_type = F_UNLCK;
> > +	if (filp->f_op && filp->f_op->lock) {
> > +		__locks_copy_lock(conf, fl);
> > +		error = filp->f_op->lock(filp, F_GETLK, conf);
> > +		if (conf->fl_ops && conf->fl_ops->fl_release_private)
> > +			conf->fl_ops->fl_release_private(conf);
> 
> Why are you adding in a "release" call here? Is there any reason why a
> GETLK would want to return private data from the filesystem to the VFS?

I'm not adding it--it's already there in the current code for
fcntl_getlk().

I looked over the nfsv4 implementation of ->lock in the getlk case, and
it looks to me like it does in fact return the lock with private data
still set, and counts on the VFS to release it.  But I was just skimming
and may have overlooked something.

--b.
