Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50658 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757848AbcH3LL2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 30 Aug 2016 07:11:28 -0400
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id DEA5A635C3
        for <linux-nfs@vger.kernel.org>; Tue, 30 Aug 2016 11:11:27 +0000 (UTC)
Received: from [10.10.61.130] (vpn-61-130.rdu2.redhat.com [10.10.61.130])
        by int-mx14.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u7UBBQEc001676
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
        for <linux-nfs@vger.kernel.org>; Tue, 30 Aug 2016 07:11:27 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "List Linux NFS Mailing" <linux-nfs@vger.kernel.org>
Subject: Migration to self
Date: Tue, 30 Aug 2016 07:11:26 -0400
Message-ID: <5BAC7822-0023-4A20-A896-A353483E75C2@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,

Our QE has found that they can crash a client by having a server migrate 
the
client to itself.  Who would do that in real life?  Is a server allowed 
to
refer to itself?

The client crashes because it starts a migration, sets the current
nfs_client's slot table to drain, probes the new nfs_client and gets 
another
NFS4ERR_MOVED, schedules another migration, and then sleeps on the 
client
waitq waiting for the state manager in error recovery.

Then the state manager starts another migration, sets this new 
nfs_client's slot
table to drain, and the probe_fsinfo() sleeps on the slot table.

Finally someone notices the client is hung, and rpc_killall_tasks kills 
off
everything on the slot table and frees the server, but then the 
probe_fsinfo
that was waiting on the state manager in error recovery wakes up and 
tries
to read bits from that freed nfs_server:

Unable to handle kernel paging request for data at address 
0x656465736b746fa0
Faulting instruction address: 0xd0000000046006a8
Oops: Kernel access of bad area, sig: 11 [#1]
SMP NR_CPUS=2048 NUMA pSeries
Modules linked in: rpcsec_gss_krb5 nfsv4 dns_resolver nfs fscache 
virtio_balloon nfsd auth_rpcgss nf      s_acl lockd grace sunrpc 
ip_tables xfs libcrc32c virtio_net virtio_console virtio_blk virtio_pci 
virtio_ring virtio       dm_mirror dm_region_hash dm_log dm_mod
CPU: 6 PID: 12072 Comm: ::1-manager Not tainted 3.10.0-327.el7.ppc64 #1
task: c00000023678b010 ti: c00000002c3b8000 task.ti: c00000002c3b8000
NIP: d0000000046006a8 LR: d0000000046009bc CTR: c00000000048eba0
REGS: c00000002c3bb240 TRAP: 0300   Not tainted  (3.10.0-327.el7.ppc64)
MSR: 8000000100009032 <SF,EE,ME,IR,DR,RI>  CR: 28002024  XER: 20000000
CFAR: c000000000009368 DAR: 656465736b746fa0 DSISR: 40000000 SOFTE: 1
GPR00: d0000000046009bc c00000002c3bb4c0 d00000000468a9f0 
c00000002c3bb530
GPR04: c00000023380e800 c00000002c3bb640 c00000002c3bb660 
c00000002c3bb600
GPR08: c00000002c3bb660 656465736b746f70 c00000002c3bb600 
d00000000467cf10
GPR12: c00000000048eba0 c000000007b83600 c00000000010c220 
c000000233c8dc00
GPR16: c000000234800034 0000000000000010 c000000234a820f0 
0000000000000801
GPR20: c000000234810000 c000000233900000 c00000023380e800 
c00000000130fe00
GPR24: c000000003eb6600 0000000000000010 c000000237e645c0 
c00000002a9aa700
GPR28: c000000235eb0008 c000000233c89c00 c000000235eb0008 
c00000023380e800
NIP [d0000000046006a8] .nfs4_call_sync_sequence+0x48/0xa0 [nfsv4]
LR [d0000000046009bc] ._nfs4_server_capabilities+0x7c/0x2a0 [nfsv4]
Call Trace:
[c00000002c3bb4c0] [c000000000923240] .out_of_line_wait_on_bit+0xd0/0xe0 
(unreliable)
[c00000002c3bb590] [d0000000046009bc] 
._nfs4_server_capabilities+0x7c/0x2a0 [nfsv4]
[c00000002c3bb690] [d0000000046103fc] 
.nfs4_server_capabilities+0x3c/0x70 [nfsv4]
[c00000002c3bb730] [d0000000043e1f54] .nfs_probe_fsinfo+0x74/0x730 [nfs]
[c00000002c3bb830] [d00000000463b814] .nfs4_update_server+0x234/0x330 
[nfsv4]
[c00000002c3bba00] [d000000004638e00] 
.nfs4_replace_transport+0x200/0x370 [nfsv4]
[c00000002c3bbaf0] [d00000000462aab4] .nfs4_try_migration+0x244/0x360 
[nfsv4]
[c00000002c3bbb90] [d00000000462d328] .nfs4_state_manager+0x6b8/0xc00 
[nfsv4]
[c00000002c3bbcb0] [d00000000462d898] .nfs4_run_state_manager+0x28/0x50 
[nfsv4]
[c00000002c3bbd30] [c00000000010c308] .kthread+0xe8/0xf0
[c00000002c3bbe30] [c00000000000a470] .ret_from_kernel_thread+0x58/0x68

I would like to catch these sort of migration loops before we start
following them, and an easy place to do that is to check if the
nfs_server->nfs_client is already set and is the same as the found 
client in
nfs4_set_client().  Other than nfs4_try_migration(), the only other
callpaths for nfs4_set_client() are nfs4_init_server() and
nfs4_create_referral_server(), both of which have newly initialized 
servers.

Alternatively, a fix would need to have rpc_killall_tasks unwind tasks
waiting on the state manager in a series of migrations.

Any thoughts?  I'll follow up with a patch for nfs4_set_client() to 
return
an error rather than set the same client on the server.

Ben
