Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:38703 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757704Ab0EXVNk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 May 2010 17:13:40 -0400
Subject: Re: [PATCH] VFS: fix recent breakage of FS_REVAL_DOT
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Neil Brown <neilb@suse.de>, "Dr. J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
In-Reply-To: <20100524190828.GS31073@ZenIV.linux.org.uk>
References: <20100524165756.2cfa54c4@notabene.brown>
	 <20100524115903.GP31073@ZenIV.linux.org.uk>
	 <20100524155031.GQ31073@ZenIV.linux.org.uk>
	 <1274718082.10795.31.camel@heimdal.trondhjem.org>
	 <20100524164736.GR31073@ZenIV.linux.org.uk>
	 <1274720791.10795.50.camel@heimdal.trondhjem.org>
	 <20100524190828.GS31073@ZenIV.linux.org.uk>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 24 May 2010 17:13:32 -0400
Message-ID: <1274735612.4030.16.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2010-05-24 at 20:08 +0100, Al Viro wrote: 
> On Mon, May 24, 2010 at 01:06:31PM -0400, Trond Myklebust wrote:
> 
> > I believe that the answer is that most filehandle types include an
> > encoding of the inode number of the export directory. In other words, as
> > long as '/a' and '/b' are different directories, then they will result
> > in the generation of different filehandles for /a/x and /b/x.
> > 
> > It seems that is not always the case, though. According to the
> > definition of mk_fsid(), it looks as if the 'FSID_UUID8' and
> > 'FSID_UUID16' filehandle types only encode the uuid of the filesystem,
> > and have no inode information. They will therefore not be able to
> > distinguish between an export through '/a' or '/b'.
> > 
> > Neil, Bruce am I right?
> 
> Er?  On server:
> 
> mount -t ext2 /dev/sdb1 /srv/nfs4
> mount -t ext2 /dev/sda1 /srv/nfs4/a
> mount -t ext2 /dev/sda1 /srv/nfs4/b
> 
> after that /srv/nfs4/a and /srv/nfs4/b will have the *same* inode, nevermind
> the inode number.  I really mean the same filesystem mounted twice; if you
> want to include inumber of mountpoint into fsid, fine, turn the above into
> 
> mount -t ext2 /dev/sdb1 /srv/nfs4
> mount -t ext2 /dev/sda1 /srv/nfs4/a
> mount -t ext2 /dev/sda1 /srv/nfs4/b
> mount -t ext2 /dev/sda3 /srv/nfs4/a/z
> mount -t ext2 /dev/sda3 /srv/nfs4/b/z
> 
> At that point you have the same fs (ext2 from sda3) mounted on /srv/nfs4/a/z
> and /srv/nfs4/b/z, with the same directory inode overmounted by it in both
> mountpoints.  Suppose your referral point is on /a/z/x and /b/z/x resp. and
> see the question upthread...

Sorry... I misunderstood you.

In cases like the above, then the default behaviour of the server would
be to assign the same filehandles to those mount points. The
administrator can, however, make them different by choosing to use the
'fsid' mount option to manually assign different fsids to the different
export points.

If not, then the client will automatically group these things in the
same superblock, so like the server, it too is supposed to share the
same inode for these different objects. It will then use
d_obtain_alias() to get a root dentry for that inode (see
nfs4_get_root()).

Cheers
  Trond

