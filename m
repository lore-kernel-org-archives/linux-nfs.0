Return-Path: linux-nfs-owner@vger.kernel.org
Received: from peace.netnation.com ([204.174.223.2]:46623 "EHLO
	peace.netnation.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752254Ab2JCBRz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Oct 2012 21:17:55 -0400
Date: Tue, 2 Oct 2012 18:17:53 -0700
From: Simon Kirby <sim@hostway.ca>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [3.6-rc3] rdirplus broken? (EBUSY)
Message-ID: <20121003011753.GA17905@hostway.ca>
References: <20120827215510.GL24761@hostway.ca>
 <20120911192523.GA11160@hostway.ca>
 <20120912121613.GC3009@fieldses.org>
 <20120912212035.GB28555@hostway.ca>
 <20120920001303.GC8249@hostway.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120920001303.GC8249@hostway.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 19, 2012 at 05:13:03PM -0700, Simon Kirby wrote:

> On Wed, Sep 12, 2012 at 02:20:35PM -0700, Simon Kirby wrote:
> 
> > On Wed, Sep 12, 2012 at 08:16:13AM -0400, J. Bruce Fields wrote:
> > 
> > > The symptoms sound similar to
> > > http://marc.info/?l=linux-fsdevel&m=134738157303017&w=2
> > > 
> > > Might be worth checking whether it's that patch?
> > 
> > Indeed! I tried this hack:
> > 
> > diff --git a/fs/dcache.c b/fs/dcache.c
> > index 8086636..649a112 100644
> > --- a/fs/dcache.c
> > +++ b/fs/dcache.c
> > @@ -2404,6 +2404,10 @@ out_unalias:
> >  	if (likely(!d_mountpoint(alias))) {
> >  		__d_move(alias, dentry);
> >  		ret = alias;
> > +	} else {
> > +		printk(KERN_WARNING "VFS: __d_move()ing a d_mountpoint(), uh oh\n");
> > +		__d_move(alias, dentry);
> > +		ret = alias;
> >  	}
> >  out_err:
> >  	spin_unlock(&inode->i_lock);
> > 
> > With this applied, "ls -l flick" prints:
> > 
> > [   77.217420] VFS: __d_move()ing a d_mountpoint(), uh oh
> > [   77.222390] VFS: __d_move()ing a d_mountpoint(), uh oh
> > 
> > ...and "pics" and "raid" then work as they did before, or with "nordirplus"
> > set. So, is something broken with nordirplus or the NFS layer, or should
> > __d_unalias() really move a mountpoint? With nordirplus, it works without
> > complaining about moving a mountpoint.
> 
> By the way, This seems fixed in 3.6-rc6, likely due to
> c3f52af3e03013db5237e339c817beaae5ec9e3a. Thanks!

I confused myself with my own patch here. This still happens to me in
release 3.6, making it not possible for me to use these NFS mounts unless
I set "nordirplus" or apply my above call-__d_move-anyway patch.

I'm also getting file data corruption when mounted TCP, for some stupid
reason, even with all TSO/GSO/GRO disabled, and this goes away with UDP.
Reproducible on different client hardware, and on client kernels back to
2.6.32. Probably related to the 3.4.1 server. More debugging to do...

Simon-
