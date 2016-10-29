Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:33071 "EHLO
        mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750701AbcJ2Oc7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 29 Oct 2016 10:32:59 -0400
Received: by mail-qk0-f181.google.com with SMTP id v138so27680010qka.0
        for <linux-nfs@vger.kernel.org>; Sat, 29 Oct 2016 07:32:59 -0700 (PDT)
Message-ID: <1477751574.13215.5.camel@redhat.com>
Subject: Re: general protection fault in release_lock_stateid
From: Jeff Layton <jlayton@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Date: Sat, 29 Oct 2016 10:32:54 -0400
In-Reply-To: <17B7F931-8BD0-422B-B4B5-68C6940C838D@oracle.com>
References: <17B7F931-8BD0-422B-B4B5-68C6940C838D@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2016-10-28 at 22:14 -0400, Chuck Lever wrote:
> Hi Jeff-
> 
> When I push NFSv4.1 / RDMA hard, (xfstests generic/089, for example),
> I get this crash on the server:
> 
> Oct 28 22:04:30 klimt kernel: general protection fault: 0000 [#1] SMP DEBUG_PAGEALLOC
> Oct 28 22:04:30 klimt kernel: Modules linked in: cts rpcsec_gss_krb5 iTCO_wdt iTCO_vendor_support sb_edac edac_core x86_pkg_temp_thermal intel_powerclamp coretemp kvm_intel kvm btrfs irqbypass crct10dif_pclmul crc32_pclmul ghash_clmulni_intel aesni_intel lrw gf128mul glue_helper ablk_helper cryptd xor pcspkr raid6_pq i2c_i801 i2c_smbus lpc_ich mfd_core sg mei_me mei ioatdma shpchp wmi ipmi_si ipmi_msghandler rpcrdma ib_ipoib rdma_ucm acpi_power_meter acpi_pad ib_ucm ib_uverbs ib_umad rdma_cm ib_cm iw_cm nfsd auth_rpcgss nfs_acl lockd grace sunrpc ip_tables xfs libcrc32c mlx4_ib mlx4_en ib_core sr_mod cdrom sd_mod ast drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops ttm drm crc32c_intel igb ahci libahci ptp mlx4_core pps_core dca libata i2c_algo_bit i2c_core dm_mirror dm_region_hash dm_log dm_mod
> Oct 28 22:04:30 klimt kernel: CPU: 7 PID: 1558 Comm: nfsd Not tainted 4.9.0-rc2-00005-g82cd754 #8
> Oct 28 22:04:30 klimt kernel: Hardware name: Supermicro Super Server/X10SRL-F, BIOS 1.0c 09/09/2015
> Oct 28 22:04:30 klimt kernel: task: ffff880835c3a100 task.stack: ffff8808420d8000
> Oct 28 22:04:30 klimt kernel: RIP: 0010:[<ffffffffa05a759f>]  [<ffffffffa05a759f>] release_lock_stateid+0x1f/0x60 [nfsd]
> Oct 28 22:04:30 klimt kernel: RSP: 0018:ffff8808420dbce0  EFLAGS: 00010246
> Oct 28 22:04:30 klimt kernel: RAX: ffff88084e6660f0 RBX: ffff88084e667020 RCX: 0000000000000000
> Oct 28 22:04:30 klimt kernel: RDX: 0000000000000007 RSI: 0000000000000000 RDI: ffff88084e667020
> Oct 28 22:04:30 klimt kernel: RBP: ffff8808420dbcf8 R08: 0000000000000001 R09: 0000000000000000
> Oct 28 22:04:30 klimt kernel: R10: ffff880835c3a100 R11: ffff880835c3aca8 R12: 6b6b6b6b6b6b6b6b
> Oct 28 22:04:30 klimt kernel: R13: ffff88084e6670d8 R14: ffff880835f546f0 R15: ffff880835f1c548
> Oct 28 22:04:30 klimt kernel: FS:  0000000000000000(0000) GS:ffff88087bdc0000(0000) knlGS:0000000000000000
> Oct 28 22:04:30 klimt kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> Oct 28 22:04:30 klimt kernel: CR2: 00007ff020389000 CR3: 0000000001c06000 CR4: 00000000001406e0
> Oct 28 22:04:30 klimt kernel: Stack:
> Oct 28 22:04:30 klimt kernel: ffff88084e667020 0000000000000000 ffff88084e6670d8 ffff8808420dbd20
> Oct 28 22:04:30 klimt kernel: ffffffffa05ac80d ffff880835f54548 ffff88084e640008 ffff880835f545b0
> Oct 28 22:04:30 klimt kernel: ffff8808420dbd70 ffffffffa059803d ffff880835f1c768 0000000000000870
> Oct 28 22:04:30 klimt kernel: Call Trace:
> Oct 28 22:04:30 klimt kernel: [<ffffffffa05ac80d>] nfsd4_free_stateid+0xfd/0x1b0 [nfsd]
> Oct 28 22:04:30 klimt kernel: [<ffffffffa059803d>] nfsd4_proc_compound+0x40d/0x690 [nfsd]
> Oct 28 22:04:30 klimt kernel: [<ffffffffa0583114>] nfsd_dispatch+0xd4/0x1d0 [nfsd]
> Oct 28 22:04:30 klimt kernel: [<ffffffffa047bbf9>] svc_process_common+0x3d9/0x700 [sunrpc]
> Oct 28 22:04:30 klimt kernel: [<ffffffffa047ca64>] svc_process+0xf4/0x330 [sunrpc]
> Oct 28 22:04:30 klimt kernel: [<ffffffffa05827ca>] nfsd+0xfa/0x160 [nfsd]
> Oct 28 22:04:30 klimt kernel: [<ffffffffa05826d0>] ? nfsd_destroy+0x170/0x170 [nfsd]
> Oct 28 22:04:30 klimt kernel: [<ffffffff810b367b>] kthread+0x10b/0x120
> Oct 28 22:04:30 klimt kernel: [<ffffffff810b3570>] ? kthread_stop+0x280/0x280
> Oct 28 22:04:30 klimt kernel: [<ffffffff8174e8ba>] ret_from_fork+0x2a/0x40
> Oct 28 22:04:30 klimt kernel: Code: c3 66 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 55 48 89 e5 41 55 41 54 53 48 8b 87 b0 00 00 00 48 89 fb 4c 8b a0 98 00 00 00 <49> 8b 44 24 20 48 8d b8 80 03 00 00 e8 10 66 1a e1 48 89 df e8 
> Oct 28 22:04:30 klimt kernel: RIP  [<ffffffffa05a759f>] release_lock_stateid+0x1f/0x60 [nfsd]
> Oct 28 22:04:30 klimt kernel: RSP <ffff8808420dbce0>
> Oct 28 22:04:30 klimt kernel: ---[ end trace cf5d0b371973e167 ]---
> 
> [cel@klimt nfsd]$ gdb nfsd.ko 
> GNU gdb (GDB) Red Hat Enterprise Linux 7.6.1-80.el7
> Copyright (C) 2013 Free Software Foundation, Inc.
> License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
> This is free software: you are free to change and redistribute it.
> There is NO WARRANTY, to the extent permitted by law.  Type "show copying"
> and "show warranty" for details.
> This GDB was configured as "x86_64-redhat-linux-gnu".
> For bug reporting instructions, please see:
> <http://www.gnu.org/software/gdb/bugs/>...
> Reading symbols from /usr/lib/modules/4.9.0-rc2-00005-g82cd754/kernel/fs/nfsd/nfsd.ko...done.
> (gdb) list *(release_lock_stateid+0x1f)
> 0x265cf is in release_lock_stateid (/home/cel/src/linux/linux-2.6/include/linux/spinlock.h:302).
> 297		raw_spin_lock_init(&(_lock)->rlock);		\
> 298	} while (0)
> 299	
> 300	static __always_inline void spin_lock(spinlock_t *lock)
> 301	{
> 302		raw_spin_lock(&lock->rlock);
> 303	}
> 304	
> 305	static __always_inline void spin_lock_bh(spinlock_t *lock)
> 306	{
> (gdb)
> 
> 1239 static void release_lock_stateid(struct nfs4_ol_stateid *stp)
> 1240 {
> 1241         struct nfs4_openowner *oo = openowner(stp->st_openstp->st_stateowner);
> 1242         bool unhashed;
> 1243 
> 1244         spin_lock(&oo->oo_owner.so_client->cl_lock);
> 1245         unhashed = unhash_lock_stateid(stp);
> 1246         spin_unlock(&oo->oo_owner.so_client->cl_lock);
> 1247         if (unhashed)
> 1248                 nfs4_put_stid(&stp->st_stid);
> 1249 }
> 
> This is the new code we added to deal with the race between FREE_STATEID and LOCK.
> 
> 
> 

Interesting. I'm guessing that means that we have a different race there
as well. Is it possible for you to get and poke at a vmcore?

What I think would be ideal would be to try and backtrack the various
pointers there. Is the lock stateid actually bogus, or is it just the oo
or even the so_client?

Hm...now that I look though, this is a little suspicious:

    struct nfs4_openowner *oo = openowner(stp->st_openstp->st_stateowner);

I wonder if it's possible for the openstateid to have already been
destroyed at this point.

We might be better off doing something like this to get the client pointer:

    stp->st_stid.sc_client;

...which should be more direct and less dependent on other stateids
staying valid. I can't spin up a patch at the moment, but if you feel like
trying that, then I'd be interested to see if it helps.

-- 
Jeff Layton <jlayton@redhat.com>
