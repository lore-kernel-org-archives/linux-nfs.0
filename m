Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.135]:64929 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751268AbcEDNqg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 May 2016 09:46:36 -0400
From: Arnd Bergmann <arnd@arndb.de>
To: David Howells <dhowells@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-afs@vger.kernel.org,
        linux-nfs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, linux-ext4@vger.kernel.org,
        deepa.kernel@gmail.com
Subject: Re: [RFC][PATCH 0/6] Enhanced file stat system call
Date: Wed, 04 May 2016 15:46:27 +0200
Message-ID: <5680195.kS2oylQXhI@wuerfel>
In-Reply-To: <20160429125736.23636.47874.stgit@warthog.procyon.org.uk>
References: <20160429125736.23636.47874.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Friday 29 April 2016 13:57:36 David Howells wrote:
>                          struct statx *buffer);
> 
> This is an enhanced file stat function that provides a number of useful
> features, in summary:
> 
>  (1) More information: creation time, data version number, inode generation
>      number and flags.  A subset of these is available through a number of
>      filesystems (such as CIFS, NFS, AFS, Ext4 and BTRFS).
> 

I have a question about birthtime/creationtime: As we are gaining a way
to read this, should we also provide a way to update it using a new variant
of the utimensat syscall in order to have 'cp -a' create an identical copy,
or is the idea that this is defined as the time that is particular copy
of the inode was created?

I've discussed this with Deepa in the past, as she is driving the
convertion of the inode timestamps to timespec64 now, and we will
need a new version of utimensat for her work as well. I can see good
reasons either way (allowing updates of btime or disallowing them).

This should not hold up the statx syscall from getting merged as
soon as we can, but I'd like to know what everyone feels about that
question now that they are looking at the interface already.

	Arnd
