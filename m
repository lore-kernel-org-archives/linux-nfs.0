Return-Path: linux-nfs-owner@vger.kernel.org
Received: from peace.netnation.com ([204.174.223.2]:40265 "EHLO
	peace.netnation.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753162Ab2ITANF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Sep 2012 20:13:05 -0400
Date: Wed, 19 Sep 2012 17:13:03 -0700
From: Simon Kirby <sim@hostway.ca>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [3.6-rc3] rdirplus broken? (EBUSY)
Message-ID: <20120920001303.GC8249@hostway.ca>
References: <20120827215510.GL24761@hostway.ca>
 <20120911192523.GA11160@hostway.ca>
 <20120912121613.GC3009@fieldses.org>
 <20120912212035.GB28555@hostway.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120912212035.GB28555@hostway.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 12, 2012 at 02:20:35PM -0700, Simon Kirby wrote:

> On Wed, Sep 12, 2012 at 08:16:13AM -0400, J. Bruce Fields wrote:
> 
> > The symptoms sound similar to
> > http://marc.info/?l=linux-fsdevel&m=134738157303017&w=2
> > 
> > Might be worth checking whether it's that patch?
> 
> Indeed! I tried this hack:
> 
> diff --git a/fs/dcache.c b/fs/dcache.c
> index 8086636..649a112 100644
> --- a/fs/dcache.c
> +++ b/fs/dcache.c
> @@ -2404,6 +2404,10 @@ out_unalias:
>  	if (likely(!d_mountpoint(alias))) {
>  		__d_move(alias, dentry);
>  		ret = alias;
> +	} else {
> +		printk(KERN_WARNING "VFS: __d_move()ing a d_mountpoint(), uh oh\n");
> +		__d_move(alias, dentry);
> +		ret = alias;
>  	}
>  out_err:
>  	spin_unlock(&inode->i_lock);
> 
> With this applied, "ls -l flick" prints:
> 
> [   77.217420] VFS: __d_move()ing a d_mountpoint(), uh oh
> [   77.222390] VFS: __d_move()ing a d_mountpoint(), uh oh
> 
> ...and "pics" and "raid" then work as they did before, or with "nordirplus"
> set. So, is something broken with nordirplus or the NFS layer, or should
> __d_unalias() really move a mountpoint? With nordirplus, it works without
> complaining about moving a mountpoint.

By the way, This seems fixed in 3.6-rc6, likely due to
c3f52af3e03013db5237e339c817beaae5ec9e3a. Thanks!

Simon-
