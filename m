Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f174.google.com ([74.125.82.174]:55640 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758055Ab2AFVg3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Jan 2012 16:36:29 -0500
Message-ID: <1325892968.4847.4.camel@lappy>
Subject: Re: Boot regression caused by commit 6829a048
From: Sasha Levin <levinsasha928@gmail.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux@razik.name, Trond.Myklebust@netapp.com,
        Pekka Enberg <penberg@kernel.org>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>
Date: Sat, 07 Jan 2012 01:36:08 +0200
In-Reply-To: <5A327123-1097-474C-A7F6-7C29BB71FCEE@oracle.com>
References: <1325871176.4629.35.camel@lappy>
	 <5A327123-1097-474C-A7F6-7C29BB71FCEE@oracle.com>
Content-Type: text/plain; charset="us-ascii"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2012-01-06 at 13:29 -0500, Chuck Lever wrote:
> On Jan 6, 2012, at 12:32 PM, Sasha Levin wrote:
> 
> > Hi all,
> > 
> > I've noticed a boot regression caused by commit 6829a048 ("NFS: Retry
> > mounting NFSROOT") which has increased boot time by 95 seconds.
> > 
> > The scenario is as follows:
> > - A virtual guest running under the KVM tool.
> > - Guest is using kernel automatic IP DHCP configuration ("ip=dhcp").
> > - Guest is booting from a 9p device (which is not detected as block,
> > and gets mounted after NFS tries to do its mounts).
> > - No NFS server at all, no NFS parameters passed to the guest kernel.
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
> > 
> > This probably happens since the NFS server isn't configured, so the
> > bootserver is automatically assumed to be the DHCP server, and with the
> > commit above we won't simply fail immediately when the NFS code fails
> > connecting to it.
> > 
> > I'm not quite sure about the correct solution for this. While I can
> > forcefully disable NFS, is it really the right solution? Should we be
> > retrying a NFS server even if one wasn't specifically set?
> 
> What DHCP options are passed to the client?  You can specify the "nfsrootdebug" boot command line option to explore this a little more.

This is what came out:

[    5.220654] NFS: nfs mount opts='vers=2,udp,rsize=4096,wsize=4096,nolock,addr=0.0.0.0'
[    5.226382] NFS:   parsing nfs mount option 'vers=2'
[    5.227707] NFS:   parsing nfs mount option 'udp'
[    5.228781] NFS:   parsing nfs mount option 'rsize=4096'
[    5.230307] NFS:   parsing nfs mount option 'wsize=4096'
[    5.231537] NFS:   parsing nfs mount option 'nolock'
[    5.232834] NFS:   parsing nfs mount option 'addr=0.0.0.0'
[    5.234069] NFS: mount program didn't pass remote address

> Typically ip= is used specifically with NFSROOT.  You might review Documentation/filesystems/nfs/nfsroot.txt to see if some combination of boot command line options gives more desirable behavior.

Within nfsroot.txt, it says I should specify "root=/dev/nfs" so that
nfsroot would be used. Why do we try mounting nfsroot if I specifically
specify something else under "root="?


-- 

Sasha.

