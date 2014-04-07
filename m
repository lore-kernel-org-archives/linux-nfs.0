Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:41781 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755187AbaDGU1w (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Apr 2014 16:27:52 -0400
Date: Mon, 7 Apr 2014 22:27:50 +0200
From: Jan Kara <jack@suse.cz>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Brown Neil <neilb@suse.de>, Jan Kara <jack@suse.cz>,
        Viro Alexander <viro@zeniv.linux.org.uk>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: NFS deadlock between 'sync' and commit after unmount....
Message-ID: <20140407202750.GE23670@quack.suse.cz>
References: <20140407135001.56ef9f36@notabene.brown>
 <F59673DE-8047-4FE0-AFF9-6A3DC37348A5@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <F59673DE-8047-4FE0-AFF9-6A3DC37348A5@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

  Hello,

On Mon 07-04-14 10:10:27, Trond Myklebust wrote:
> On Apr 6, 2014, at 23:50, NeilBrown <neilb@suse.de> wrote:
> > I've just hit a deadlock in NFS that seems very strange.
> > The kernel is 3.14-rc8 which some local changes which shouldn't affect the
> > deadlocking code.
> > 
> > Shortly after umounting the NFS filesystem with "umount -f" (though I don't
> > think the -f is important), I ran "sync".
> > 
> > The sync is now stuck in
> > 
> > [<ffffffff81197fc1>] sync_inodes_sb+0xa1/0x1c0
> > [<ffffffff8119cd99>] sync_inodes_one_sb+0x19/0x20
> > [<ffffffff81173372>] iterate_supers+0xb2/0x110
> > [<ffffffff8119cfd0>] sys_sync+0x30/0x90
> > [<ffffffff81aa4622>] system_call_fastpath+0x16/0x1b
> > [<ffffffffffffffff>] 0xffffffffffffffff
> > 
> > while kworker/u16:1 is stuck:
> > 
> > [<ffffffff815420b3>] call_rwsem_down_write_failed+0x13/0x20
> > [<ffffffff81172889>] deactivate_super+0x39/0x60
> > [<ffffffff812d56f1>] nfs_sb_deactive+0x21/0x30
> > [<ffffffff812d2ef9>] __put_nfs_open_context+0xc9/0x100
> > [<ffffffff812d2f3b>] put_nfs_open_context+0xb/0x10
> > [<ffffffff812ddd14>] nfs_commitdata_release+0x14/0x30
> > [<ffffffff812ddd4a>] nfs_commit_release+0x1a/0x20
> > [<ffffffff81a45a05>] rpc_free_task+0x25/0x70
> > [<ffffffff81a45fd8>] rpc_do_put_task+0x78/0x80
> > [<ffffffff81a45feb>] rpc_put_task+0xb/0x10
> > [<ffffffff812de3fe>] nfs_initiate_commit+0xce/0x110
> > [<ffffffff812df112>] nfs_commit_list+0x62/0x90
> > [<ffffffff812dfd26>] nfs_commit_inode+0xa6/0x170
> > [<ffffffff812dfe4d>] nfs_write_inode+0x5d/0xa0
> > [<ffffffff81300d69>] nfs4_write_inode+0x9/0x10
> > [<ffffffff811978ec>] __writeback_single_inode+0x10c/0x2c0
> > [<ffffffff811987ea>] writeback_sb_inodes+0x2ca/0x450
> > [<ffffffff81198b2c>] wb_writeback+0xec/0x320
> > [<ffffffff81199365>] bdi_writeback_workfn+0x115/0x4c0
> > [<ffffffff810a595b>] process_one_work+0x16b/0x430
> > [<ffffffff810a6619>] worker_thread+0x119/0x3a0
> > [<ffffffff810ac2bd>] kthread+0xcd/0xf0
> > [<ffffffff81aa457c>] ret_from_fork+0x7c/0xb0
> > [<ffffffffffffffff>] 0xffffffffffffffff
> > 
> > 
> > So sync is holding sb->s_umount, queued some bdi work on the filesystem
> > and is waiting for it to complete.  Mean while, that work has (I think)
> > submitted a 'commit' (via ->write_inode) and that commit wants to
> > deactivate_super and so needs to get ->s_umount.
> > 
> > I suspect this could happen even more easily with a lazy unmount.
> > 
> > It seems that this commit request is that last thing that is keeping
> > ->s_active elevated and it deadlocks trying to drop the last s_active.
> > 
> > I have no idea how to fix it....  help?
> > 
> 
> The problem seems to be the use of iterate_supers(), which grabs a
> passive reference, and conflicts with our use of an active reference in
> the open context.
  Yeah, we cannot really do otherwise in iterate_supers() - we have to grab
some superblock reference and we don't really want to get an active one
since that would result in spurious EBUSY returns from umount.

Cannot we just punt the deactivate_super() call to a workqueue to avoid
this deadlock? It's a bit ugly but it should do the trick. Or is
nfs_sb_deactive() called too often and we'd see some adverse effects for
that? We could also offload it to workqueue only in the special case where
sb->s_active == 1. That should be really rare then but it's a bit ugly
poking in VFS internals. BTW why is nfs_sb_active() safe doing just
atomic_inc() on s_active? grab_super() is more careful...

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR
