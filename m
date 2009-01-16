From: Jeff Layton <jlayton@redhat.com>
Subject: regression: oops due to recent nfsd4_lockt patch
Date: Fri, 16 Jan 2009 14:58:32 -0500
Message-ID: <20090116145832.0f93014a@tleilax.poochiereds.net>
References: <1230856611-32574-1-git-send-email-bfields@citi.umich.edu>
	<1230856611-32574-2-git-send-email-bfields@citi.umich.edu>
	<1230856611-32574-3-git-send-email-bfields@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org, Marc Eshel <eshel@almaden.ibm.com>
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:55977 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756340AbZAPUAh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Jan 2009 15:00:37 -0500
In-Reply-To: <1230856611-32574-3-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu,  1 Jan 2009 19:36:51 -0500
"J. Bruce Fields" <bfields@citi.umich.edu> wrote:

> I've got a slight fear that the problem Marc tripped across won't be the
> last that's caused by this hack of faking up a struct file with only
> some fields initialized.  We may as well just do an open, just as we do
> with reads and writes in the v2/v3 case, and get a proper struct file.
> 
> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> ---

I was working on backporting this patch, but it seems to be causing a
reliable oops:

----------------[snip]------------------

BUG: unable to handle kernel NULL pointer dereference at (null)
IP: [<ffffffff811928d9>] kref_get+0xc/0x2f
PGD 1685f067 PUD 16860067 PMD 0 
Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
last sysfs file: /sys/fs/gfs2/jtltest:v1/lock_module/recover_status
CPU 0 
Modules linked in: nfsd lockd nfs_acl exportfs ipt_MASQUERADE iptable_nat nf_nat bridge stp llc lock_dlm gfs2 dlm configfs autofs4 rpcsec_gss_krb5 auth_rpcgss des_generic sunrpc ipv6 dm_multipath uinput i2c_piix4 8139cp pcspkr i2c_core 8139too mii ata_generic pata_acpi [last unloaded: freq_table]
Pid: 4088, comm: nfsd Tainted: G        W  2.6.29-0.35.rc1.git4.fc11.x86_64 #1
RIP: 0010:[<ffffffff811928d9>]  [<ffffffff811928d9>] kref_get+0xc/0x2f
RSP: 0018:ffff88000dadfc40  EFLAGS: 00010282
RAX: 0000000000000000 RBX: 0000000000000000 RCX: 0000000000000009
RDX: 0000000000000000 RSI: ffff88000fec42e0 RDI: 0000000000000000
RBP: ffff88000dadfc50 R08: ffff8800154b03d8 R09: ffffffff810dfc9f
R10: ffff88000f496d80 R11: ffff88000dadfc20 R12: ffff88000fec42e0
R13: ffff88000dadfcc0 R14: ffff88000dadfcc0 R15: ffffffffa04938d0
FS:  0000000000000000(0000) GS:ffffffff81934000(0000) knlGS:0000000000000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: 0000000000000000 CR3: 000000001685e000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process nfsd (pid: 4088, threadinfo ffff88000dade000, task ffff88000dad2350)
Stack:
 ffff88000fec42a8 0000000000000000 ffff88000dadfc80 ffffffffa04628c3
 ffff88000dadfc70 0000000000000000 ffff88000fec42a8 000000001a270000
 ffff88000dadfde0 ffffffffa0464db0 0000000000000004 ffff88000f58b360
Call Trace:
 [<ffffffffa04628c3>] nfs4_set_lock_denied+0x2c/0xa9 [nfsd]
 [<ffffffffa0464db0>] nfsd4_lockt+0x323/0x38d [nfsd]
 [<ffffffffa045b6a4>] nfsd4_proc_compound+0x1d0/0x30c [nfsd]
 [<ffffffffa044d256>] nfsd_dispatch+0xe9/0x1ca [nfsd]
 [<ffffffffa01d4327>] svc_process+0x3fc/0x63f [sunrpc]
 [<ffffffff813828a2>] ? down_read+0x77/0x7f
 [<ffffffffa044d862>] nfsd+0x149/0x1a9 [nfsd]
 [<ffffffffa044d719>] ? nfsd+0x0/0x1a9 [nfsd]
 [<ffffffffa044d719>] ? nfsd+0x0/0x1a9 [nfsd]
 [<ffffffff8105e954>] kthread+0x49/0x76
 [<ffffffff8101262a>] child_rip+0xa/0x20
 [<ffffffff8138397a>] ? _spin_unlock_irq+0x2b/0x37
 [<ffffffff81011f3e>] ? restore_args+0x0/0x30
 [<ffffffff8105e8e6>] ? kthreadd+0x176/0x19b
 [<ffffffff8105e90b>] ? kthread+0x0/0x76
 [<ffffffff81012620>] ? child_rip+0x0/0x20
Code: ff f0 ff 0b 0f 94 c0 31 d2 84 c0 74 0b 48 89 df 41 ff d4 ba 01 00 00 00 5b 89 d0 41 5c c9 c3 55 48 89 e5 53 48 89 fb 48 83 ec 08 <8b> 07 85 c0 75 13 31 d2 be 2b 00 00 00 48 c7 c7 a9 5d 4c 81 e8 
RIP  [<ffffffff811928d9>] kref_get+0xc/0x2f
 RSP <ffff88000dadfc40>
CR2: 0000000000000000
---[ end trace 4eaa2a86a8e2da24 ]---

----------------[snip]------------------

Basically I have a GFS2 filesystem and have one process on the server
taking a lock on a file. When a NFSv4 client tries to do a GETLK
against the same file I get the above stack trace.

The problem is that nfsd4_lockt does this:

        lockt->lt_stateowner = find_lockstateowner_str(inode,
                        &lockt->lt_clientid, &lockt->lt_owner);
        if (lockt->lt_stateowner)
                file_lock.fl_owner = (fl_owner_t)lockt->lt_stateowner;

...but it's not finding anything in the lockowner hash since no NFSv4
client is holding a lock. So fl_owner ends up being NULL, but fl_type 
is F_UNLCK. We then call into nfs4_set_lock_denied(), which does this:

        if (fl->fl_lmops == &nfsd_posix_mng_ops) {
                sop = (struct nfs4_stateowner *) fl->fl_owner;
                hval = lockownerid_hashval(sop->so_id);
                kref_get(&sop->so_ref);

...and that then oops when dereferencing sop->so_ref.

So in any case, I see the cause here but the fix is not immediately
clear to me. Does nfs4_set_lock_denied() need to take into account the
possibility of a NULL fl_owner, or should we be allocating a new
lockstateowner in this case?

-- 
Jeff Layton <jlayton@redhat.com>
