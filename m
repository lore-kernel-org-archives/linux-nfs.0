From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 2/14] locks: factor out generic/filesystem switch from test_lock
Date: Sat, 3 Feb 2007 20:48:44 -0500
Message-ID: <20070204014844.GG7588@fieldses.org>
References: <ad8373acbb12f165b625f6065bc0ca86f3982b7f.1170479265.git.bfields@citi.umich.edu> <5cdd83858bf5c75e14742bbd03b462f5ec4997fe.1170479265.git.bfields@citi.umich.edu> <20070203085025.GB18828@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net,
	Marc Eshel <eshel@almaden.ibm.com>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070203085025.GB18828@infradead.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Sat, Feb 03, 2007 at 08:50:25AM +0000, Christoph Hellwig wrote:
> > +int vfs_test_lock(struct file *filp, struct file_lock *fl, struct file_lock *conf)
> 
> Please make sure to add linebreaks after at most 80 characters.

OK, done.

> 
> > +	error = vfs_test_lock(filp, &file_lock, &cfl);
> > +	if (error)
> > +		goto out;
> 
> > +	fl = (cfl.fl_type == F_UNLCK ? NULL : &cfl);
> >  	flock.l_type = F_UNLCK;
> >  	if (fl != NULL) {
> 
> This code snippled is more than ugly.  fl is only checked for equality
> once so you should reformulate that check using the actual type check:
> 
> 	if (cfl.fl_type != F_UNLCK) {
> 
> That also allows you to move the
> 
> 	flock.l_type = fl->fl_type;
> 
> out of the if statement later on.

That's a good idea, thanks; done.

Actually, I wonder if there's any reason we couldn't also just give
posix_test_lock() the same interface as ->lock?  (The latter uses the
same file_lock argument for the input and (in the case where it finds
a conflicting lock) the output, where the former uses an extra argument
to pass back the lock.)  That'd make this a little simpler too.

> In fact that copying out should proably move into posix_lock_to_flock
> and posix_lock_to_fock64 helpers similar to the flock_to_posix_lock
> and flock64_to_posix_lock helpers we have for the other way around.

OK!--b.
