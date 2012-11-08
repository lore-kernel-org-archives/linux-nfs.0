Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.struction.de ([85.214.237.111]:32859 "EHLO
	rasta.struction.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753222Ab2KHUU5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Nov 2012 15:20:57 -0500
Message-ID: <509C1419.2030802@struction.de>
Date: Thu, 08 Nov 2012 21:20:41 +0100
From: pille <pille+kernel.org+mailinglist+linux-nfs@struction.de>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org, 1071733@bugs.launchpad.net
Subject: Re: NFS export of LVM snapshot exports origin instead of snapshot
References: <509BDA31.3090904@struction.de> <20121108195025.GA5042@fieldses.org>
In-Reply-To: <20121108195025.GA5042@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/08/2012 08:50 PM, J. Bruce Fields wrote:

> The protocol references files on the filesystem using filehandles.  The
> linux NFS server generates a filehandle that has a part which identifies
> the filesystem and a part which identifies the particular file (usually
> an inode and generation number).

sounds comprehensible.

> The filesystem part in your case is probably a uuid which is part of
> what's copied when you snapshot (as are all the inode numbers).  So
> you're left with filehandles that are the same for the two filesystems.

i can confirm that both filesystems by design have the same UUID.

> You can tell it to instead to use whatever integer you'd like using the
> "fsid=" export option (just don't used fsid=0, which has a special
> meaning).

tried that already (using 2 and 6) and it did not work.

> Or, probably better--you should be able to be able to modify the uuid...
> Looking at the tune2fs man page, I think it should be:
> 
> 	tune2fs -U random /dev/vg0/nfssnapshot

we're using xfs in production, but it has some similar tool. i'll look
into it tomorrow, because it doesn't works out that quick.

my problem with this issue is that we're running this setup for over two
years now and the NFS server wasn't rebooted since half a year and the
bug just showed recently. while we didn't had safety-checks in place to
be sure what we mounted, we regularly simulated file-operations on a
snapshot which never affected the origin volume.

  pille
