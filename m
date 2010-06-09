From: Neil Brown <neilb@suse.de>
Subject: Re: Problem using exportfs in an active-active nfs cluster
Date: Wed, 9 Jun 2010 18:04:39 +1000
Message-ID: <20100609180439.40e856ac@notabene.brown>
References: <4C0E6ED0.60200@miamammausalinux.org>
	<20100609075425.7ec4ccd9@notabene.brown>
	<4C0F4634.8090102@miamammausalinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: rasca-9B074fXSGsOr88ip1nKoZ2D2FQJk+8+b@public.gmane.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:53761 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755802Ab0FIIEt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Jun 2010 04:04:49 -0400
In-Reply-To: <4C0F4634.8090102-9B074fXSGsOr88ip1nKoZ2D2FQJk+8+b@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 09 Jun 2010 09:43:48 +0200
RaSca <rasca-9B074fXSGsOr88ip1nKoZ2D2FQJk+8+b@public.gmane.org> wrote:

> Il giorno Mar 08 Giu 2010 23:54:25 CET, Neil Brown ha scritto:
> [...]
> > Try
> >    exportfs -f
> 
> Already tried, it didn't work. The file system is still locked by nfsd.
> 

Seems unlikely ... "exportfs -f" flushes all the export caches in the kernel
thus letting go of any filesystems.
I guess an active NFS request could still hold the fs active, but that should
complete fairly quickly.
file locking might be an issue.  Might a client have a lock on some file in
the filesystem?  Failover of locks is rather more complicated that simple
file-access fail-over.  I don't recall what the status of this is currently.

When the umount files, check the content of
   /proc/net/rpc/nfsd.export/content
and
   /proc/locks

to check what is actually using the filesystem.

NeilBrown
