From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 3/14] locks: factor out generic/filesystem switch from setlock code
Date: Sat, 3 Feb 2007 21:27:50 -0500
Message-ID: <20070204022750.GL7588@fieldses.org>
References: <ad8373acbb12f165b625f6065bc0ca86f3982b7f.1170479265.git.bfields@citi.umich.edu> <1dd47bf9aeb6f19c82a59efb2f4236f23f73019d.1170479265.git.bfields@citi.umich.edu> <20070203085136.GC18828@infradead.org> <20070203051638.GA29763@cynthia.pants.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net,
	Marc Eshel <eshel@almaden.ibm.com>
To: Brad Boyer <flar@allandria.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070203051638.GA29763@cynthia.pants.nu>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Fri, Feb 02, 2007 at 09:16:38PM -0800, Brad Boyer wrote:
> On Sat, Feb 03, 2007 at 08:51:36AM +0000, Christoph Hellwig wrote:
> > On Sat, Feb 03, 2007 at 12:33:59AM -0500, J. Bruce Fields wrote:
> > > + */
> > > +int vfs_lock_file(struct file *filp, unsigned int cmd, struct file_lock *fl)
> > > +{
> > > +	if (filp->f_op && filp->f_op->lock)
> > > +		return filp->f_op->lock(filp, cmd, fl);
> > > +	else
> > > +		return posix_lock_file(filp, fl);
> > > +}
> > > +EXPORT_SYMBOL(vfs_lock_file);
> > 
> > _GPL please (and same for the last patch)
> 
> Any particular reason? It seems like this is a function that
> would be exactly the sort of thing to be publically exported.
> I know it's not a popular opinion around here, but I think
> that the GPL exports should be primarily for things that
> aren't intended to be used by normal modules.

Actually, this is only used by the NLM and NFSv4 servers.  I doubt
there will be other users any time soon.

If you really want to argue about the EXPORT_SYMBOL_GPL stuff you'll
want to google through the archives for previous discussions first.

--b.
