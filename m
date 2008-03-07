From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: READDIRPLUS max mount option
Date: Fri, 07 Mar 2008 14:59:37 -0500
Message-ID: <1204919978.16746.12.camel@heimdal.trondhjem.org>
References: <47D1995E.6060501@krose.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org
To: Kyle Rose <krose-x8616dYPWyvYtjvyW6yDsg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:41596 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750718AbYCGT7m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Mar 2008 14:59:42 -0500
In-Reply-To: <47D1995E.6060501-x8616dYPWyvYtjvyW6yDsg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Fri, 2008-03-07 at 14:37 -0500, Kyle Rose wrote:
> I have a very specific use for an NFS mount over a WAN, and allowing for 
> much larger expected READDIRPLUS requests actually improves performance 
> by at least a factor of 10 by eliminating the round-trip latency that 
> results from the application's single-threaded 
> readdir/stat/stat/stat/... behavior.  Rather than maintain a hacked 
> kernel on my end, I'd rather the READDIRPLUS limit be a mount option.  
> Hence, the following patch.  It defaults to the old behavior 
> (8*PAGE_SIZE), but with a properly-prepared mount binary will allow the 
> client to specify a limit.
> 
> I'm not subscribed to the list, so please CC me in any relevant discussion.
> 
> Kyle

(adding cc to linux-nfs@vger.kernel.org)

The binary mount format is frozen forever, so the changes to nfs_mount.h
and nfs4_mount.h are definitely NACKed.

Otherwise, it would be nice to know why this absolutely has to be made a
mount option rather than just having a system-wide option (either a
module/boot parameter or a sysctl) to control the behaviour of all
mounts.

Cheers
  Trond

