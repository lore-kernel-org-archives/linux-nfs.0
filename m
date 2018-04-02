Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:49974 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752150AbeDBGom (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Apr 2018 02:44:42 -0400
Date: Mon, 2 Apr 2018 07:44:37 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: syzbot <syzbot+f3bd89a5ab3266b10540@syzkaller.appspotmail.com>,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        syzkaller-bugs@googlegroups.com, linux-nfs@vger.kernel.org
Subject: Re: BUG: corrupted list in __dentry_kill
Message-ID: <20180402064437.GB30522@ZenIV.linux.org.uk>
References: <001a11447acaa9eec40568bd5438@google.com>
 <20180401033519.GZ30522@ZenIV.linux.org.uk>
 <20180401200531.GA30522@ZenIV.linux.org.uk>
 <20180401210508.GA743@sol.localdomain>
 <20180401214854.GB743@sol.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180401214854.GB743@sol.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Apr 01, 2018 at 02:48:54PM -0700, Eric Biggers wrote:
> [+Cc linux-nfs]
> > 
> > [   42.965515] net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry blocklayout
> > [   42.967234] net/sunrpc/rpc_pipe.c: rpc_mkpipe_dentry() failed to create pipe nfs/blocklayout (errno = -12)

	AFAICS, there's nothing to zero nn->bl_device_pipe->dentry after
nfs4blocklayout_unregister_sb(), is there?  If nothing else, what's
going to happen after mount/umount/mount with failing
nfs4blocklayout_register_sb()?  AFAICS, we'll have stale pointer to
dentry sitting in nn->bl_device_pipe->dentry, and call rpc_unlink()
on it while cleaning up after the failing mount.

	I don't think that's all there is to it, but it does smell like
a bug.
