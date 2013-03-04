Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:58893 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757643Ab3CDOXQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Mar 2013 09:23:16 -0500
Date: Mon, 4 Mar 2013 09:23:10 -0500
From: Jeff Layton <jlayton@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Ming Lei <ming.lei@canonical.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Mandeep Singh Baines <msb@chromium.org>
Subject: Re: LOCKDEP: 3.9-rc1: mount.nfs/4272 still has locks held!
Message-ID: <20130304092310.1d21100c@tlielax.poochiereds.net>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9286AD113@sacexcmbx05-prd.hq.netapp.com>
References: <CACVXFVMKN6aeCvJcn7dyuonJYJDfYxWeW5KE6gfKRKJKFj2M4A@mail.gmail.com>
	<4FA345DA4F4AE44899BD2B03EEEC2FA9286AD113@sacexcmbx05-prd.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 4 Mar 2013 14:14:23 +0000
"Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Mon, 2013-03-04 at 21:57 +0800, Ming Lei wrote:
> > Hi,
> > 
> > The below warning can be triggered each time when mount.nfs is
> > running on 3.9-rc1.
> > 
> > Not sure if freezable_schedule() inside rpc_wait_bit_killable should
> > be changed to schedule() since nfs_clid_init_mutex is held in the path.
> 
> Cc:ing Jeff, who added freezable_schedule(), and applied it to
> rpc_wait_bit_killable.
> 
> So this is occurring when the kernel enters the freeze state?
> Why does it occur only with nfs_clid_init_mutex, and not with all the
> other mutexes that we hold across RPC calls? We hold inode->i_mutex
> across RPC calls all the time when doing renames, unlinks, file
> creation,...
> 

cc'ing Mandeep as well since his patch caused this to start popping up...

We've also gotten some similar lockdep pops in the nfsd code recently.
I responded to an email about it here on Friday, and I'll re-post what
I said there below:

-------------------------[snip]----------------------
Ok, I see...

rpc_wait_bit_killable() calls freezable_schedule(). That calls
freezer_count() which calls try_to_freeze(). try_to_freeze does this
lockdep check now as of commit 6aa9707099.

The assumption seems to be that freezing a thread while holding any
sort of lock is bad. The rationale in that patch seems a bit sketchy to
me though. We can be fairly certain that we're not going to deadlock by
holding these locks, but I guess there could be something I've missed.

Mandeep, can you elaborate on whether there's really a deadlock
scenario here? If not, then is there some way to annotate these locks
so this lockdep pop goes away?
-------------------------[snip]----------------------


