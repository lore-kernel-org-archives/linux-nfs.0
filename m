From: Marc Eshel <eshel@almaden.ibm.com>
Subject: Re: regression: oops due to recent nfsd4_lockt patch
Date: Fri, 16 Jan 2009 13:39:25 -0800
Message-ID: <OF1E9AE5DC.D8D57C12-ON88257540.0075DEE0-88257540.0076F6DA@us.ibm.com>
References: <1230856611-32574-1-git-send-email-bfields@citi.umich.edu>	<1230856611-32574-2-git-send-email-bfields@citi.umich.edu>
	<1230856611-32574-3-git-send-email-bfields@citi.umich.edu>	<20090116145832.0f93014a@tleilax.poochiereds.net> <20090116155742.36f4dea4@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>,
	linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:52294 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758321AbZAPVja (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Jan 2009 16:39:30 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n0GLc56P007213
	for <linux-nfs@vger.kernel.org>; Fri, 16 Jan 2009 16:38:05 -0500
Received: from d01av05.pok.ibm.com (d01av05.pok.ibm.com [9.56.224.195])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n0GLdTa2190148
	for <linux-nfs@vger.kernel.org>; Fri, 16 Jan 2009 16:39:29 -0500
Received: from d01av05.pok.ibm.com (loopback [127.0.0.1])
	by d01av05.pok.ibm.com (8.13.1/8.13.3) with ESMTP id n0GLdSk6019045
	for <linux-nfs@vger.kernel.org>; Fri, 16 Jan 2009 16:39:29 -0500
In-Reply-To: <20090116155742.36f4dea4-RtJpwOs3+0O+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff Layton <jlayton@redhat.com> wrote on 01/16/2009 12:57:42 PM:

> On Fri, 16 Jan 2009 14:58:32 -0500
> Jeff Layton <jlayton@redhat.com> wrote:
> 
> > On Thu,  1 Jan 2009 19:36:51 -0500
> > "J. Bruce Fields" <bfields@citi.umich.edu> wrote:
> > 
> > > I've got a slight fear that the problem Marc tripped across won't be 
the
> > > last that's caused by this hack of faking up a struct file with only
> > > some fields initialized.  We may as well just do an open, just as we 
do
> > > with reads and writes in the v2/v3 case, and get a proper struct 
file.
> > > 
> > > Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> > > ---
> > 
> > I was working on backporting this patch, but it seems to be causing a
> > reliable oops:
> > 
> > ----------------[snip]------------------
> > 
> > BUG: unable to handle kernel NULL pointer dereference at (null)
> > IP: [<ffffffff811928d9>] kref_get+0xc/0x2f
> > PGD 1685f067 PUD 16860067 PMD 0 
> > Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
> > last sysfs file: /sys/fs/gfs2/jtltest:v1/lock_module/recover_status
> > CPU 0 
> > Modules linked in: nfsd lockd nfs_acl exportfs ipt_MASQUERADE 
> iptable_nat nf_nat bridge stp llc lock_dlm gfs2 dlm configfs autofs4
> rpcsec_gss_krb5 auth_rpcgss des_generic sunrpc ipv6 dm_multipath 
> uinput i2c_piix4 8139cp pcspkr i2c_core 8139too mii ata_generic 
> pata_acpi [last unloaded: freq_table]
> > Pid: 4088, comm: nfsd Tainted: G        W  2.6.29-0.
> 35.rc1.git4.fc11.x86_64 #1
> > RIP: 0010:[<ffffffff811928d9>]  [<ffffffff811928d9>] kref_get+0xc/0x2f
> > RSP: 0018:ffff88000dadfc40  EFLAGS: 00010282
> > RAX: 0000000000000000 RBX: 0000000000000000 RCX: 0000000000000009
> > RDX: 0000000000000000 RSI: ffff88000fec42e0 RDI: 0000000000000000
> > RBP: ffff88000dadfc50 R08: ffff8800154b03d8 R09: ffffffff810dfc9f
> > R10: ffff88000f496d80 R11: ffff88000dadfc20 R12: ffff88000fec42e0
> > R13: ffff88000dadfcc0 R14: ffff88000dadfcc0 R15: ffffffffa04938d0
> > FS:  0000000000000000(0000) GS:ffffffff81934000(0000) 
knlGS:0000000000000000
> > CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
> > CR2: 0000000000000000 CR3: 000000001685e000 CR4: 00000000000006e0
> > DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> > DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> > Process nfsd (pid: 4088, threadinfo ffff88000dade000, task 
ffff88000dad2350)
> > Stack:
> >  ffff88000fec42a8 0000000000000000 ffff88000dadfc80 ffffffffa04628c3
> >  ffff88000dadfc70 0000000000000000 ffff88000fec42a8 000000001a270000
> >  ffff88000dadfde0 ffffffffa0464db0 0000000000000004 ffff88000f58b360
> > Call Trace:
> >  [<ffffffffa04628c3>] nfs4_set_lock_denied+0x2c/0xa9 [nfsd]
> >  [<ffffffffa0464db0>] nfsd4_lockt+0x323/0x38d [nfsd]
> >  [<ffffffffa045b6a4>] nfsd4_proc_compound+0x1d0/0x30c [nfsd]
> >  [<ffffffffa044d256>] nfsd_dispatch+0xe9/0x1ca [nfsd]
> >  [<ffffffffa01d4327>] svc_process+0x3fc/0x63f [sunrpc]
> >  [<ffffffff813828a2>] ? down_read+0x77/0x7f
> >  [<ffffffffa044d862>] nfsd+0x149/0x1a9 [nfsd]
> >  [<ffffffffa044d719>] ? nfsd+0x0/0x1a9 [nfsd]
> >  [<ffffffffa044d719>] ? nfsd+0x0/0x1a9 [nfsd]
> >  [<ffffffff8105e954>] kthread+0x49/0x76
> >  [<ffffffff8101262a>] child_rip+0xa/0x20
> >  [<ffffffff8138397a>] ? _spin_unlock_irq+0x2b/0x37
> >  [<ffffffff81011f3e>] ? restore_args+0x0/0x30
> >  [<ffffffff8105e8e6>] ? kthreadd+0x176/0x19b
> >  [<ffffffff8105e90b>] ? kthread+0x0/0x76
> >  [<ffffffff81012620>] ? child_rip+0x0/0x20
> > Code: ff f0 ff 0b 0f 94 c0 31 d2 84 c0 74 0b 48 89 df 41 ff d4 ba 
> 01 00 00 00 5b 89 d0 41 5c c9 c3 55 48 89 e5 53 48 89 fb 48 83 ec 08
> <8b> 07 85 c0 75 13 31 d2 be 2b 00 00 00 48 c7 c7 a9 5d 4c 81 e8 
> > RIP  [<ffffffff811928d9>] kref_get+0xc/0x2f
> >  RSP <ffff88000dadfc40>
> > CR2: 0000000000000000
> > ---[ end trace 4eaa2a86a8e2da24 ]---
> > 
> > ----------------[snip]------------------
> > 
> > Basically I have a GFS2 filesystem and have one process on the server
> > taking a lock on a file. When a NFSv4 client tries to do a GETLK
> > against the same file I get the above stack trace.
> > 
> > The problem is that nfsd4_lockt does this:
> > 
> >         lockt->lt_stateowner = find_lockstateowner_str(inode,
> >                         &lockt->lt_clientid, &lockt->lt_owner);
> >         if (lockt->lt_stateowner)
> >                 file_lock.fl_owner = (fl_owner_t)lockt->lt_stateowner;
> > 
> > ...but it's not finding anything in the lockowner hash since no NFSv4
> > client is holding a lock. So fl_owner ends up being NULL, but fl_type 
> > is F_UNLCK. We then call into nfs4_set_lock_denied(), which does this:
> > 
> >         if (fl->fl_lmops == &nfsd_posix_mng_ops) {
> >                 sop = (struct nfs4_stateowner *) fl->fl_owner;
> >                 hval = lockownerid_hashval(sop->so_id);
> >                 kref_get(&sop->so_ref);
> > 
> > ...and that then oops when dereferencing sop->so_ref.
> > 
> > So in any case, I see the cause here but the fix is not immediately
> > clear to me. Does nfs4_set_lock_denied() need to take into account the
> > possibility of a NULL fl_owner, or should we be allocating a new
> > lockstateowner in this case?
> > 
> 
> A little bit more info (and this is a little strange). Both with and
> without the patch, nfsd4_lockt does this:
> 
> file_lock.fl_lmops = &nfsd_posix_mng_ops;
> 
> ...but pre-patch, the fl_lmops ends up getting nulled out before calling
> into nfs4_set_lock_denied(), but after the patch it remains set to
> nfsd_posix_mng_ops. This accounts for why we didn't see this before the
> patch was applied.
> 

When we don't call the underling file system (which is without this patch) 
the code will call posix_test_lock() and this function will call 
__locks_copy_lock() which set fl_lmops to NULL. So a way that you can fix 
it to do the same in the file system, see in __locks_copy_lock() which are 
the important fields to copy and which to zero when a conflicting lock was 
found. 
On a related issue to Bruce, I never liked the code in 
nfs4_set_lock_denied() where is cast fl_owner to nfs4_stateowner and 
complained about it many times for now we can add a test to see if it is 
NULL.
Marc.

> -- 
> Jeff Layton <jlayton@redhat.com>

