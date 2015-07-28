Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:60638 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752535AbbG1VEf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Jul 2015 17:04:35 -0400
Date: Tue, 28 Jul 2015 17:04:34 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Andrew W Elble <aweits@rit.edu>, linux-nfs@vger.kernel.org,
        Anna Schumaker <schumakeranna@gmail.com>
Subject: Re: list_del corruption / unhash_ol_stateid()
Message-ID: <20150728210434.GC9349@fieldses.org>
References: <m23809zl8z.fsf@discipline.rit.edu>
 <m2zj2hwk4e.fsf@discipline.rit.edu>
 <20150728090206.1331e476@tlielax.poochiereds.net>
 <m2wpxktjfc.fsf@discipline.rit.edu>
 <20150728114933.6f917374@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150728114933.6f917374@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 28, 2015 at 11:49:33AM -0400, Jeff Layton wrote:
> On Tue, 28 Jul 2015 11:01:59 -0400
> Andrew W Elble <aweits@rit.edu> wrote:
> 
> > 
> > Still trying to develop some kind of test to reliably trigger this.
> > 
> > > My guess is that that may be collateral damage from the double
> > > unhashing of the stateid. It certainly doesn't look directly related to
> > > anything in knfsd -- it's a crash down deep in the POSIX ACL code,
> > > apparently.
> > 
> > Thinking that it's collateral - here's the backtrace from a similar
> > event.
> > 
> > (was preceded by both the WARN_ON_ONCE() and the list_del corruption messages)
> > 
> > running 3.18.9:
> > 
> > [846121.007040] general protection fault: 0000 [#1] SMP
> > [846121.013461] Modules linked in: nfnetlink_queue nfnetlink_log nfnetlink bluetooth gfs2 dlm sctp sg dm_service_time cts iscsi_tcp libiscsi_tcp libiscsi rpcsec_gss_
> > krb5 nfsv4 dns_resolver nfs scsi_transport_iscsi fscache 8021q nf_log_ipv4 nf_log_common garp xt_LOG mrp stp llc bonding xt_conntrack cfg80211 iptable_filter nf_conn
> > track_ftp nf_conntrack_ipv4 nf_defrag_ipv4 nf_conntrack rfkill ip_tables dm_multipath x86_pkg_temp_thermal coretemp kvm_intel kvm crct10dif_pclmul crc32_pclmul crc32
> > c_intel ghash_clmulni_intel mei_me mei aesni_intel lrw gf128mul glue_helper nfsd ablk_helper sb_edac iTCO_wdt ipmi_devintf pcspkr acpi_power_meter iTCO_vendor_suppor
> > t dcdbas ipmi_si edac_core cryptd lpc_ich mfd_core wmi shpchp ipmi_msghandler acpi_pad auth_rpcgss nfs_acl lockd grace sunrpc binfmt_misc xfs sr_mod cdrom mgag200 sy
> > scopyarea sd_mod sysfillrect sysimgblt i2c_algo_bit ixgbe drm_kms_helper mdio tg3 ttm ahci dca drm libahci ptp libata megaraid_sas i2c_core pps_core dm_mirror dm_region_hash dm_log dm_mod
> > [846121.119250] CPU: 8 PID: 46216 Comm: nfsd Tainted: G        W      3.18.9 #1
> > [846121.127982] Hardware name: Dell Inc. PowerEdge R720/0X3D66, BIOS 2.4.3 07/09/2014
> > [846121.137268] task: ffff881ecd854330 ti: ffff881ecebf4000 task.ti: ffff881ecebf4000
> > [846121.146540] RIP: 0010:[<ffffffff811c7595>]  [<ffffffff811c7595>] kmem_cache_alloc+0x65/0x140
> > [846121.156839] RSP: 0018:ffff881ecebf7c28  EFLAGS: 00010286
> > [846121.163626] RAX: 0000000000000000 RBX: ffff8811bd0cf3e0 RCX: 0000000000003a0c
> > [846121.172438] RDX: 0000000000003a0b RSI: 00000000000080d0 RDI: ffff881fff489000
> > [846121.181267] RBP: ffff881ecebf7c68 R08: 0000000000016ae0 R09: 00000000b9acddf8
> > [846121.190049] R10: ffff883fe43df000 R11: ffff881856038437 R12: ff88185603834800
> > [846121.198826] R13: 00000000000080d0 R14: ffff881fff489000 R15: ffffffffa0517b79
> > [846121.207623] FS:  0000000000000000(0000) GS:ffff881fffa80000(0000) knlGS:0000000000000000
> > [846121.217475] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > [846121.224720] CR2: 00000000006e8360 CR3: 00000000019bc000 CR4: 00000000001407e0
> > [846121.233525] Stack:
> > [846121.236601]  0000000000000014 ffff881fff403c00 ffff881ecebf7c88 ffff8811bd0cf3e0
> > [846121.245723]  ffff883fe43df000 ffff8835d38afa80 0000000000000000 ffff881fff489000
> > [846121.254854]  ffff881ecebf7ca8 ffffffffa0517b79 0000000000000000 ffff8811bd0cf3e0
> > [846121.263984] Call Trace:
> > [846121.267559]  [<ffffffffa0517b79>] nfs4_alloc_stid+0x29/0xc0 [nfsd]
> > [846121.275355]  [<ffffffffa051fcf8>] nfsd4_lock+0x6f8/0xda0 [nfsd]
> > [846121.282870]  [<ffffffffa050cf07>] nfsd4_proc_compound+0x4d7/0x7f0 [nfsd]
> > [846121.291191]  [<ffffffffa04f8e43>] nfsd_dispatch+0xc3/0x210 [nfsd]
> > [846121.298869]  [<ffffffffa01c8e02>] ? svc_tcp_adjust_wspace+0x12/0x30 [sunrpc]
> > [846121.307590]  [<ffffffffa01c7d23>] svc_process_common+0x453/0x6f0 [sunrpc]
> > [846121.316018]  [<ffffffffa01c80c7>] svc_process+0x107/0x170 [sunrpc]
> > [846121.323764]  [<ffffffffa04f87c7>] nfsd+0xf7/0x160 [nfsd]
> > [846121.330541]  [<ffffffffa04f86d0>] ? nfsd_destroy+0x80/0x80 [nfsd]
> > [846121.338226]  [<ffffffff81093861>] kthread+0xe1/0x100
> > [846121.344624]  [<ffffffff81093780>] ? kthread_create_on_node+0x1b0/0x1b0
> > [846121.352776]  [<ffffffff816912fc>] ret_from_fork+0x7c/0xb0
> > [846121.359661]  [<ffffffff81093780>] ? kthread_create_on_node+0x1b0/0x1b0
> > [846121.367961] Code: cc 00 00 49 8b 50 08 4d 8b 20 49 8b 40 10 4d 85 e4 0f 84 a7 00 00 00 48 85 c0 0f 84 9e 00 00 00 49 63 46 20 48 8d 4a 01 4d 8b 06 <49> 8b 1c 04 4c 89 e0 65 49 0f c7 08 0f 94 c0 84 c0 74 b9 49 63
> > [846121.391248] RIP  [<ffffffff811c7595>] kmem_cache_alloc+0x65/0x140
> > [846121.398936]  RSP <ffff881ecebf7c28>
> > 
> 
> I wonder if this could be the race. In nfsd4_process_open2:
> 
> -------------------[snip]-------------------
>         if (stp) {
>                 /* Stateid was found, this is an OPEN upgrade */
>                 status = nfs4_upgrade_open(rqstp, fp, current_fh, stp, open);
>                 if (status)
>                         goto out;
>         } else {
>                 stp = open->op_stp;
>                 open->op_stp = NULL;
>                 init_open_stateid(stp, fp, open);
>                 status = nfs4_get_vfs_file(rqstp, fp, current_fh, stp, open);
>                 if (status) {
>                         release_open_stateid(stp);
>                         goto out;
>                 }
> 
>                 stp->st_clnt_odstate = find_or_hash_clnt_odstate(fp,
>                                                         open->op_odstate);
>                 if (stp->st_clnt_odstate == open->op_odstate)
>                         open->op_odstate = NULL;
>         }
> -------------------[snip]-------------------
> 
> init_open_stateid will hash the stateid, and then call
> nfs4_get_vfs_file, which does the actual dentry_open, sets the access
> mode, etc.
> 
> If that fails, it calls release_open_stateid which basically
> unrolls the whole thing -- tears down the stateid, unhashing it in the
> process.
> 
> In that window where it's hashed though, another open could come along
> and find that stateid. If it does, then it will call nfs4_upgrade_open.
> If it requests the same access as the first open then it won't try to
> actually open the file at all. It'll just assume that the stateid has
> the correct access and proceed.
> 
> At that point, you may have all the access bits set in the nfs4_file,
> but no actual filp associated with it. That may explain the WARN
> popping.
> 
> In a similar race, you could have two opens racing for different access
> (maybe one for read and one for write), or a race between an OPEN and
> CLOSE.
> 
> In short, I think that there are a couple of potential races here:
> 
> 1) That release_open_stateid could be problematic, simply because you
> could have another user of that stateid race in before it's fully set
> up. We probably need to do that a bit more gracefully though I'm a
> little unclear on the right solution.
> 
> 2) We probably need nfs4_upgrade_open to block until the necessary
> fi->fi_fds field has been set up.
> 
> OTOH, maybe this code needs a more fundamental rethink to close these
> races -- I'm not sure...
> 
> Bruce, any thoughts?

Thanks for catching that, it does look pretty suspicious!  But I need to
look at it closer.

It does sounds like both Andrew and Anna are able to trigger this fairly
quickly, so might be worth adding a WARN_ON_ONCE() or two here in
nfsd4_process_open2 to confirm whether either the upgrade or
release_open_stateid cases are dealing with a partially setup stateid.

--b.
