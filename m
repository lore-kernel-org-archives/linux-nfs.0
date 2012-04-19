Return-Path: linux-nfs-owner@vger.kernel.org
Received: from idcmail-mo1so.shaw.ca ([24.71.223.10]:60401 "EHLO
	idcmail-mo1so.shaw.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753272Ab2DSXdC convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Apr 2012 19:33:02 -0400
Subject: Re: [PATCH 1/6] xstat: Add a pair of system calls to make extended file stats available
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
From: Andreas Dilger <adilger@dilger.ca>
In-Reply-To: <20120419140612.17272.57774.stgit@warthog.procyon.org.uk>
Date: Thu, 19 Apr 2012 17:36:32 -0600
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-ext4@vger.kernel.org, wine-devel@winehq.org, kfm-devel@kde.org,
        nautilus-list@gnome.org, linux-api@vger.kernel.org,
        libc-alpha@sourceware.org
Message-Id: <5D4BF4AB-47E9-4E25-B2A3-F895C98BDAA3@dilger.ca>
References: <20120419140558.17272.74360.stgit@warthog.procyon.org.uk> <20120419140612.17272.57774.stgit@warthog.procyon.org.uk>
To: David Howells <dhowells@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2012-04-19, at 8:06 AM, David Howells wrote:
> Add a pair of system calls to make extended file stats available,
> including file creation time, inode version and data version where available through the underlying filesystem.
> 
> The idea was initially proposed as a set of xattrs that could be
> retrieved with getxattr(), but the general preferance proved to be
> for new syscalls with an extended stat structure.

I would comment that it was the opposite.  It was originally a
stat()-like extension that degraded into a messy getxattr() mess.

> (2) Lightweight stat: Ask for just those details of interest, and
>     allow a netfs (such as NFS) to approximate anything not of
>     interest, possibly without going to the server [Trond Myklebust,
>     Ulrich Drepper].

This was my original motivation for this functionality, so you can
put my name here also.

> The fields in struct xstat come in a number of classes:
> 
> (0) st_dev, st_blksize, st_information.
> 
>     These are local data and are always available.

For the extra two bits it would cost us, I don't think st_blksize
and st_information should always be returned.  st_blksize may be
variable for a distributed filesystem, and some of the fields in
st_information (offline) may not be free to access either.

Cheers, Andreas





