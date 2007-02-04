From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 3/14] locks: factor out generic/filesystem switch from setlock code
Date: Sat, 3 Feb 2007 20:58:13 -0500
Message-ID: <20070204015813.GI7588@fieldses.org>
References: <ad8373acbb12f165b625f6065bc0ca86f3982b7f.1170479265.git.bfields@citi.umich.edu> <1dd47bf9aeb6f19c82a59efb2f4236f23f73019d.1170479265.git.bfields@citi.umich.edu> <20070203085136.GC18828@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net,
	Marc Eshel <eshel@almaden.ibm.com>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070203085136.GC18828@infradead.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Sat, Feb 03, 2007 at 08:51:36AM +0000, Christoph Hellwig wrote:
> On Sat, Feb 03, 2007 at 12:33:59AM -0500, J. Bruce Fields wrote:
> > + */
> > +int vfs_lock_file(struct file *filp, unsigned int cmd, struct file_lock *fl)
> > +{
> > +	if (filp->f_op && filp->f_op->lock)
> > +		return filp->f_op->lock(filp, cmd, fl);
> > +	else
> > +		return posix_lock_file(filp, fl);
> > +}
> > +EXPORT_SYMBOL(vfs_lock_file);
> 
> _GPL please (and same for the last patch)

Oops, sorry--I think you asked for that before.  OK, done.

> 
> > +	for (;;) {
> > +		error = vfs_lock_file(filp, cmd, file_lock);
> > +		if ((error != -EAGAIN) || (cmd == F_SETLK))
> 
> No need for the inside braces here.
> 
> > +		error = vfs_lock_file(filp, cmd, file_lock);
> > +		if ((error != -EAGAIN) || (cmd == F_SETLK64))
> 
> again.

Got it, thanks.--b.
