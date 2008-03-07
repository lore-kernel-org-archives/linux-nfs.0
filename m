From: Neil Brown <neilb@suse.de>
Subject: Re: [opensuse] nfs_update_inode: inode X mode changed, Y to Z
Date: Fri, 7 Mar 2008 15:38:53 +1100
Message-ID: <18384.50909.866848.966192@notabene.brown>
References: <47CF0829.4020502@m2000.com>
	<1204752463.5035.34.camel@heimdal.trondhjem.org>
	<47CF157B.1010908@m2000.com>
	<18383.24847.381754.517731@notabene.brown>
	<47CF62C5.7000908@m2000.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, lkml@vger.kernel.org,
	linux-nfs@vger.kernel.org, Thomas Daniel <tdaniel-PMR2DCmmWYEAvxtiuMwx3w@public.gmane.org>,
	jesper.juhl@gmail.com
To: Adam Schrotenboer <adam-PMR2DCmmWYEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:55736 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759347AbYCGEjG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Mar 2008 23:39:06 -0500
In-Reply-To: message from Adam Schrotenboer on Wednesday March 5
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wednesday March 5, adam-PMR2DCmmWYEAvxtiuMwx3w@public.gmane.org wrote:
> Neil Brown wrote:
> > On Wednesday March 5, adam-PMR2DCmmWYEAvxtiuMwx3w@public.gmane.org wrote:
> >   
> > Where :-)
> >
> > A excerpt from the logs to show actual error messages could be
> > helpful.
> >
> > Thanks,
> > NeilBrown
> sorry, must have missed the paste
> 
> Feb 28 17:27:58 koi kernel: nfs_update_inode: inode 3221350147 mode 
> changed, 0040755 to 0100644
> Feb 28 21:57:22 koi kernel: nfs_update_inode: inode 2149056279 mode 
> changed, 0040755 to 0100755
> Mar  5 01:43:21 koi kernel: nfs_update_inode: inode 3222473680 mode 
> changed, 0040755 to 0100644
> Mar  5 08:52:19 koi kernel: nfs_update_inode: inode 3222473568 mode 
> changed, 0120777 to 0100644
> Mar  5 15:00:01 koi kernel: nfs_update_inode: inode 3222473569 mode 
> changed, 0120777 to 0100644
> Mar  5 15:00:31 koi kernel: nfs_update_inode: inode 3222473674 mode 
> changed, 0120777 to 0100644
> Mar  5 15:00:31 koi kernel: nfs_update_inode: inode 3222473675 mode 
> changed, 0120777 to 0100644
> Mar  5 15:00:31 koi kernel: nfs_update_inode: inode 3222473672 mode 
> changed, 0040755 to 0100644
> Mar  5 15:00:31 koi kernel: nfs_update_inode: inode 3222473673 mode 
> changed, 0120777 to 0100644
> 
> 
Hmmm...
Directories and symlinks "changing" to regular files.

32bit inode numbers with the high bit set.

Random times, but a burst at 3pm one afternoon.

The fact that it happens so rarely make is very hard to collect more
data....


What happens when a user experiences an error?  What sort of file is
the error reported against?  Does the file remain inaccessible or does
it start working again soon?  Is the same file accessible from another
client?

NeilBrown
