Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:60237 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751153Ab0LQCJJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Dec 2010 21:09:09 -0500
Date: Thu, 16 Dec 2010 21:09:06 -0500
From: Jim Rees <rees@umich.edu>
To: Mike <debian@good-with-numbers.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: nfs-common needed on NFS-rooted client?
Message-ID: <20101217020906.GA8853@merit.edu>
References: <20101216230622.GA23016@adsl-64-142-29-25.sonic.net>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101216230622.GA23016@adsl-64-142-29-25.sonic.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Mike wrote:

  For a client with an NFS root and no other NFS mounts, is it necessary
  to have the utilities found in the Debian nfs-common package
  <http://packages.debian.org/squeeze/nfs-common>?  Seems to be working
  fine without.

The only thing you might need is the mount command, mount.nfs.  This isn't
used by the kernel for the root mount, but might be needed later for a
remount in user space.  There's also the unmount command, but presumably you
won't be using that.  And showmount, which isn't essential.  And the nfs(5)
man page.

The mount command also might be needed to update /etc/mtab if you don't have
it linked to /proc.  Does "mount" return the expected results?

I'm told by an expert that Ubuntu doesn't use the kernel root mount, but
bounces the initial mount up to user space in the initrd.  So you probably
do need nfs-common for Ubuntu.  Apparently Debian hasn't done this if it's
working for you.
