Return-Path: <SRS0=DJTG=SU=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7D7CBC10F14
	for <linux-nfs@archiver.kernel.org>; Thu, 18 Apr 2019 16:32:22 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 58A972183F
	for <linux-nfs@archiver.kernel.org>; Thu, 18 Apr 2019 16:32:22 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2389646AbfDRQcV (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 18 Apr 2019 12:32:21 -0400
Received: from mx2.math.uh.edu ([129.7.128.33]:56372 "EHLO mx2.math.uh.edu"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727807AbfDRQcV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 18 Apr 2019 12:32:21 -0400
Received: from epithumia.math.uh.edu ([129.7.128.2])
        by mx2.math.uh.edu with esmtp (Exim 4.92)
        (envelope-from <tibbs@math.uh.edu>)
        id 1hH9xS-0007p0-Sw
        for linux-nfs@vger.kernel.org; Thu, 18 Apr 2019 11:32:20 -0500
Received: by epithumia.math.uh.edu (Postfix, from userid 7225)
        id D13BE802A14; Thu, 18 Apr 2019 11:32:18 -0500 (CDT)
From:   Jason L Tibbitts III <tibbs@math.uh.edu>
To:     linux-nfs@vger.kernel.org
Subject: Re: Null pointer dereference in gss_verify_mic_kerberos (4.20.14)
References: <ufad0mn6hq7.fsf@epithumia.math.uh.edu>
Date:   Thu, 18 Apr 2019 11:32:18 -0500
In-Reply-To: <ufad0mn6hq7.fsf@epithumia.math.uh.edu> (Jason L. Tibbitts, III's
        message of "Mon, 18 Mar 2019 15:38:24 -0500")
Message-ID: <ufar29znujx.fsf@epithumia.math.uh.edu>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

I just hit a similar issue in 5.0.5.  This time instead of an oops it
was a general protection fault, but gss_verify_mic_kerberos is still
implicated.

I've updated the existing Fedora bug
(https://bugzilla.redhat.com/show_bug.cgi?id=1690123) and included the
kernel log output below, but I'm not sure what else I can do at this
point.  It's rare but when it hits all activity on the mount will hang
which makes the machine basically useless until a reboot.

general protection fault: 0000 [#1] SMP PTI
CPU: 2 PID: 23494 Comm: MATLAB Not tainted 5.0.5-200.fc29.x86_64 #1
Hardware name: To Be Filled By O.E.M. To Be Filled By O.E.M./Z170 Gaming-ITX/ac, BIOS P2.10 04/13/2016
RIP: 0010:gss_verify_mic_kerberos+0x73/0x300 [rpcsec_gss_krb5]
Code: 00 0f 84 a7 02 00 00 48 8d 44 24 34 4c 8b 62 08 c7 44 24 20 14 00 00 00 48 89 44 24 28 f6 05 7f 07>
RSP: 0018:ffffa123c821b738 EFLAGS: 00010246
RAX: ffffa123c821b76c RBX: ffff8dee49bfb800 RCX: 0000000000000012
RDX: ffffa123c821b7b0 RSI: ffffa123c821b7c0 RDI: ffff8deed94f0730
RBP: ffffa123c821b7c0 R08: 00000000000002f4 R09: ffff8dec806c5b40
R10: ffff8decf0198f98 R11: 00000000e22f0760 R12: b3ee8b75a91dc700
R13: 0000000000000000 R14: 0000000000004f64 R15: ffff8def389f6c00
FS:  00007fcce5cf3700(0000) GS:ffff8def55f00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00001de264a1b000 CR3: 000000050d684001 CR4: 00000000003606e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
Call Trace:
 gss_unwrap_resp_integ.isra.12+0xa6/0xf0 [auth_rpcgss]
 ? nfs4_xdr_dec_layoutget+0xa0/0xa0 [nfsv4]
 gss_unwrap_resp+0x1c4/0x230 [auth_rpcgss]
 ? gss_validate+0x1b4/0x200 [auth_rpcgss]
 ? nfs4_xdr_dec_layoutget+0xa0/0xa0 [nfsv4]
 rpcauth_unwrap_resp+0x67/0xc0 [sunrpc]
 ? nfs4_xdr_dec_layoutget+0xa0/0xa0 [nfsv4]
 call_decode+0x260/0x500 [sunrpc]
 ? trace_event_raw_event_rpc_stats_latency+0x240/0x240 [sunrpc]
 ? call_refreshresult+0xd0/0xd0 [sunrpc]
 __rpc_execute+0x7f/0x350 [sunrpc]
 ? recalibrate_cpu_khz+0x10/0x10
 ? ktime_get+0x36/0xa0
 rpc_run_task+0xfc/0x130 [sunrpc]
 nfs4_call_sync_sequence+0x64/0xa0 [nfsv4]
 _nfs4_proc_readdir+0x208/0x280 [nfsv4]
 nfs4_proc_readdir+0x86/0x120 [nfsv4]
 ? nfs4_proc_symlink+0x1e0/0x1e0 [nfsv4]
 nfs_readdir_xdr_to_array+0x17a/0x3f0 [nfs]
 ? xas_store+0x4b/0x540
 ? mem_cgroup_commit_charge+0x82/0x150
 ? __add_to_page_cache_locked+0x336/0x3e0
 nfs_readdir_filler+0x1b/0x90 [nfs]
 do_read_cache_page+0x371/0x7e0
 ? nfs_readdir_xdr_to_array+0x3f0/0x3f0 [nfs]
 ? nfs4_do_check_delegation+0x18/0x40 [nfsv4]
 ? nfs_check_cache_invalid+0x33/0x90 [nfs]
 nfs_readdir+0x137/0x510 [nfs]
 ? nfs4_xdr_dec_allocate+0xd0/0xd0 [nfsv4]
 iterate_dir+0x91/0x190
 ksys_getdents64+0x9c/0x130
 ? iterate_dir+0x190/0x190
 __x64_sys_getdents64+0x16/0x20
 do_syscall_64+0x5b/0x160
 entry_SYSCALL_64_after_hwframe+0x44/0xa9
RIP: 0033:0x7fcdc17b8dfb
Code: 00 00 48 83 c4 08 5b 5d c3 66 0f 1f 44 00 00 f3 0f 1e fa 48 8b 47 20 c3 0f 1f 80 00 00 00 00 f3 0f>
RSP: 002b:00007fcce5cf2128 EFLAGS: 00000246 ORIG_RAX: 00000000000000d9
RAX: ffffffffffffffda RBX: 00007fcd28115eb0 RCX: 00007fcdc17b8dfb
RDX: 0000000000008000 RSI: 00007fcd28115ee0 RDI: 0000000000000319
RBP: 00007fcd28115ee0 R08: 0000000000000000 R09: 0000000000000005
R10: 0000000000000038 R11: 0000000000000246 R12: ffffffffffffff40
R13: 0000000000000002 R14: 00000000018f99f8 R15: 00007fcce5cf2220
Modules linked in: rpcsec_gss_krb5 nfsv4 dns_resolver nfs lockd grace fscache ip6t_rpfilter ip6t_REJECT >
---[ end trace 7ae22b160d893b2f ]---
RIP: 0010:gss_verify_mic_kerberos+0x73/0x300 [rpcsec_gss_krb5]
Code: 00 0f 84 a7 02 00 00 48 8d 44 24 34 4c 8b 62 08 c7 44 24 20 14 00 00 00 48 89 44 24 28 f6 05 7f 07>
RSP: 0018:ffffa123c821b738 EFLAGS: 00010246
RAX: ffffa123c821b76c RBX: ffff8dee49bfb800 RCX: 0000000000000012
RDX: ffffa123c821b7b0 RSI: ffffa123c821b7c0 RDI: ffff8deed94f0730
RBP: ffffa123c821b7c0 R08: 00000000000002f4 R09: ffff8dec806c5b40
R10: ffff8decf0198f98 R11: 00000000e22f0760 R12: b3ee8b75a91dc700
R13: 0000000000000000 R14: 0000000000004f64 R15: ffff8def389f6c00
FS:  00007fcce5cf3700(0000) GS:ffff8def55f00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00001de264a1b000 CR3: 000000050d684001 CR4: 00000000003606e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
