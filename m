Return-Path: <jeff.layton@primarydata.com>
Date: Fri, 1 May 2015 19:17:41 -0400
From: Jeff Layton <jeff.layton@primarydata.com>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: Shawn Bohrer <shawn.bohrer@gmail.com>, linux-nfs@vger.kernel.org,
        linux-pm@vger.kernel.org, linux-kernel@vger.kernel.org,
        mayoff@rgmadvisors.com, fsorenso@redhat.com, tj@kernel.org
Subject: Re: NFS Freezer and stuck tasks
Message-ID: <20150501191741.17bed93c@tlielax.poochiereds.net>
In-Reply-To: <alpine.OSX.2.19.9992.1505011708000.656@planck.local>
References: <20150304220027.GB20242@sbohrermbp13-local.rgmadvisors.com>
	<alpine.OSX.2.19.9992.1505011631390.946@planck.local>
	<alpine.OSX.2.19.9992.1505011708000.656@planck.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 1 May 2015 17:10:34 -0400 (EDT)
Benjamin Coddington <bcodding@redhat.com> wrote:

> On Fri, 1 May 2015, Benjamin Coddington wrote:
> 
> > On Wed, 4 Mar 2015, Shawn Bohrer wrote:
> >
> > > Hello,
> > >
> > > We're using the Linux cgroup Freezer on some machines that use NFS and
> > > have run into what appears to be a bug where frozen tasks are blocking
> > > running tasks and preventing them from completing.  On one of our
> > > machines which happens to be running an older 3.10.46 kernel we have
> > > frozen some of the tasks on the system using the cgroup Freezer.  We
> > > also have a separate set of tasks which are NOT frozen which are stuck
> > > trying to open some files on NFS.
> > >
> > > Looking at the frozen tasks there are several that have the following
> > > stack:
> > >
> > > [<ffffffff814fd055>] rpc_wait_bit_killable+0x35/0x80
> > > [<ffffffff814fd01d>] __rpc_wait_for_completion_task+0x2d/0x30
> > > [<ffffffff811dce5d>] nfs4_run_open_task+0x11d/0x170
> > > [<ffffffff811de7a3>] _nfs4_open_and_get_state+0x53/0x260
> > > [<ffffffff811e12d1>] nfs4_do_open+0x121/0x400
> > > [<ffffffff811e15e1>] nfs4_atomic_open+0x31/0x50
> > > [<ffffffff811f02dc>] nfs4_file_open+0xac/0x180
> > > [<ffffffff811479be>] do_dentry_open.isra.19+0x1ee/0x280
> > > [<ffffffff81147b3e>] finish_open+0x1e/0x30
> > > [<ffffffff811578d2>] do_last.isra.64+0x2c2/0xc40
> > > [<ffffffff81158519>] path_openat.isra.65+0x2c9/0x490
> > > [<ffffffff81158c38>] do_filp_open+0x38/0x80
> > > [<ffffffff81148cd4>] do_sys_open+0xe4/0x1c0
> > > [<ffffffff81148dce>] SyS_open+0x1e/0x20
> > > [<ffffffff8153e719>] system_call_fastpath+0x16/0x1b
> > > [<ffffffffffffffff>] 0xffffffffffffffff
> > >
> > > Here it looks like we are waiting in a wait queue inside
> > > rpc_wait_bit_killable() for RPC_TASK_ACTIVE.
> > >
> > > And there is a single task with a stack that looks like the following:
> > >
> > > [<ffffffff8107dc05>] __refrigerator+0x55/0x150
> > > [<ffffffff814fd086>] rpc_wait_bit_killable+0x66/0x80
> > > [<ffffffff814fd01d>] __rpc_wait_for_completion_task+0x2d/0x30
> > > [<ffffffff811dce5d>] nfs4_run_open_task+0x11d/0x170
> > > [<ffffffff811de7a3>] _nfs4_open_and_get_state+0x53/0x260
> > > [<ffffffff811e12d1>] nfs4_do_open+0x121/0x400
> > > [<ffffffff811e15e1>] nfs4_atomic_open+0x31/0x50
> > > [<ffffffff811f02dc>] nfs4_file_open+0xac/0x180
> > > [<ffffffff811479be>] do_dentry_open.isra.19+0x1ee/0x280
> > > [<ffffffff81147b3e>] finish_open+0x1e/0x30
> > > [<ffffffff811578d2>] do_last.isra.64+0x2c2/0xc40
> > > [<ffffffff81158519>] path_openat.isra.65+0x2c9/0x490
> > > [<ffffffff81158c38>] do_filp_open+0x38/0x80
> > > [<ffffffff81148cd4>] do_sys_open+0xe4/0x1c0
> > > [<ffffffff81148dce>] SyS_open+0x1e/0x20
> > > [<ffffffff8153e719>] system_call_fastpath+0x16/0x1b
> > > [<ffffffffffffffff>] 0xffffffffffffffff
> > >
> > > This looks similar but the different offset into
> > > rpc_wait_bit_killable() shows that we have returned from the
> > > schedule() call in freezable_schedule() and are now blocked in
> > > __refrigerator() inside freezer_count()
> > >
> > > Similarly if you look at the tasks that are NOT frozen but are stuck
> > > opening a NFS file, they also have the following stack showing they are
> > > waiting in the wait queue for RPC_TASK_ACTIVE.
> > >
> > > [<ffffffff814fd055>] rpc_wait_bit_killable+0x35/0x80
> > > [<ffffffff814fd01d>] __rpc_wait_for_completion_task+0x2d/0x30
> > > [<ffffffff811dce5d>] nfs4_run_open_task+0x11d/0x170
> > > [<ffffffff811de7a3>] _nfs4_open_and_get_state+0x53/0x260
> > > [<ffffffff811e12d1>] nfs4_do_open+0x121/0x400
> > > [<ffffffff811e15e1>] nfs4_atomic_open+0x31/0x50
> > > [<ffffffff811f02dc>] nfs4_file_open+0xac/0x180
> > > [<ffffffff811479be>] do_dentry_open.isra.19+0x1ee/0x280
> > > [<ffffffff81147b3e>] finish_open+0x1e/0x30
> > > [<ffffffff811578d2>] do_last.isra.64+0x2c2/0xc40
> > > [<ffffffff81158519>] path_openat.isra.65+0x2c9/0x490
> > > [<ffffffff81158c38>] do_filp_open+0x38/0x80
> > > [<ffffffff81148cd4>] do_sys_open+0xe4/0x1c0
> > > [<ffffffff81148dce>] SyS_open+0x1e/0x20
> > > [<ffffffff8153e719>] system_call_fastpath+0x16/0x1b
> > > [<ffffffffffffffff>] 0xffffffffffffffff
> > >
> > > We have hit this a couple of times now and know that if we THAW all of
> > > the frozen tasks that running tasks will unwedge and finish.
> > >
> > > Additionally we have also tried thawing the single task that is frozen
> > > in __refrigerator() inside rpc_wait_bit_killable().  This usually
> > > results in different frozen task entering the __refrigerator() state
> > > inside rpc_wait_bit_killable().  It looks like each one of those tasks
> > > must wake up another letting it progress.  Again if you thaw enough of
> > > the frozen tasks eventually everything unwedges and everything
> > > completes.
> > >
> > > I've looked through the 3.10 stable patches since 3.10.46 and don't
> > > see anything that looks like it addresses this.  Does anyone have any
> > > idea what might be going on here, and what the fix might be?
> > >
> > > Thanks,
> > > Shawn
> >
> > Hi Shawn, just started looking at this myself, and as Frank Sorensen points
> > out in https://bugzilla.redhat.com/show_bug.cgi?id=1209143 the problem is
> > that a task takes the xprt lock and then ends up in the refrigerator
> > effectively blocking other tasks from proceeding.
> >
> > Jeff, any suggestions on how to proceed here?
> 
> Sorry for the noise, and self-reply..  Looks like there's additional context
> here: http://marc.info/?t=136761512100007&r=1&w=2
> 
> Due to a number of locking problems the answer to this problem is likely to
> be "don't do that" for now.
> 
> Ben