> > [   41.387939] =====================================
> > [   41.392913] [ BUG: mount.nfs/643 still has locks held! ]
> > [   41.398559] 3.9.0-rc1+ #1740 Not tainted
> > [   41.402709] -------------------------------------
> > [   41.407714] 1 lock held by mount.nfs/643:
> > [   41.411956]  #0:  (nfs_clid_init_mutex){+.+...}, at: [<c0226d6c>]
> > nfs4_discover_server_trunking+0x60/0x1d4
> > [   41.422363]
> > [   41.422363] stack backtrace:
> > [   41.427032] [<c0014dd4>] (unwind_backtrace+0x0/0xe0) from
> > [<c04a8300>] (rpc_wait_bit_killable+0x38/0xc8)
> > [   41.437103] [<c04a8300>] (rpc_wait_bit_killable+0x38/0xc8) from
> > [<c054e454>] (__wait_on_bit+0x54/0x9c)
> > [   41.446990] [<c054e454>] (__wait_on_bit+0x54/0x9c) from
> > [<c054e514>] (out_of_line_wait_on_bit+0x78/0x84)
> > [   41.457061] [<c054e514>] (out_of_line_wait_on_bit+0x78/0x84) from
> > [<c04a8f88>] (__rpc_execute+0x170/0x348)
> > [   41.467407] [<c04a8f88>] (__rpc_execute+0x170/0x348) from
> > [<c04a250c>] (rpc_run_task+0x9c/0xa4)
> > [   41.476715] [<c04a250c>] (rpc_run_task+0x9c/0xa4) from [<c04a265c>]
> > (rpc_call_sync+0x70/0xb0)
> > [   41.485778] [<c04a265c>] (rpc_call_sync+0x70/0xb0) from
> > [<c021af54>] (nfs4_proc_setclientid+0x1a0/0x1c8)
> > [   41.495819] [<c021af54>] (nfs4_proc_setclientid+0x1a0/0x1c8) from
> > [<c0224eb4>] (nfs40_discover_server_trunki
> > ng+0xec/0x148)
> > [   41.507507] [<c0224eb4>]
> > (nfs40_discover_server_trunking+0xec/0x148) from [<c0226da0>]
> > (nfs4_discover_server
> > _trunking+0x94/0x1d4)
> > [   41.519866] [<c0226da0>] (nfs4_discover_server_trunking+0x94/0x1d4)
> > from [<c022c664>] (nfs4_init_client+0x15
> > 0/0x1b0)
> > [   41.531036] [<c022c664>] (nfs4_init_client+0x150/0x1b0) from
> > [<c01fe954>] (nfs_get_client+0x2cc/0x320)
> > [   41.540863] [<c01fe954>] (nfs_get_client+0x2cc/0x320) from
> > [<c022c080>] (nfs4_set_client+0x80/0xb0)
> > [   41.550476] [<c022c080>] (nfs4_set_client+0x80/0xb0) from
> > [<c022cef8>] (nfs4_create_server+0xb0/0x21c)
> > [   41.560333] [<c022cef8>] (nfs4_create_server+0xb0/0x21c) from
> > [<c0227524>] (nfs4_remote_mount+0x28/0x54)
> > [   41.570373] [<c0227524>] (nfs4_remote_mount+0x28/0x54) from
> > [<c0113a8c>] (mount_fs+0x6c/0x160)
> > [   41.579498] [<c0113a8c>] (mount_fs+0x6c/0x160) from [<c012a47c>]
> > (vfs_kern_mount+0x4c/0xc0)
> > [   41.588378] [<c012a47c>] (vfs_kern_mount+0x4c/0xc0) from
> > [<c022734c>] (nfs_do_root_mount+0x74/0x90)
> > [   41.597961] [<c022734c>] (nfs_do_root_mount+0x74/0x90) from
> > [<c0227574>] (nfs4_try_mount+0x24/0x3c)
> > [   41.607513] [<c0227574>] (nfs4_try_mount+0x24/0x3c) from
> > [<c02070f8>] (nfs_fs_mount+0x6dc/0x7a0)
> > [   41.616821] [<c02070f8>] (nfs_fs_mount+0x6dc/0x7a0) from
> > [<c0113a8c>] (mount_fs+0x6c/0x160)
> > [   41.625701] [<c0113a8c>] (mount_fs+0x6c/0x160) from [<c012a47c>]
> > (vfs_kern_mount+0x4c/0xc0)
> > [   41.634582] [<c012a47c>] (vfs_kern_mount+0x4c/0xc0) from
> > [<c012c330>] (do_mount+0x710/0x81c)
> > [   41.643524] [<c012c330>] (do_mount+0x710/0x81c) from [<c012c4c0>]
> > (sys_mount+0x84/0xb8)
> > [   41.652008] [<c012c4c0>] (sys_mount+0x84/0xb8) from [<c000d6c0>]
> > (ret_fast_syscall+0x0/0x48)
> > [   41.715911] device: '0:28': device_add
> > [   41.720062] PM: Adding info for No Bus:0:28
> > [   41.746887] device: '0:29': device_add
> > [   41.751037] PM: Adding info for No Bus:0:29
> > [   41.780700] device: '0:28': device_unregister
> > [   41.785400] PM: Removing info for No Bus:0:28
> > [   41.790344] device: '0:28': device_create_release
> > 
> > 
> > Thanks,
> > --
> > Ming Lei
> 


-- 
Jeff Layton <jlayton@redhat.com>
