Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:56108 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933556AbZHDW4V (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Aug 2009 18:56:21 -0400
Date: Wed, 5 Aug 2009 00:56:19 +0200
From: Jan Kara <jack@suse.cz>
To: Sylvain Rochet <gradator@gradator.net>
Cc: Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-nfs@vger.kernel.org,
        Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: 2.6.28.9: EXT3/NFS inodes corruption
Message-ID: <20090804225619.GB11097@duck.suse.cz>
References: <20090420162017.GA28079@gradator.net> <20090716172749.GC3740@atrey.karlin.mff.cuni.cz> <20090725151751.GA6419@gradator.net> <20090727154253.GB8332@duck.suse.cz> <20090728112715.GA8442@gradator.net> <20090728135226.GA21682@duck.suse.cz> <20090728164142.GA13662@gradator.net> <20090803222901.GB23162@duck.suse.cz> <20090804111505.GA6433@gradator.net>
Content-Type: multipart/mixed; boundary="2fHTh5uZTiUOsy+g"
In-Reply-To: <20090804111505.GA6433@gradator.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--2fHTh5uZTiUOsy+g
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

  Hi,

On Tue 04-08-09 13:15:05, Sylvain Rochet wrote:
> On Tue, Aug 04, 2009 at 12:29:01AM +0200, Jan Kara wrote:
> > 
> >   OK, I've found some time and written the debugging patch. Hopefully it
> > will tell us more. It should output messages to the kernel log if it
> > finds something suspicious - like:
> > No dentry for unlinked inode...
> > Dentry ... for unlinked inode ... has no parent
> > Found directory entry ... for unlinked inode
> > 
> >   When you see such messages in the log, send them to me please. Also
> > attach the System.map file so that I can translate the address where
> > i_nlink was dropped - for that ext3 should be compiled into the kernel
> > (should not be a module). Thanks a lot for testing.
> 
> Patch applied.
> 
> And there is already a lot of output.
> 
> http://edony.tuxfamily.org/~grad/bazooka/System.map-2.6.30.4
> http://edony.tuxfamily.org/~grad/bazooka/config-2.6.30.4
> http://edony.tuxfamily.org/~grad/bazooka/kern.log
  Thanks for testing. So you seem to be really stressting the path where
creation of new files / directories fails (probably due to group quota).  I
have one idea what could cause your filesystem corruption, although it's a
wild guess... Please try attached oneliner.
  Also your corruption reminded me that Al Viro has been fixing problems
where we could cache one inode twice when a filesystem was mounted over NFS
and that could also lead to a filesystem corruption. So I'm adding him to
CC just in case he has some idea. BTW Al, what do you think about the
problem I describe in the attached patch? I'm not sure if it can cause some
real problems but in theory it could...

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--2fHTh5uZTiUOsy+g
Content-Type: text/x-patch; charset=us-ascii
Content-Disposition: attachment; filename="0001-fs-Make-sure-data-stored-into-inode-is-properly-see.patch"

>From 78513d3a5628fda0f8d685d732b7bc73bd4c9222 Mon Sep 17 00:00:00 2001
From: Jan Kara <jack@suse.cz>
Date: Wed, 5 Aug 2009 00:42:21 +0200
Subject: [PATCH] fs: Make sure data stored into inode is properly seen before unlocking new inode

In theory it could happen that on one CPU we initialize a new inode but clearing
of I_NEW | I_LOCK gets reordered before some of the initialization. Thus on
another CPU we return not fully uptodate inode from iget_locked().

Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/inode.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/inode.c b/fs/inode.c
index 901bad1..e9a8e77 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -696,6 +696,7 @@ void unlock_new_inode(struct inode *inode)
 	 * just created it (so there can be no old holders
 	 * that haven't tested I_LOCK).
 	 */
+	smp_mb();
 	WARN_ON((inode->i_state & (I_LOCK|I_NEW)) != (I_LOCK|I_NEW));
 	inode->i_state &= ~(I_LOCK|I_NEW);
 	wake_up_inode(inode);
-- 
1.6.0.2


--2fHTh5uZTiUOsy+g--
