Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:53440 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758693Ab2AFXQo convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Jan 2012 18:16:44 -0500
Message-ID: <1325891801.11799.5.camel@lade.trondhjem.org>
Subject: Re: Boot regression caused by commit 6829a048
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: chuck.lever@oracle.com, linux@razik.name,
        Pekka Enberg <penberg@kernel.org>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>
Date: Fri, 06 Jan 2012 18:16:41 -0500
In-Reply-To: <1325892770.4847.1.camel@lappy>
References: <1325871176.4629.35.camel@lappy>
	 <1325874404.32470.6.camel@lade.trondhjem.org>
	 <1325892770.4847.1.camel@lappy>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2012-01-07 at 01:32 +0200, Sasha Levin wrote: 
> On Fri, 2012-01-06 at 13:26 -0500, Trond Myklebust wrote:
> > On Fri, 2012-01-06 at 19:32 +0200, Sasha Levin wrote: 
> > > Hi all,
> > > 
> > > I've noticed a boot regression caused by commit 6829a048 ("NFS: Retry
> > > mounting NFSROOT") which has increased boot time by 95 seconds.
> > > 
> > > The scenario is as follows:
> > >  - A virtual guest running under the KVM tool.
> > >  - Guest is using kernel automatic IP DHCP configuration ("ip=dhcp").
> > >  - Guest is booting from a 9p device (which is not detected as block,
> > > and gets mounted after NFS tries to do its mounts).
> > >  - No NFS server at all, no NFS parameters passed to the guest kernel.
> > > 
> > > Under this scenario, theres an additional 95 second delay before NFS
> > > fails and tries to boot using 9p:
> > > 
> > > [...]
> > > [    6.505269] md: autorun ...
> > > [    6.506954] md: ... autorun DONE.
> > > [  101.522716] VFS: Unable to mount root fs via NFS, trying floppy.
> > > [  101.534499] VFS: Mounted root (9p filesystem) on device 0:18.
> > > [...]
> > 
> > Can't you avoid the whole NFS root mount attempt by setting "root=2:0"
> > directly instead of relying on 'mount_root' to do it for you?
> 
> I am specifying root and root parameters fully:
> 
> "root=/dev/root rw rootflags=rw,trans=virtio,version=9p2000.L
> rootfstype=9p"
> 
> Actually, I'm not sure why NFS comes to play at all in this case.

It's because mount_root() tests MAJOR(ROOT_DEV) only when probing for
nfsroot. Since ROOT_DEV is initialised to 0, and root=/dev/root matches
nothing in name_to_dev_t(), then you end up matching the nfsroot test.

A simple fix would be either:

A) skip the root=/dev/root.
B) change mount_root to also test MINOR(ROOT_DEV), which should equal
255 if ROOT_DEV==Root_NFS

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

