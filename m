Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f174.google.com ([74.125.82.174]:47618 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752928Ab2AFVdL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Jan 2012 16:33:11 -0500
Message-ID: <1325892770.4847.1.camel@lappy>
Subject: Re: Boot regression caused by commit 6829a048
From: Sasha Levin <levinsasha928@gmail.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: chuck.lever@oracle.com, linux@razik.name,
        Pekka Enberg <penberg@kernel.org>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>
Date: Sat, 07 Jan 2012 01:32:50 +0200
In-Reply-To: <1325874404.32470.6.camel@lade.trondhjem.org>
References: <1325871176.4629.35.camel@lappy>
	 <1325874404.32470.6.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="us-ascii"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2012-01-06 at 13:26 -0500, Trond Myklebust wrote:
> On Fri, 2012-01-06 at 19:32 +0200, Sasha Levin wrote: 
> > Hi all,
> > 
> > I've noticed a boot regression caused by commit 6829a048 ("NFS: Retry
> > mounting NFSROOT") which has increased boot time by 95 seconds.
> > 
> > The scenario is as follows:
> >  - A virtual guest running under the KVM tool.
> >  - Guest is using kernel automatic IP DHCP configuration ("ip=dhcp").
> >  - Guest is booting from a 9p device (which is not detected as block,
> > and gets mounted after NFS tries to do its mounts).
> >  - No NFS server at all, no NFS parameters passed to the guest kernel.
> > 
> > Under this scenario, theres an additional 95 second delay before NFS
> > fails and tries to boot using 9p:
> > 
> > [...]
> > [    6.505269] md: autorun ...
> > [    6.506954] md: ... autorun DONE.
> > [  101.522716] VFS: Unable to mount root fs via NFS, trying floppy.
> > [  101.534499] VFS: Mounted root (9p filesystem) on device 0:18.
> > [...]
> 
> Can't you avoid the whole NFS root mount attempt by setting "root=2:0"
> directly instead of relying on 'mount_root' to do it for you?

I am specifying root and root parameters fully:

"root=/dev/root rw rootflags=rw,trans=virtio,version=9p2000.L
rootfstype=9p"

Actually, I'm not sure why NFS comes to play at all in this case.

-- 

Sasha.

