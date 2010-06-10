Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:60764 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750838Ab0FJEJR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Jun 2010 00:09:17 -0400
Date: Thu, 10 Jun 2010 14:09:08 +1000
From: Neil Brown <neilb@suse.de>
To: rasca@miamammausalinux.org
Cc: linux-nfs@vger.kernel.org
Subject: Re: Problem using exportfs in an active-active nfs cluster
Message-ID: <20100610140908.3a07596c@notabene.brown>
In-Reply-To: <4C0F6CDB.5050004@miamammausalinux.org>
References: <4C0E6ED0.60200@miamammausalinux.org>
	<20100609075425.7ec4ccd9@notabene.brown>
	<4C0F4634.8090102@miamammausalinux.org>
	<20100609180439.40e856ac@notabene.brown>
	<4C0F6CDB.5050004@miamammausalinux.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 09 Jun 2010 12:28:43 +0200
RaSca <rasca@miamammausalinux.org> wrote:

> Il giorno Mer 09 Giu 2010 10:04:39 CET, Neil Brown ha scritto:
> [...]
> > Seems unlikely ... "exportfs -f" flushes all the export caches in the kernel
> > thus letting go of any filesystems.
> > I guess an active NFS request could still hold the fs active, but that should
> > complete fairly quickly.
> > file locking might be an issue.  Might a client have a lock on some file in
> > the filesystem?  Failover of locks is rather more complicated that simple
> > file-access fail-over.  I don't recall what the status of this is currently.
> > When the umount files, check the content of
> >     /proc/net/rpc/nfsd.export/content
> > and
> >     /proc/locks
> > to check what is actually using the filesystem.
> 
> Note that I'm mounting from the client with nolock option.
> 
> Here is the output of the two cat:
> 
> /proc/net/rpc/nfsd.export/content:
> 
> #path domain(flags)#012# 
> /share-a#011192.168.1.0/24(rw,no_root_squash,sync,wdelay,crossmnt,no_subtree_check,fsid=1,uuid=7c80c4af:2a244b39:af
> adb554:8c8e0574)
> 
> /proc/locks:
> 
> 1: POSIX  ADVISORY  WRITE 753 00:11:3923 0 EOF#0122: FLOCK  ADVISORY 
> WRITE 739 00:11:3916 0 EOF#0123: POSIX  ADVISORY  WRITE 522 00:11:3049
>   0 EOF
> 
> What do you think about it?
>

Clearly there are no locks .. though I wonder what is mounted on 00:11.
Probably not important.

The fact that the export entry is there after you did "exportfs -f" strong
suggests that a new request came in and caused mountd to re-add the entry.

Do you disable the network interface that the clients connect to *before*
unexporting?  If you don't, you should.
Maybe run mountd with "-d all" and see what it is doing when you are
unexporting and unmounting.

NeilBrown
