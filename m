Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:38618 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754654AbaDGDuK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 6 Apr 2014 23:50:10 -0400
Date: Mon, 7 Apr 2014 13:50:01 +1000
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: NFS deadlock between 'sync' and commit after unmount....
Message-ID: <20140407135001.56ef9f36@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/a4Xs=GUrGuqp+iW.GrOofET"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/a4Xs=GUrGuqp+iW.GrOofET
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


Hi,
 I've just hit a deadlock in NFS that seems very strange.
The kernel is 3.14-rc8 which some local changes which shouldn't affect the
deadlocking code.

Shortly after umounting the NFS filesystem with "umount -f" (though I don't
think the -f is important), I ran "sync".

The sync is now stuck in

[<ffffffff81197fc1>] sync_inodes_sb+0xa1/0x1c0
[<ffffffff8119cd99>] sync_inodes_one_sb+0x19/0x20
[<ffffffff81173372>] iterate_supers+0xb2/0x110
[<ffffffff8119cfd0>] sys_sync+0x30/0x90
[<ffffffff81aa4622>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff


while kworker/u16:1 is stuck:

[<ffffffff815420b3>] call_rwsem_down_write_failed+0x13/0x20
[<ffffffff81172889>] deactivate_super+0x39/0x60
[<ffffffff812d56f1>] nfs_sb_deactive+0x21/0x30
[<ffffffff812d2ef9>] __put_nfs_open_context+0xc9/0x100
[<ffffffff812d2f3b>] put_nfs_open_context+0xb/0x10
[<ffffffff812ddd14>] nfs_commitdata_release+0x14/0x30
[<ffffffff812ddd4a>] nfs_commit_release+0x1a/0x20
[<ffffffff81a45a05>] rpc_free_task+0x25/0x70
[<ffffffff81a45fd8>] rpc_do_put_task+0x78/0x80
[<ffffffff81a45feb>] rpc_put_task+0xb/0x10
[<ffffffff812de3fe>] nfs_initiate_commit+0xce/0x110
[<ffffffff812df112>] nfs_commit_list+0x62/0x90
[<ffffffff812dfd26>] nfs_commit_inode+0xa6/0x170
[<ffffffff812dfe4d>] nfs_write_inode+0x5d/0xa0
[<ffffffff81300d69>] nfs4_write_inode+0x9/0x10
[<ffffffff811978ec>] __writeback_single_inode+0x10c/0x2c0
[<ffffffff811987ea>] writeback_sb_inodes+0x2ca/0x450
[<ffffffff81198b2c>] wb_writeback+0xec/0x320
[<ffffffff81199365>] bdi_writeback_workfn+0x115/0x4c0
[<ffffffff810a595b>] process_one_work+0x16b/0x430
[<ffffffff810a6619>] worker_thread+0x119/0x3a0
[<ffffffff810ac2bd>] kthread+0xcd/0xf0
[<ffffffff81aa457c>] ret_from_fork+0x7c/0xb0
[<ffffffffffffffff>] 0xffffffffffffffff


So sync is holding sb->s_umount, queued some bdi work on the filesystem and
is waiting for it to complete.
Mean while, that work has (I think) submitted a 'commit' (via ->write_inode)
and that commit wants to deactivate_super and so needs to get ->s_umount.

I suspect this could happen even more easily with a lazy unmount.

It seems that this commit request is that last thing that is keeping
->s_active elevated and it deadlocks trying to drop the last s_active.

I have no idea how to fix it....  help?

NeilBrown

--Sig_/a4Xs=GUrGuqp+iW.GrOofET
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU0IgaTnsnt1WYoG5AQLh5Q/+KvsVEqP0Iby3IusZ1blAI0t2rip9D3ma
g1TNNuIABOk4KXPghFYunnmb/2cxX9W311fB9WWebpEwVqxnCpZe6NISjR4XtU43
VE78ImrmgCdX0Vp0gpWjQgeRjj95AE7XwKTD3mKeliT7aL64WicYQ7HgbC8yToNO
5vuEeARo48tNEK3ihZyu880yGZfmRYDGZKZ/Fj634Fs3rJgXHMRY5gJZ7ZlHgy65
erOPvPSvzU06kNiWP75bmsXIxwNhr931la1XnqcQWEBuSHWnVqs4kXJ+kYP7sco5
TJS+1YZVWXroR3/90cSYOSTkVCa7DDpgdigKgCYibU4ynPvRCcqVr7YK8X6+obhV
mTHKmZjjav3M5NZ6wKQs1uAOg0AmCu5+GEYNC82mj3x3bKMmi72uWYRuB1sdBD3t
FzI9YRIbPRqheSCw5NpD6quuqqAlPUXQkZ1oOBPtYxieQ9wCUXrcNzH3oOZW9Tnz
PKiTPVFrDyzBlt7KCnzwL7GnJHacHPSg+4yZclYSIUYdr60mbLf5eOEiw0DRtpcT
Odo3NjvztHiq+0YHdbvZABdGpSdd/D5pwQxe9HHrt8Xh3RnoiNNjhqibuvpvHViR
FhPp0sYQhhsi6m0BxHohyriXeCAuYYCpGCQEjtZj8v2q/Lh5UXcHJNn/maOUH4fG
8xh+vxSHID0=
=96LC
-----END PGP SIGNATURE-----

--Sig_/a4Xs=GUrGuqp+iW.GrOofET--
