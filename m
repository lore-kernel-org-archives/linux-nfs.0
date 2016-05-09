Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from muru.com ([72.249.23.125]:53710 "EHLO muru.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751145AbcEIPVn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 May 2016 11:21:43 -0400
Date: Mon, 9 May 2016 08:21:38 -0700
From: Tony Lindgren <tony@atomide.com>
To: Eric Dumazet <edumazet@google.com>
Cc: linux-nfs@vger.kernel.org, Jiri Pirko <jiri@resnulli.us>,
        netdev <netdev@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Christoph Hellwig <hch@lst.de>, Al Viro <viro@zeniv.linux.org.uk>,
        linux-omap@vger.kernel.org, Anna Schumaker <anna.schumaker@netapp.com>,
        linux-arm-kernel@lists.infradead.org
Subject: Re: NFSroot hangs with bad unlock balance in Linux next
Message-ID: <20160509152138.GG5995@atomide.com>
References: <20160505220344.GE5995@atomide.com>
 <20160508141629.GF2694@ZenIV.linux.org.uk>
 <20160509073235.GI2694@ZenIV.linux.org.uk>
 <CANn89iK5H-SokYE1r+OO3sPmQ1vpGqYGbE4x1QLn44wdyvH0cw@mail.gmail.com>
 <20160509151219.GF5995@atomide.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160509151219.GF5995@atomide.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

* Tony Lindgren <tony@atomide.com> [160509 08:15]:
> * Eric Dumazet <edumazet@google.com> [160509 07:16]:
> > On Mon, May 9, 2016 at 12:32 AM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> > > On Sun, May 08, 2016 at 03:16:29PM +0100, Al Viro wrote:
> > >
> > >> Very strange.  We grab that rwsem at the entry into nfs_call_unlink()
> > >> and then either release it there and return or call nfs_do_call_unlink().
> > >> Which arranges for eventual call of nfs_async_unlink_release() (via
> > >> ->rpc_release); nfs_async_unlink_release() releases the rwsem.  Nobody else
> > >> releases it (on the read side, that is).
> > >>
> > >> The only kinda-sorta possibility I see here is that the inode we are
> > >> unlocking in that nfs_async_unlink_release() is not the one we'd locked
> > >> in nfs_call_unlink() that has lead to it.  That really shouldn't happen,
> > >> though...  Just to verify whether that's what we are hitting, could you
> > >> try to reproduce that thing with the patch below on top of -next and see
> > >> if it triggers any of those WARN_ON?
> 
> Thanks no warnings with that patch though.
> 
> > > D'oh...  Lockdep warnings are easy to trigger (and, AFAICS, bogus).
> > > up_read/down_read in fs/nfs/unlink.c should be replaced with
> > > up_read_non_owner/down_read_non_owner, lest the lockdep gets confused.
> > > Hangs are different - I've no idea what's triggering those.  I've seen
> > > something similar on that -next, but not on work.lookups.
> > >
> > > The joy of bisecting -next...  <a couple of hours later>
> > > 9317bb69824ec8d078b0b786b6971aedb0af3d4f is the first bad commit
> > > commit 9317bb69824ec8d078b0b786b6971aedb0af3d4f
> > > Author: Eric Dumazet <edumazet@google.com>
> > > Date:   Mon Apr 25 10:39:32 2016 -0700
> > >
> > >     net: SOCKWQ_ASYNC_NOSPACE optimizations
> > >
> > > Reverting changes to sk_set_bit/sk_clear_bit gets rid of the hangs.  Plain
> > > revert gives a conflict, since there had been additional change in
> > > "net: SOCKWQ_ASYNC_WAITDATA optimizations"; removing both fixed the hangs.
> > >
> > > Note that hangs appear without any fs/nfs/unlink.c modifications being
> > > there.  When the hang happens it affects NFS traffic; ssh session still
> > > works fine until it steps on a filesystem operation on NFS (i.e. you
> > > can use builtins, access procfs, etc.)
> > 
> > Yeah, the issue was reported last week (
> > http://www.spinics.net/lists/netdev/msg375777.html ),
> > and I could not convince myself to add a new sock flag,  like
> > SOCK_FASYNC_STICKY.
> > 
> > (Just in case NFS would ever call sock_fasync() with an empty
> > fasync_list, and SOCK_FASYNC would be cleared again.
> 
> Yeah applying the test patch from the url above makes things work
> for me again.

Looks like with both patches applied I still also get this eventually:

=====================================
[ BUG: bad unlock balance detected! ]
4.6.0-rc7-next-20160509+ #1264 Not tainted
-------------------------------------
kworker/0:1/18 is trying to release lock (&nfsi->rmdir_sem) at:
[<c03a894c>] nfs_async_unlink_release+0x3c/0xc0
but there are no more locks to release!

               other info that might help us debug this:
2 locks held by kworker/0:1/18:
 #0:  ("nfsiod"){.+.+..}, at: [<c015473c>] process_one_work+0x120/0x6bc
 #1:  ((&task->u.tk_work)#2){+.+...}, at: [<c015473c>] process_one_work+0x120/0x6bc

               stack backtrace:
CPU: 0 PID: 18 Comm: kworker/0:1 Not tainted 4.6.0-rc7-next-20160509+ #1264
Hardware name: Generic OMAP5 (Flattened Device Tree)
Workqueue: nfsiod rpc_async_release
[<c0110318>] (unwind_backtrace) from [<c010c3bc>] (show_stack+0x10/0x14)
[<c010c3bc>] (show_stack) from [<c0481da8>] (dump_stack+0xb0/0xe4)
[<c0481da8>] (dump_stack) from [<c018d090>] (print_unlock_imbalance_bug+0xb0/0xe0)
[<c018d090>] (print_unlock_imbalance_bug) from [<c0190e9c>] (lock_release+0x2ec/0x4c0)
[<c0190e9c>] (lock_release) from [<c018a4b8>] (up_read+0x18/0x58)
[<c018a4b8>] (up_read) from [<c03a894c>] (nfs_async_unlink_release+0x3c/0xc0)
[<c03a894c>] (nfs_async_unlink_release) from [<c07860e0>] (rpc_free_task+0x24/0x44)
[<c07860e0>] (rpc_free_task) from [<c0154804>] (process_one_work+0x1e8/0x6bc)
[<c0154804>] (process_one_work) from [<c0154e1c>] (worker_thread+0x144/0x4e8)
[<c0154e1c>] (worker_thread) from [<c015acd4>] (kthread+0xdc/0xf8)
[<c015acd4>] (kthread) from [<c01078f0>] (ret_from_fork+0x14/0x24)

After the warning, NFSroot keeps working with Eric's patch.

Regards,

Tony
