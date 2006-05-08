From: Neil Brown <neilb@suse.de>
Subject: Re: [NFS] Re: [PATCH][RFC] NFS: Improving the access cache
Date: Mon, 8 May 2006 13:28:54 +1000
Message-ID: <17502.47862.957566.808437@cse.unsw.edu.au>
References: <444EC96B.80400@RedHat.com>
	<17486.64825.942642.594218@cse.unsw.edu.au>
	<444F88EF.5090105@RedHat.com>
	<17487.62730.16297.979429@cse.unsw.edu.au>
	<44572B33.4070100@RedHat.com>
	<445834CB.4050408@citi.umich.edu>
	<17502.45182.130630.119304@cse.unsw.edu.au>
	<445EB9A4.2080705@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Dickson <SteveD@redhat.com>, nfs@lists.sourceforge.net,
	linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: cel@citi.umich.edu
In-Reply-To: message from Chuck Lever on Sunday May 7
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Sunday May 7, cel@citi.umich.edu wrote:
> > If you have one particular file that is used regularly - and so never
> > falls out of cache - and is used occasionally by every single user in
> > your system, then that one inode could contribute to thousands of
> > access cache items that will never be purged.
> 
> I speculate that this would not be a problem.
> 
> First, each entry in the cache is not going to be very large.  For the 
> sake of easy math, let's say each one is 32 bytes.  One hundred thousand 
> of these is a little more than 3MB.  Or, say we have ten thousand files 
> with 10 different access cache entries: again, that's just about 3MB. 
> (Naturally I'm ignoring the slab accounting overhead).
> 
> Even a single-user system these days is going to have a gigabyte or more 
> of RAM, so we're talking less than a percent of memory tied up in this 
> case.  Three megabytes is probably less memory than a single Gnome 
> application uses for its working set.

:-)

> 
> I'm always told to start with a design that is as simple as possible 
> (and no simpler) and build on it only when I find a problem; this avoids 
> overdesign.  I don't see a compelling reason to start with a complicated 
> design here, and there are good reasons to keep it simple.

You are probably right.

> 
> If allowing the access cache to grow potentially without bounds still 
> makes you nervous, I maintain that we still want to avoid a global LRU. 
>   Having an LRU _per-inode_ might be a simple way to limit the amount of 
> memory that is consumed without the locking and management overhead of a 
> global LRU.  If entries haven't been accessed in more than actimeo 
> seconds, then purge them; we'll have to go back to the server to 
> revalidate such entries anyway, so there's no reason to keep them around.
> 
> It is pretty cheap to release, say, the two oldest entries every time 
> you try an access, provided they have not been touched in actimeo seconds.

If you want simple, a per-inode lru which is search linearly and
discards old entries as you suggest would probably be just right.
Leave the option of making a more sophisticated data structure if it
really seems necessary.

NeilBrown
