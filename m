Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:34781 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932148AbbGUV6f (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Jul 2015 17:58:35 -0400
Date: Wed, 22 Jul 2015 07:58:24 +1000
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Kinglong Mee <kinglongmee@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 10/10 v7] nfsd: Allows user un-mounting filesystem where
 nfsd exports base on
Message-ID: <20150722075824.3e7498ce@noble>
In-Reply-To: <20150716205148.GC10673@fieldses.org>
References: <55A11010.6050005@gmail.com>
	<55A111A8.2040701@gmail.com>
	<20150713133934.6a4ef77d@noble>
	<20150715210756.GE21669@fieldses.org>
	<20150716094046.445c038b@noble>
	<20150716205148.GC10673@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 16 Jul 2015 16:51:48 -0400 "J. Bruce Fields"
<bfields@fieldses.org> wrote:

> On Thu, Jul 16, 2015 at 09:40:46AM +1000, NeilBrown wrote:
> > On Wed, 15 Jul 2015 17:07:56 -0400 "J. Bruce Fields"
> > <bfields@fieldses.org> wrote:
> > 
> > > > Wow.... this is turning out to be a lot more complex that I imagined at
> > > > first (isn't that always the way!).
> > > > 
> > > > There is a lot of good stuff here, but I think we can probably make it
> > > > simpler and so even better.
> > > 
> > > I'm still not convinced that the expkey
> 
> (Sorry, I meant an entry in the export cache, not the expkey cache.)

They are very closely related.  An incoming filehandle has its 'fs'
identifier mapped through the expkey cache to get an "export point".
Then the "export point" plus "client identifier" are mapped through the
export cache to get export options.

So the "export point" thing in the expkey cache should really be the
same as the thing in the export cache.

> 
> > should have a dentry reference
> > > in the key in the first place.  Fixing that would fix the immediate
> > > problem.
> > 
> > ???  If we removed the dentry, how would you export a subdirectory of a
> > filesystem?
> 
> I've been wondering if the export cache should really be keyed on the
> string representation of the path instead of the struct path.  That's
> what the userspace interface uses.

That makes sense for handling updates to the cache from user-space.
I'm not sure it is so good for handling mapping from file-handle to
export flags.

> 
> There's a related bug: if there are mountpoints at both /a and /a/b,

Just to make sure I'm clear on what you are saying, this would be
achieved by, e.g.

 mkdir -p /a/b
 mount /dev/sdX /a/b
 mount /dev/sdY /a

so the mount of /dev/sdX is complete unreachable from '/'.

Correct?

> then thanks to the lookup-underneath-mountpoint behavior of the server,
> an NFSv3 client looking that up will end up going underneath the first
> mountpoint and doing an export cache lookup for
> 
> 	(vfsmnt, dentry) == (/, /a/b)

Maybe this step is where the bug is. "/a/b" is not really a valid name.
Should d_path() check for paths that have been mounted over, and attach
"(unreachable)" to the end of the path, similar to "(deleted)".

sys_getcwd() can give you "(unreachable)" when in a filesystem that has
e.g. been lazy-unmounted.  Maybe we want something similar for a
mounted-over filesystem???


> 
> When the server gets a response that starts with "/a/b", it interprets
> that as applying to the path (/a, /a/b), so doesn't recognize it as
> resolving the query about (/, /a/b).
> 
> Well, at least I assume that's why I see "ls" hang if I run "ls
> /mnt/a/b" on the client.  And there may be some better fix, but I always
> figured the root (hah) problem here was due to indexing the cache on
> struct path while the upcall interface uses the full path string.
> 
Sounds like a very odd corner case - how did you stumble on to it?

Thanks,
NeilBrown
