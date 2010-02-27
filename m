From: Neil Brown <neilb@suse.de>
Subject: Re: Problem with nfs server reboot causing exports to jumble
Date: Sun, 28 Feb 2010 08:10:05 +1100
Message-ID: <20100228081005.6e29b367@notabene.brown>
References: <20100225192911.09CC318839E@wsnyder.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: wsnyder-12vJDDTx9R9AfugRpC6u6w@public.gmane.org (Wilson Snyder)
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:33520 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030875Ab0B0VKN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 27 Feb 2010 16:10:13 -0500
In-Reply-To: <20100225192911.09CC318839E-12vJDDTx9R9AfugRpC6u6w@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 25 Feb 2010 14:29:10 -0500 (EST)
wsnyder-12vJDDTx9R9AfugRpC6u6w@public.gmane.org (Wilson Snyder) wrote:

> 
> We're using the 2.6.18 x86_64 kernel (RH SL 5.1) with a NFS
> v3 server and NFS v3 clients using the automounter with options
> (rw,noatime,hard,intr,rsize=32768,wsize=32768,proto=tcp).
> 
> Our NFS server had several exports
> 
>     /export/a/{files-a}
>     /export/b/{files-b}
> 
> these were mounted on various clients.
> 
> We then added a new mount and export without rebooting:
> 
>     /export/a/{files-a}
>     /export/b/{files-b}
>     /export/c/{files-c}
> 
> All were visible on the clients, and everything was fine:
> 
>     /nfs/a/{files-a}
>     /nfs/b/{files-b}
>     /nfs/c/{files-c}
> 
> Our NFS server then crashed, and rebooted.  After reboot the
> clients then had:
> 
>     /nfs/a/{files-c}
>     /nfs/b/{files-a}
>     /nfs/c/{files-b}

There is lots of useful information you haven't given us, such as a copy
of /etc/exports, and /etc/fstab, and information about what hardware the
files are on, but at a guess:
 files-a and files-b were on /dev/sdc and /dev/sdd
you plugged in a new hard drive to store files-c.  It was called
/dev/sde.
But after a reboot the devices were discovered in a different order
and the one containing files-c is now called /dev/sdc,
files-a are on /dev/sdd and files-b are on /dev/sde.

As nfs in 2.6.18 uses the device id to identify a filesystem, the name of the
device that was mounted would be more important than the name of the place
where it was mounted on the server.

In more recent kernels and nfs-utils, the uuid of the filessytem is used in
preference to the device id, so this problem is avoided.

On your system you can add "fsid=1", "fsid=2" etc (avoid fsid=0) to help
disambiguate.
When you do this, the nfs server will still honour the old device-id-base
file handles, but will only give out the fsid= filehandles for new mounts.
So it will not break your current clients, but they will need to remount
before they can benefit from the increased stabilitiy of fsid= exports.

NeilBrown

> 
> Note the files correspond to the wrong exports.  Remounting
> on every client fixed the problem - once we realized what
> was going on!  (files-a/b/c were all similar so it wasn't
> immediately aparent)
> 
> My speculation is the reboot changed some enumeration
> causing a mismatch between the clients and servers.
> 
> This is a new one by me - is this a known issue, and if so
> is a patch available?
> 
> Other than patching, are there any precautions we can take
> to avoid this in the future?  (Other than not crashing the
> server, which we'd be happy to not to do. :)
> 
> Thanks
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

