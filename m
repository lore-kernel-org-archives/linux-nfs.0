From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: READDIRPLUS max mount option
Date: Fri, 07 Mar 2008 15:42:50 -0500
Message-ID: <1204922570.16746.37.camel@heimdal.trondhjem.org>
References: <47D1995E.6060501@krose.org>
	 <1204919978.16746.12.camel@heimdal.trondhjem.org>
	 <47D1A0F5.2070501@krose.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org
To: Kyle Rose <krose-x8616dYPWyvYtjvyW6yDsg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:43658 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761181AbYCGUmy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Mar 2008 15:42:54 -0500
In-Reply-To: <47D1A0F5.2070501-x8616dYPWyvYtjvyW6yDsg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Fri, 2008-03-07 at 15:09 -0500, Kyle Rose wrote:
> > The binary mount format is frozen forever, so the changes to nfs_mount.h
> > and nfs4_mount.h are definitely NACKed.
> >   
> Ah. :-)  So is there no way to add mount options, or is there a 
> different mechanism today?

Newer versions of 'mount' should use the text-based interface.

> > Otherwise, it would be nice to know why this absolutely has to be made a
> > mount option rather than just having a system-wide option (either a
> > module/boot parameter or a sysctl) to control the behaviour of all
> > mounts.
> >   
> I mount multiple remote file systems.  Only one of them I own, so I'm 
> willing to potentially hammer it with huge READDIRPLUS requests, while 
> the others probably deserve more benign behavior. ;-)

The size of the actual READDIRPLUS requests is completely unaffected by
your patch. Your change actually means that the client will continue to
use READDIRPLUS on very large directories instead of falling back to
readdir.
The reason for falling back to readdir is that value of readdirplus
tends to decrease with larger directories as the cost of caching all
those dentries, attributes and filehandles both on the client and the
server goes up.

If you want a faster readdir(), you will find that splitting those huge
directories up into smaller subdirs is an alternative solution that
tends to scale much better on both client and server.

> In general, I think having system-wide defaults somewhere in proc is 
> helpful---and certainly superior to a constant in the source---but there 
> should really be mount-specific overrides wherever the system-wide 
> default might not be globally appropriate.

Having hundreds of mount options for minor tweaks is not an acceptable
practice. Each mount option needs to be abundantly justified.

Since we're talking about what is really a quite arbitrary limit, I can
certainly see an argument for why we might want a way to change it, but
I'm still not convinced that we need to be setting this parameter at the
mountpoint level.

Cheers
  Trond

