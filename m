Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:5107 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755746Ab2HGW1G (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Aug 2012 18:27:06 -0400
Date: Tue, 7 Aug 2012 18:26:51 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        steved@redhat.com
Subject: Re: nfs4 mounts failing with 3.6.0-rc1
Message-ID: <20120807182651.32448074@tlielax.poochiereds.net>
In-Reply-To: <1344374613.8845.3.camel@lade.trondhjem.org>
References: <20120804000819.GB25558@fieldses.org>
	<20120803220039.743fe1f0@corrin.poochiereds.net>
	<20120804190104.GA2135@fieldses.org>
	<20120807130932.79625d7e@tlielax.poochiereds.net>
	<20120807194250.GB22532@fieldses.org>
	<50217035.5010304@netapp.com>
	<20120807195703.GC22532@fieldses.org>
	<50217649.6010402@netapp.com>
	<20120807202523.GD22532@fieldses.org>
	<1344374613.8845.3.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 7 Aug 2012 21:23:34 +0000
"Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Tue, 2012-08-07 at 16:25 -0400, J. Bruce Fields wrote:
> > On Tue, Aug 07, 2012 at 04:10:49PM -0400, Bryan Schumaker wrote:
> > > On 08/07/2012 03:57 PM, J. Bruce Fields wrote:
> > > > On Tue, Aug 07, 2012 at 03:44:53PM -0400, Bryan Schumaker wrote:
> > > >> On 08/07/2012 03:42 PM, J. Bruce Fields wrote:
> > > >>> On Tue, Aug 07, 2012 at 01:09:32PM -0400, Jeff Layton wrote:
> > > >>>> On Sat, 4 Aug 2012 15:01:04 -0400
> > > >>>> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > > >>>>
> > > >>>>> On Fri, Aug 03, 2012 at 10:00:39PM -0400, Jeff Layton wrote:
> > > >>>>>> On Fri, 3 Aug 2012 20:08:19 -0400
> > > >>>>>> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > > >>>>>>
> > > >>>>>>> I'm getting
> > > >>>>>>>
> > > >>>>>>> 	# mount -tnfs -onfsvers=4 pip1:/exports /mnt/
> > > >>>>>>>
> > > >>>>>>> (OK, admittedly that's with 3.6.0-rc1 + a few experimental patches, but
> > > >>>>>>> I doubt they're related.)
> > > >>>>>>>
> > > >>>>>>> Also:
> > > >>>>>>>
> > > >>>>>>> 	[root@pip2 ~]# modprobe nfs4
> > > >>>>>>> 	[root@pip2 ~]# lsmod|grep nfs4
> > > >>>>>>> 	[root@pip2 ~]# 
> > > >>>>>>>
> > > >>>>>>> --b.
> > > >>>>>>
> > > >>>>>> I hit the same problem...
> > > >>>>>>
> > > >>>>>> Try removing /usr/lib/modprobe.d/nfs.conf (assuming you're running
> > > >>>>>> Fedora).
> > > >>>>>
> > > >>>>> Oog, right.
> > > >>>>>
> > > >>>>> But, without testing--won't that make v4 mounts fail on older kernels?
> > > >>>>
> > > >>>> Actually, now that I look, this does not seem to break on older kernels
> > > >>>> as long as you use a syntax like:
> > > >>>>
> > > >>>>     # mount -t nfs server:/export /mnt/point -o vers=4
> > > >>>>
> > > >>>> ...if, however you use a syntax like:
> > > >>>>
> > > >>>>     # mount -t nfs4 server:/export /mnt/point
> > > >>>>
> > > >>>> ...then it fails without the above file in place. I guess the question
> > > >>>> we have to answer is: Do we want to continue to support the "-t nfs4"
> > > >>>> mount syntax?
> > > >>>
> > > >>> I think you're right that we want to deprecate it.
> > > >>>
> > > >>> Though this is a bit of a harsh way to do it--would have been nice to
> > > >>> have some transition period with a warning or something.
> > > >>
> > > >> I didn't expect this to be broken, both ways of mounting still work on my VMs so I expected them to work for everybody else too.
> > > > 
> > > > Huh.  Just checked on an old kernel without an "alias nfs4 nfs" in
> > > > modprobe configuration, and sure enough I get "No such device".
> > > > 
> > > > Maybe you have some initscripts or something else that's loading the
> > > > nfs module for you before the mount?
> > > 
> > > My nfs-common daemon script loads sunrpc, nfs
> > 
> > Yep, that's why you're not seeing it.
> > 
> > > and nfsd but not nfs2, nfs3 or nfs4.
> > > 
> > > Could we rename the module to avoid the alias name collision?  Something like this (untested) maybe?
> > 
> > I don't think that will help.
> 
> It should if we also add back in
> 
> struct file_system_type nfs4_fs_type = {
>         .owner          = THIS_MODULE,
>         .name           = "nfs4",
>         .mount          = nfs_fs_mount,
>         .kill_sb        = nfs_kill_super,
>         .fs_flags       = FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
> };
> 
> and then add that to register_nfs_fs()/unregister_nfs_fs(). As far as I
> can see, that will trigger all the right incantations in
> nfs_validate_mount_data() to mount an NFSv4 filesystem.
> 

So, move the nfs4 fstype definition back into nfs.ko? That would
ensure that you could still do a "-t nfs4" mount with that modprobe
alias in place.

I think Bryan is correct though. We'll also need to rename nfs4.ko or
you won't ever be able to call request_module for it in order to plug
it in if you have that module alias in place.

Does this mean that we plan to support the "-t nfs4" mount syntax in
perpetuity?

-- 
Jeff Layton <jlayton@redhat.com>
