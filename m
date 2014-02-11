Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f177.google.com ([209.85.223.177]:41558 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752199AbaBKETL convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Feb 2014 23:19:11 -0500
Received: by mail-ie0-f177.google.com with SMTP id at1so4224803iec.36
        for <linux-nfs@vger.kernel.org>; Mon, 10 Feb 2014 20:19:11 -0800 (PST)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: "nosharecache" option prevent "mount" from detecting when the mount is a duplicate.
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <20140211133013.1ccf8615@notabene.brown>
Date: Mon, 10 Feb 2014 23:19:09 -0500
Cc: NFS <linux-nfs@vger.kernel.org>
Message-Id: <4A18E8CC-9376-4456-9FD6-E6B36BF8E89D@primarydata.com>
References: <20140211133013.1ccf8615@notabene.brown>
To: Brown Neil <neilb@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 10, 2014, at 21:30, NeilBrown <neilb@suse.de> wrote:

> 
> (I seem to have quite a pile of NFS issues lately.... some if it is tidying up
> issues from before Christmas, some of it just keeps on coming :-)
> 
> If you run "mount -a" it will attempt to mount all filesystems listed
> in /etc/fstab, but filesystems that are already mounted will not be mounted
> again.  So it is normally safe to run "mount -a" multiple times.
> 
> However if an NFS mount in /etc/fstab has the "nosharecache" option set,
> mount doesn't notice that it is already mounted as so mounts it again.  So
> repeated "mount -a" is no longer safe.
> 
> This happens because the prevention of multiple mounts happens in do_add_mount
> in fs/namespace.c:
> 
> 	err = -EBUSY;
> 	if (path->mnt->mnt_sb == newmnt->mnt.mnt_sb &&
> 	    path->mnt->mnt_root == path->dentry)
> 		goto unlock;
> 
> 
> i.e. if the exact same superblock is being mounted in the exact same place,
> return EBUSY.
> With nosharecache, every mount attempt produces a new superblock so this test
> never fires.
> 
> One way to address this would be to have a different option, e.g.
>          sharecache=27
> 
> where the '27' is an arbitrary number meaning that if two mount attempts have
> different sharecache numbers they will have different superblocks.  If they
> have the same sharecache number they can have the same superblock.
> This is not the most elegant interface ever and I would be very happy for
> suggestions to improve it.  Maybe a string rather than a number ???
> 
> This probably isn't a very serious issue, but is a regression in terms of the
> usability of "mount -a" and I think it would be best to fix it if the cost is
> not too high.
> 
> Below is my patch to implement the "sharecache=%u" syntax.
> 
> Any ideas?

What are people using nosharecache for these days, and why is this not another argument for just getting rid of it?

_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

