Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zeniv.linux.org.uk ([195.92.253.2]:38115 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752753Ab3ILTda (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Sep 2013 15:33:30 -0400
Date: Thu, 12 Sep 2013 20:33:28 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        sandeen@redhat.com
Subject: Re: why is i_ino unsigned long, anyway?
Message-ID: <20130912193328.GP13318@ZenIV.linux.org.uk>
References: <20130912160324.GE1462@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130912160324.GE1462@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 12, 2013 at 12:03:24PM -0400, J. Bruce Fields wrote:
> Somebody noticed an "ls -l" over nfs failing on entries with inode
> numbers greater than 2^32 on a 32-bit NFS server.  The cause is some
> code that tries to compare i_ino to the full 64-bit inode number.
> 
> I think the following will fix it, but I'm curious: why is i_ino
> "unsigned long", anyway?  Is there something know that depends on that,
> or is it just that the sheer number of users makes it too scary to
> change?

i_ino use is entirely up to filesystem; it may be used by library helpers,
provided that the choice of using or not using those is, again, up to
filesystem in question.  NFSD has no damn business looking at it; library
helpers in fs/exportfs might, but that makes them not suitable for use
by filesystems without inode numbers or with 64bit ones.

The reason why it's there at all is that it serves as convenient icache
search key for many filesystems.  IOW, it's used by iget_locked() and
avoiding the overhead of 64bit comparisons on 32bit hosts is the main
reason to avoid making it u64.

Again, no fs-independent code has any business looking at it, 64bit or
not.  From the VFS point of view there is no such thing as inode number.
And get_name() is just a library helper.  For many fs types it works
as suitable ->s_export_op->get_name() instance, but decision to use it
or not belongs to filesystem in question and frankly, it's probably better
to provide an instance of your own anyway.