Yeah, that's definitely the answer for now.

NFS and the freezer basically cooperate if you are freezing the whole
system, but freezing some tasks and not others is fraught with peril.
The problem is that by the time you get a freeze "signal" you might be
very deep inside the call stack, holding VFS layer locks, etc. and that
can block other non-freezing tasks from progressing.

My memory is vague, but Tejun (cc'ed) and I discussed this a couple of
years or so ago and the tentative idea at the time was to teach the
NFS and RPC code to return a particular error akin to ERESTARTSYS
(EFREEZE?) when a freeze event comes in and we haven't yet sent an RPC
call.

The idea was to teach the ptrace layer to watch for this error and
freeze at that point and then to reissue the syscall after resume. All
of that's a non-trivial task though, as knowledge of this would need to
be plumbed all the way through the stack down to the RPC layer.

When you have already sent the call though, then things get trickier.
You want to wait for a bit and see if the reply comes in. If it does,
great...just return and let the freeze in userland happen.

If it doesn't though then you're sort of screwed as you can't really
freeze (at least if you have a hard mount) since that mandates that you
keep retransmitting. So, we also discussed adding a new hard/soft
variant (slushy?) that basically acts like "hard" most of the time, but
"soft" when the freezer kicks in. That's not transparent to userland
though, so YMMV there...

Anyway, I'm afraid I won't have time to work on this anytime soon, but
if someone else wanted to pick up that torch and run with it I can try
to offer encouragement and guidance.

-- 
Jeff Layton <jeff.layton@primarydata.com>
